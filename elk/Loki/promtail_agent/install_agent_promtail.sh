#!/bin/bash

###########################################################
###########################################################

set -E
trap '[ "$?" -ne 77 ] ||  exit 77' ERR


SCRIPTDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

SHELL_PATH=${SCRIPTDIR}/
#PACKAGE_PATH="$(cd ${SHELL_PATH} && cd apps && pwd)"
#CONF_FILE="${SCRIPTDIR}/deepinsight.properties"
IP=$(hostname -I|tr " " "\n"|sed  -n '1p')
SDIR="/usr/local/promtail"

#echo ${SCRIPTDIR} \n ${IP}

function ERROR() {
    printf "$(tput setaf 1)[$(date '+%Y-%m-%d %H:%M:%S')] [ERROR] ✖ %s $(tput sgr0)\n" "$@"
}

function INFO() {
    printf "$(tput setaf 2)[$(date '+%Y-%m-%d %H:%M:%S')] [INFO] ➜ %s $(tput sgr0)\n" "$@"
}

function SUCCESS() {
    printf "$(tput setaf 3)[$(date '+%Y-%m-%d %H:%M:%S')] [SUCCESS] ✔ %s $(tput sgr0)\n" "$@"
}

function WARNING() {
    printf "$(tput setaf 5)[$(date '+%Y-%m-%d %H:%M:%S')] [WARNING] ➜ %s $(tput sgr0)\n" "$@"
}

function CHECK() {
    printf "$(tput setaf 3)[$(date '+%Y-%m-%d %H:%M:%S')] [CHECK] ✔ %s $(tput sgr0)\n" "$@"
}

# Check command
CHECK_CMD() {
    command -v "$1" >/dev/null 2>&1
}

###########################################################
#       initSystem
#   @Description:
###########################################################
function initSystem() {

    #if [ ! "$(grep -rn 'vm.swappiness' /etc/sysctl.conf)" ]; then
    #    echo 'vm.swappiness=10' >>/etc/sysctl.conf
    #    echo 'echo never > /sys/kernel/mm/transparent_hugepage/defrag' >>/etc/rc.local
    #    echo 'echo never > /sys/kernel/mm/transparent_hugepage/enabled' >>/etc/rc.local
    #fi
    INFO "Create uers of promtail"
    useradd --system --home /usr/local/promtail --shell /sbin/nologin promtail
    usermod -aG systemd-journal promtail
    usermod -a -G root promtail
    #setfacl -m u:promtail:rwx /var/log/
    #chmod o+r /var/log/*
}

function install() {
    #dirname=$1
    if [ ! -d ${SDIR} ]; then
        INFO "Create dir for promtail"
        mkdir -p ${SDIR}
    
        if [[ $(pgrep -f promtail >/dev/null) -ne 0 ]];then
        WARNING "promtail isaliveing...."
        fi
        
    	INFO "BBBBBBBBBBBBBBBBBBBBBB"
    	#sed -i "s/x.x.x.x/${IP}/g" ${SHELL_PATH}/promtail.yaml
   	cp ${SHELL_PATH}{promtail-linux-amd64,promtail.yaml} ${SDIR} 
    	sed -i "s/x.x.x.x/${IP}/g" ${SDIR}/promtail.yaml
    	cp ${SHELL_PATH}/promtail.service /usr/lib/systemd/system/ && chmod +x /usr/lib/systemd/system/promtail.service

    	chmod o+w /usr/local/promtail/ && chown promtail.promtail /usr/local/promtail/promtail.yaml

    	sudo systemctl daemon-reload && sudo systemctl enable --now promtail && sudo systemctl status promtail

    	setfacl -m u:promtail:rwx /var/log/*
   	chmod o+r /var/log/* 
        chmod o+w /usr/local/promtail/ 
    	getfacl /var/log/
    	systemctl restart promtail
        
  fi
}

function clear() {
    INFO "dell promtail PROC"
    systemctl daemon-reload && systemctl stop  promtail
    #ps -ef| grep "promtail"|awk '{system("kill -9 " $2)}'  >/dev/null 2>&1 
    rm -fr ${SDIR} ; ls -al ${SDIR} 
    rm -f /usr/lib/systemd/system/promtail.service
    userdel -r promtail
    INFO "CLEAL ALL....."
}

function main() {
    case $1 in
    install)
        initSystem
        install
        ;;
    dell)
        clear
        ;;
    *)
        echo "Useage: $0 install | dell"
        ;;
    esac

    return 0
}

main $@
