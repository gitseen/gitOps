#!/bin/bash
#-----------------------------------------------------------------------------#
#    Copyright @Shanghai Zhizhen JunZhi Technology Co.,Ltd.  2014-2022. All rights reserved.
#                    版权所有 (C), 2014-2022, 上海直真君智科技有限公司
#
#    Description: CDH6.3.2 一键安装
#    Author: x1
#    Version:： v1.0
#    CreateTime: 2022/03/15
#-----------------------------------------------------------------------------#
#. /etc/profile
###########################################################
# 主入口：
###########################################################

set -E
trap '[ "$?" -ne 77 ] ||  exit 77' ERR

###########################################################
#       settings ENV
###########################################################
#sed -i 's/$OLDIP/$NEWIP/g' /etc/sysconfig/network-scripts/ifcfg-eth0
#systemctl restart network && #reboot
OLDIP=$1
NEWIP=$2
SCRIPTDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOGFILE=${SCRIPTDIR}/exec.log
SDIR="/etc/kubernetes"

###########################################################
#    输出样式 function
#   @Description(描述):
###########################################################
ERROR() {
    printf "$(tput setaf 1)[$(date '+%Y-%m-%d %H:%M:%S')] [ERROR] ✖ %s $(tput sgr0)\n" "$@"
}

INFO() {
    printf "$(tput setaf 2)[$(date '+%Y-%m-%d %H:%M:%S')] [INFO] ➜ %s $(tput sgr0)\n" "$@"
}

SUCCESS() {
    printf "$(tput setaf 3)[$(date '+%Y-%m-%d %H:%M:%S')] [SUCCESS] ✔ %s $(tput sgr0)\n" "$@"
}

WARNING() {
    printf "$(tput setaf 5)[$(date '+%Y-%m-%d %H:%M:%S')] [WARNING] ➜ %s $(tput sgr0)\n" "$@"
}

CHECK() {
    printf "$(tput setaf 3)[$(date '+%Y-%m-%d %H:%M:%S')] [CHECK] ✔ %s $(tput sgr0)\n" "$@"
}

# Check command
CHECK_CMD() {
    command -v "$1" >/dev/null 2>&1
}

log() {
    echo -e "$(date +%Y-%m-%d_%H%M)" "$1" >>"${LOGFILE}"
    if [ "$2" != "noecho" ]; then
        echo -e "$1"
    fi
}

