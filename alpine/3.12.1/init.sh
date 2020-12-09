#!/bin/bash

COUNTRY=$(curl -s ipinfo.io | jq .country)

if [[ ${COUNTRY} == "\"CN\"" ]];then
    sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories
else
    sed -i 's/mirrors.ustc.edu.cn/dl-cdn.alpinelinux.org/g' /etc/apk/repositories
fi
