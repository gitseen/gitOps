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



```
