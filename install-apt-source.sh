#!/bin/sh
configure
set system package repository stretch components 'main contrib non-free'
set system package repository stretch distribution stretch
set system package repository stretch url http://mirrors.huaweicloud.com/debian
commit
save
exit

apt-get update

# configure
# delete system package repository stretch
# commit
# save
# exit
