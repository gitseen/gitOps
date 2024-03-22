# shell
600条最强Linux命令总结  https://www.toutiao.com/article/7249559687354974759

shell中的printf vs echo到底哪个更好用  https://m.toutiao.com/is/yYEuL17/

退出shell脚本的正确姿势与最佳实践 https://m.toutiao.com/is/y8GoQSX/


# shell常用日志输出
```bash
###########################################################
#       log function
#   @Description(描述):
###########################################################
log() {
    echo -e "$(date +%Y-%m-%d_%H%M)" "$1" >>"${LOGFILE}"
    if [ "$2" != "noecho" ]; then
        echo -e "$1"
    fi
}

#log(){
# echo -e >&1 "INFO: ${1:-$(</dev/stdin)}"
#}
#form: https://www.coder.work/article/2569352
#from: https://tiscs.choral.io/notes/k8s-cluster/


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
    printf "$(tput setaf 3)[$(date '+%Y-%m-%d %H:%M:G%S')] [SUCCESS] ✔ %s $(tput sgr0)\n" "$@"
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



log "AAAAAA"
ERROR "AA"
WARNING "BB"



color () {
    RES_COL=60
    MOVE_TO_COL="echo -en \\033[${RES_COL}G"
    SETCOLOR_SUCCESS="echo -en \\033[1;32m"
    SETCOLOR_FAILURE="echo -en \\033[1;31m"
    SETCOLOR_WARNING="echo -en \\033[1;33m"
    SETCOLOR_NORMAL="echo -en \E[0m"
    echo -n "$1" && $MOVE_TO_COL
    echo -n "["
    if [ $2 = "success" -o $2 = "0" ] ;then
        ${SETCOLOR_SUCCESS}
        echo -n $"  OK  "   
    elif [ $2 = "failure" -o $2 = "1"  ] ;then
        ${SETCOLOR_FAILURE}
        echo -n $"FAILED"
    else
        ${SETCOLOR_WARNING}
        echo -n $"WARNING"
    fi
    ${SETCOLOR_NORMAL}
    echo -n "]"
    echo
}
 
check () {
    if [ $ID = 'ubuntu' -a ${VERSION_ID} = "20.04"  ];then
        true
    else
        color "不支持此操作系统，退出!" 1
        exit
    fi
}
```
