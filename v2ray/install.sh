#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
cd `dirname $0`
ISPDNS=223.5.5.5
# 上游DNS
UPDNS=127.0.0.1#5353
#UPDNS=$ISPDNS

Install() {
	# apt-get install unzip -y  

	# Install V2Ray
	echo "Install V2Ray"
	bash go.sh --local ./v2ray-linux-mipsle.zip

	# 新建一个名为 V2RAY 的链
	iptables -t nat -N V2RAY
	# 直连 SO_MARK 为 0xff 的流量(0xff 是 16 进制数，数值上等同与上面配置的 255)，此规则目的是避免代理本机(网关)流量出现回环问题
	iptables -t nat -A V2RAY -p tcp -j RETURN -m mark --mark 0xff
	# 允许连接保留地址
	# 直连 192.168.0.0/16
	iptables -t nat -A V2RAY -d 0.0.0.0/8 -j RETURN
	iptables -t nat -A V2RAY -d 10.0.0.0/8 -j RETURN
	iptables -t nat -A V2RAY -d 127.0.0.0/8 -j RETURN
	iptables -t nat -A V2RAY -d 169.254.0.0/16 -j RETURN
	iptables -t nat -A V2RAY -d 172.16.0.0/12 -j RETURN
	iptables -t nat -A V2RAY -d 192.168.0.0/16 -j RETURN
	iptables -t nat -A V2RAY -d 224.0.0.0/4 -j RETURN
	iptables -t nat -A V2RAY -d 240.0.0.0/4 -j RETURN

	# 其余流量转发到 12345 端口（即 V2Ray）
	iptables -t nat -A V2RAY -p tcp -j REDIRECT --to-ports 12345
	# 对局域网其他设备进行透明代理
	iptables -t nat -I PREROUTING -p tcp -j V2RAY
	# 对本机进行透明代理
	iptables -t nat -I OUTPUT -p tcp -j V2RAY
	
	sed -i "s|server=.*$|server=${UPDNS}|" /etc/dnsmasq.conf
	[ 0 == `grep "^server=" /etc/dnsmasq.conf|wc -l` ] && echo server=$UPDNS >> /etc/dnsmasq.conf
	sed -i "s|^# no-resolv|no-resolv|" /etc/dnsmasq.conf
	[ 0 == `grep "^no-resolv" /etc/dnsmasq.conf|wc -l` ] && echo no-resolv >> /etc/dnsmasq.conf
	set -i "s|^# conf-dir=/etc/dnsmasq.d|conf-dir=/etc/dnsmasq.d|" /etc/dnsmasq.conf
	[ 0 == `grep "^conf-dir=" /etc/dnsmasq.conf|wc -l` ] && echo conf-dir=/etc/dnsmasq.d >> /etc/dnsmasq.conf
	
	service v2ray start
	service dnsmasq restart
}

Uninstall() {
	echo "Uninstall V2Ray"

	# 对局域网其他设备进行透明代理
	iptables -t nat -D PREROUTING -p tcp -j V2RAY
	# 对本机进行透明代理
	iptables -t nat -D OUTPUT -p tcp -j V2RAY
	# 清空删除V2RAY
	iptables -t nat -F V2RAY
	iptables -t nat -X V2RAY
	sed -i "/^server=.*$/d" /etc/dnsmasq.conf
	sed -i "s|^no-resolv|# no-resolv|" /etc/dnsmasq.conf
	sed -i "s|^conf-dir=/etc/dnsmasq.d|# conf-dir=/etc/dnsmasq.d|" /etc/dnsmasq.conf
	
	service v2ray stop
	service dnsmasq restart
}


until
echo "Usage Select You Connect Mode"		
echo "1.Install"
echo "2.Uninstall"
echo "3.Exit Setup"
read select
test $select = 3
do
case $select in
	1)
    echo "Begin Install"
	Install
	break;;
	2)
    echo "Begin Uninstall"
	Uninstall
	break;;
	3)
    echo "Exit Setup"
	exit;;
esac
done