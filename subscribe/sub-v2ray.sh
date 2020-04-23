#!/bin/sh
decode()
{   # accept pipe data
    rep=$(tr - + | tr _ /)
    case "$((${#rep} % 4))" in
        2) rep="$rep==" ;;
        3) rep="$rep=" ;;
        *) ;;
    esac
    echo "$rep">temp
    base64 -d temp
    rm -f temp
}
parse_json()
{
    rep=$(tr - -)
    value=`echo $rep | sed 's/.*"'$1'":\([^,}]*\).*/\1/'`
    echo $value \
    | sed 's/^"//g' \
    | sed 's/"$//g' \
    | sed 's/\\\//\//g' \
    | sed 's/\\\"/\"/g'
}
escape()
{
    rep=$(tr - -)
    echo $rep \
    | sed 's/\\/\\\\/g' \
    | sed 's/\//\\\//g' \
    | sed 's/\./\\\./g' \
    | sed 's/\$/\\\$/g' \
    | sed 's/\^/\\\^/g' \
    | sed 's/\*/\\\*/g' \
    | sed 's/\[/\\\[/g' \
    | sed 's/\]/\\\]/g'
}
unescape()
{
    rep=$(tr - -)
    echo $rep \
    | sed 's/\\\\/\\/g' \
    | sed 's/\\\//\//g' \
    | sed 's/\\\./\./g' \
    | sed 's/\\\$/\$/g' \
    | sed 's/\\\^/\^/g' \
    | sed 's/\\\*/\*/g' \
    | sed 's/\\\[/\[/g' \
    | sed 's/\\\]/\]/g'
}

template="v2ray-template.json"
v2ray_config_output="/etc/v2ray/subs"
decode_protocol_link()
{
    link="$1"
    info="$(echo "${link#*://}" | decode)"
    case "${link%%:*}" in
        vmess)
            echo $info
            j=$info
            j_add=`echo $j | parse_json add | escape`
            j_host=`echo $j | parse_json host | escape`
            j_id=`echo $j | parse_json id | escape`
            j_net=`echo $j | parse_json net | escape`
            j_path=`echo $j | parse_json path | escape`
            j_port=`echo $j | parse_json port | escape`
            j_ps=`echo $j | parse_json ps | escape`
            j_tls=`echo $j | parse_json tls | escape`
            j_v=`echo $j | parse_json v | escape`
            j_aid=`echo $j | parse_json aid | escape`
            j_type=`echo $j | parse_json type | escape`
            j_name=`echo "$j_add" | unescape` #`echo $j_add | sed 's/\..*//g'`
            if [ ! -d "$v2ray_config_output" ]; then
                mkdir -p $v2ray_config_output
            fi
            cat $template \
            | sed 's/\$add/'$j_add'/g' \
            | sed 's/\$host/'$j_host'/g' \
            | sed 's/\$id/'$j_id'/g' \
            | sed 's/\$net/'$j_net'/g' \
            | sed 's/\$path/'$j_path'/g' \
            | sed 's/\$port/'$j_port'/g' \
            | sed 's/\$ps/'$j_ps'/g' \
            | sed 's/\$tls/'$j_tls'/g' \
            | sed 's/\$v/'$j_v'/g' \
            | sed 's/\$aid/'$j_aid'/g' \
            | sed 's/\$type/'$j_type'/g' > ${v2ray_config_output}/${j_name}.json
        ;;
        http|https)
            curl $link | decode | while read -r line
            do
                decode_protocol_link "$line"
            done
        ;;
        *)
            for possible_link in $info; do
                decode_protocol_link "$possible_link"
            done
        ;;
    esac
}

if [ "$#" = 0 ]; then
   while read -r url; do
       decode_protocol_link "$url"
   done
elif [ "$#" = 1 ] && [ "$1" != "-h" ]; then
    decode_protocol_link "$1"
else
    echo "Usage: $(basename "$0") link"
    echo "       $(basename "$0") < link.txt"
    echo
    echo "Supported format for <link>:"
    echo "    http(s):// subscription link, or downloaded content therein"
    echo "    vmess:// v2ray encoded config"
fi


