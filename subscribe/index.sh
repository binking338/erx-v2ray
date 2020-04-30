#!/bin/sh
cd `dirname $0`
rm -f /etc/v2ray/subs/*.json
# ./sub-v2ray.sh https://www.mlycc.com/modules/servers/V2raySocks/subscribe/\?sid\=37637\&token\=uqIiT1DPLNzc
./sub-v2ray.sh https://xxoo.men/link/SSyCYfJ8YOCetwrW?mu=2

if [ "$#" = 0 ]; then
    echo "Enter EndPoint:"
    read p
    configfile=`ls /etc/v2ray/subs/ | grep $p | sort  -n | head -n 1`
    if [ ! -n "$configfile" ]; then
        configfile=`ls /etc/v2ray/subs/ | sort  -n | head -n 1`
    fi
    cp -f /etc/v2ray/subs/$configfile /etc/v2ray/config.json
    echo "Use $configfile"
    service v2ray stop
    service v2ray start
elif [ "$#" = 1 ] && [ "$1" = "-r" ]; then
    configfile=`ls /etc/v2ray/subs/ | sort  -n | head -n 1`
    cp -f /etc/v2ray/subs/$configfile /etc/v2ray/config.json
    echo "Use $configfile"
    service v2ray stop
    service v2ray start
elif [ "$#" = 1 ] && [ "$1" != "-h" ]; then
    configfile=`ls /etc/v2ray/subs/ | grep $1 | sort  -n | head -n 1`
    cp -f /etc/v2ray/subs/$configfile /etc/v2ray/config.json
    echo "Use $configfile"
    service v2ray stop
    service v2ray start
else
    echo "Usage: $(basename "$0") [Endpoint]"
    echo "Usage: $(basename "$0") -r"
    echo "Usage: $(basename "$0") -h"
fi