###########################################################
#   change_k8s_ip function
#   @Description(描述):
###########################################################
change_k8s_ip(){

#change_hosts
echo $OLDIP
echo $NEWIP
sed -i "s/$OLDIP/$NEWIP/g" /etc/hosts
log "k8s-hosts-list: \n$(cat /etc/hosts|awk 'NR>2' |awk '{print $0}')"

#change_ip_k8s_cluster
sed -i 's/$OLDIP/$NEWIP/' /etc/exports
exportfs -arv
grep -rl "$OLDIP" /data/nfs_data/config/k8sConfig/|xargs sed -i 's/$OLDIP/$NEWIP/g'
cp -Rf $SDIR{,.bef} && cd $SDIR
find . -type f | xargs sed -i "s/$OLDIP/$NEWIP/"
#change_pod
#kubectl -n kube-system get cm kubeadm-config -o yaml | sed -i 's/$OLDIP/$NEWIP/'
#kubectl -n kube-system get cm kube-proxy -o yaml | sed -i 's/$OLDIP/$NEWIP/'

#change_ip_ELK
sed -i 's/$OLDIP/$NEWIP/g' /opt/logstash-6.8.0/config/logstash.conf
sed -i 's/$OLDIP/$NEWIP/g' /opt/kibana-6.8.0-linux-x86_64/config/kibana.yml
sed -i 's/$OLDIP/$NEWIP/g' /opt/logstash-6.8.0/config/logstash.conf
#change_rulemanage
grep -rl 's/$OLDIP/$NEWIP/g' /opt/ruleknowledgemanagement |xargs sed -i 's/$OLDIP/$NEWIP/g'
#change_nginx
grep -rl 's/$OLDIP/$NEWIP/g' /usr/local/openresty/nginx/conf/ |xargs sed -i 's/$OLDIP/$NEWIP/g'
nginx -s reload
#find . -type f | xargs grep "$NEWIP"
grep -rl "$NEWIP" ./

#识别pki中以旧的IP地址作为alt name的证书
cd $SDIR/pki
for f in $(find -name "*.crt"); do openssl x509 -in $f -text -noout > $f.txt; done
grep -Rl $OLDIP .
for f in $(find -name "*.crt"); do  \rm $f.txt; done
#生成api etcd证书i(kubeadm init phase certs all)
\rm  apiserver.crt apiserver.key && kubeadm init phase certs apiserver
if [[ ! $? -eq 0 ]]; then
        log "ERROR: kubeadm init phase certs apiserver. please check..."
        exit 2
fi
\rm etcd/peer.crt etcd/peer.key && kubeadm init phase certs etcd-peer
if [[ ! $? -eq 0 ]];then
        log "ERROR: kubeadm init phase certs etcd-peer. please check..."
        exit 3
fi
#可以全部重新生成: kubeadm init phase certs all
#生成新的 kubeconfig文件
cd $SDIR
\rm -f admin.conf kubelet.conf controller-manager.conf scheduler.conf
kubeadm init phase kubeconfig all
if [[ ! $? -eq 0 ]]; then
        log "ERROR: kubeadm init phase kubeconfig all. please check..."
        exit 3
fi
\cp /etc/kubernetes/admin.conf $HOME/.kube/config
systemctl restart docker && systemctl restart kubelet
sleep 6
log "======================cluster-nodes-status========================"
kubectl get nodes
log  " "
log "======================k8s kube-system status======================" 
kubectl get po -n kube-system
sleep 2 
log "======================cluster-cs-status==========================="
kubectl get cs && kubectl get ep -A

WARNING " 当前已完成XYJX平台IP修改操作
          需手动操作如下
          1编辑kubectl -n kube-system edit cm kubeadm-config 找到旧IP修改成新IP
          2编辑kubectl -n kube-system edit cm kube-proxy     找到旧IP修改成新IP
          3运行systemctl status docker.service && systemctl status kubelet.service
          4编辑vim /etc/exports配置文件中修改需要挂载nfs的IP "
log "$OLDIP"
log "==================="
log "$NEWIP"
kubectl -n kube-system get cm kubeadm-config -o yaml | sed -i "s/$OLDIP/$NEWIP/g"
kubectl -n kube-system get cm kube-proxy -o yaml | sed -i "s/$OLDIP/$NEWIP/g"
}

###########################################################
#   show_help function
#   @Description(描述):
###########################################################
show_help() {
    echo -e "\033[33m提示：确认当前主机网卡IP是否已修改后可执行"$0"脚本 \033[0m"
    echo -e "\033[33m请输入修改K8S集群参数:  \033[0m"
    echo -e "\033[33m参数1：原K8S集群IP \033[0m"
    echo -e "\033[33m参数2：新K8S集群IP \033[0m"
    echo -e "\033[33m例如: sh $0  192.168.11.11 192.168.11.12 \033[0m"
    #ERROR "AAAAAAAAAA"
    #INFO  "BBBBBBBBBB"
    #SUCCESS "CCCCCCCCCC"
    #WARNING "DDDDDDDDDDDD"

}

###########################################################
#       main
#   @Description: proc-in
###########################################################
main() {

    if [ $UID -ne 0 ]; then
        echo Non root user. Please run as root.
        exit 0
    fi


    if [ $# -lt 2 ]; then
        show_help
        return 0
    fi
    ###
    #if [[ $# -ne 2 ]];then
    #    echo -e "\033[33mUsage: sh $0 masterip node1ip node2ip  \033[0m"
    #    exit 0
    #fi
    change_k8s_ip
    return 0
}

main $@
