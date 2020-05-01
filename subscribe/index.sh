#!/bin/sh
cd `dirname $0`
subs_path='/etc/v2ray/subs'
is_empty_dir(){ 
    return `ls -A $1|wc -w`
}

download_config() {
    if is_empty_dir ./conf
    then
        echo 'no configfile downloaded'
    else
        rm -f $subs_path/*.json
        mv -f ./conf/*.json $subs_path/
    fi
}

use_config() {
    configfile=`ls $subs_path/ | grep $1 | sort  -n | head -n 1`
    if [ ! -n "$configfile" ]; then
        echo "configfile not exists"
    fi
    
    if [ -n "$configfile" ]; then
        echo "Use $configfile"
        cp -f $subs_path/$configfile /etc/v2ray/config.json
        service v2ray stop
        service v2ray start
    fi
}

if [ "$#" = 0 ]; then
    download_config
    echo "Enter EndPoint:"
    read cfg
    if [ -n "$cfg" ]; then
        use_config $cfg
    fi
elif [ "$#" = 1 ] && [ "$1" = "-d" ]; then
    download_config
elif [ "$#" = 1 ] && [ "$1" = "-r" ]; then
    use_config "*.json"
elif [ "$#" = 1 ] && [ "$1" != "-h" ]; then
    use_config $1
else
    echo "Usage: $(basename "$0") -d"
    echo "Usage: $(basename "$0") -r"
    echo "Usage: $(basename "$0") {config_name}"
    echo "Usage: $(basename "$0") -h"
fi
