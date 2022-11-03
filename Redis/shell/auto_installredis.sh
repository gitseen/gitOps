#!/bin/bash

#redis5-befroe Ok

#redss6 
#yum install centos-release-scl
#yum install devtoolset-7-gcc*
#scl enable devtoolset-7 bash
#source /opt/rh/devtoolset-7/enable
#gcc -v

#reis7
#yum install cpp
#yum install binutils
#yum install glibc
#yum install glibc-kernheaders
#yum install glibc-common
#yum install glibc-devel
#yum install gcc
#yum install make
#yum -y install centos-release-scl
#yum -y install devtoolset-9-gcc devtoolset-9-gcc-c++ devtoolset-9-binutils
#scl enable devtoolset-9 bash
#source /opt/rh/devtoolset-9/enable
#echo "source /opt/rh/devtoolset-9/enable" >>/etc/profile
###########################################################
#安装Redis：
###########################################################

set -E
trap '[ "$?" -ne 77 ] ||  exit 77' ERR

###########################################################
#       path
###########################################################

SCRIPTDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE=${SCRIPTDIR}/$(basename $0).log
JMX_CONFIG=$SCRIPTDIR/bin/test.jmx
DI_IP=$(hostname -I|tr " " "\n"|sed  -n '1p')

###########################################################
#    输出样式 function
#   @Description(描述):
###########################################################
function EEROR() {
    printf "$(tput setaf 1)[$(date '+%Y-%m-%d %H:%M:%S')] [ERROR] ✖ %s $(tput sgr0)\n" "$@"
}

function INFO() {
    printf "$(tput setaf 2)[$(date '+%Y-%m-%d %H:%M:%S')] [INFO] ➜ %s $(tput sgr0)\n" "$@"
}

function RUN() {
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
#       log function
#   @Description(描述):
###########################################################
function log() {
    echo -e "$(date +%Y-%m-%d_%H%M)" "$1" >>"${LOG_FILE}"
    if [ "$2" != "noecho" ]; then
        echo -e "$1"
    fi
}
###########################################################
#       Redis install
###########################################################

. /etc/init.d/functions
#设置redis版本，密码，安装目录，端口号
VERSION=redis-5.0.7
#VERSION=redis-6.0.16
#VERSION=redis-6.0.7
PASSWORD=123456
INSTALL_DIR=/usr/local/redis
DEFAULT_PORT=6379
#如果只要安装单个redis,设置为0就行
DSL_NUM=1
#如网络质量不好可以自行去官网下载，然后删除下面#wget https://download.redis.io/releases/${VERSION}.tar.gz || { action "源码包下载失败" false;exit; }#这句话
#redis版本下载官网:https://download.redis.io/releases/?_ga=2.164994486.889360285.1614915959-1081687905.1611193410

redis_install() {
yum install -y gcc jemalloc-devel -q || { action "安装依赖失败" false;exit; }
wget https://download.redis.io/releases/${VERSION}.tar.gz || { action "源码包下载失败" false;exit; }
tar xf ${VERSION}.tar.gz
cd ${VERSION}
#make PREFIX=${INSTALL_DIR}/${DEFAULT_PORT}/ install && action "redis 编译完成" || { action "redis 编译失败" false;exit; }
source /opt/rh/devtoolset-7/enable 
gcc -v
make PREFIX=${INSTALL_DIR}/${DEFAULT_PORT}/ install && action "redis 编译完成" || { action "redis 编译失败" false;exit; }
mkdir -p ${INSTALL_DIR}/${DEFAULT_PORT}/{etc,log,data,run}
cp redis.conf ${INSTALL_DIR}/${DEFAULT_PORT}/etc/redis-${DEFAULT_PORT}.conf
cp sentinel.conf ${INSTALL_DIR}/${DEFAULT_PORT}/etc/redis-${DEFAULT_PORT}-sentinel.conf
if id redis &>/dev/null;then
        action "redis 用户已经存在" false
else
        useradd -r -s /sbin/nologin redis
        action "redis 用户创建成功"
fi
cat >> /etc/sysctl.conf <<EOF
net.core.somaxconn = 1024
vm.overcommit_memory = 1
EOF
sysctl -p
echo "echo never > /sys/kernel/mm/transparent_hugepage/enabled">>/etc/rc.d/rc.local
chmod +x /etc/rc.d/rc.local
ln -s ${INSTALL_DIR}/${DEFAULT_PORT}/bin/redis-* /usr/bin/
cp src/redis-trib.rb /usr/bin/
}
dsl_install() {
sed -ri -e "/^bind 127.0.0.1/c bind 0.0.0.0"  -e "/# requirepass/a requirepass $PASSWORD"  -e "/^dir .*/c dir ${INSTALL_DIR}/${DEFAULT_PORT}/data/"  -e "/logfile .*/c logfile ${INSTALL_DIR}/${DEFAULT_PORT}/log/redis-${DEFAULT_PORT}.log" -e "/^dbfilename dump.rdb$/c dbfilename dump-${DEFAULT_PORT}.rdb" -e  "/^pidfile .*/c  pidfile ${INSTALL_DIR}/${DEFAULT_PORT}/run/redis-${DEFAULT_PORT}.pid" -e "/^appendonly no$/c appendonly yes" ${INSTALL_DIR}/${DEFAULT_PORT}/etc/redis-${DEFAULT_PORT}.conf
cat > /usr/lib/systemd/system/redis${DEFAULT_PORT}.service <<EOF
[Unit]
Description=Redis persistent key-value database
After=network.target
[Service]
ExecStart=${INSTALL_DIR}/${DEFAULT_PORT}/bin/redis-server ${INSTALL_DIR}/${DEFAULT_PORT}/etc/redis-${DEFAULT_PORT}.conf --supervised systemd
ExecStop=/bin/kill -s QUIT $MAINPID
Type=notify
User=redis
Group=redis
RuntimeDirectory=redis
RuntimeDirectoryMode=0755
[Install]
WantedBy=multi-user.target
EOF
if [ "$DSL_NUM" -gt 0 ];then
        for i in `seq $DSL_NUM` ;do
                let i=${DEFAULT_PORT}+i
                mkdir ${INSTALL_DIR}/${i}/{bin,etc,log,data,run} -p
                cp ${INSTALL_DIR}/${DEFAULT_PORT}/bin/* ${INSTALL_DIR}/${i}/bin/
                sed "s/${DEFAULT_PORT}/${i}/g"  ${INSTALL_DIR}/${DEFAULT_PORT}/etc/redis-${DEFAULT_PORT}.conf >${INSTALL_DIR}/${i}/etc/redis-${i}.conf
                sed "s/${DEFAULT_PORT}/${i}/g" /usr/lib/systemd/system/redis${DEFAULT_PORT}.service >/usr/lib/systemd/system/redis${i}.service
                cp ${INSTALL_DIR}/${DEFAULT_PORT}/etc/redis-${DEFAULT_PORT}-sentinel.conf ${INSTALL_DIR}/${i}/etc/redis-${i}-sentinel.conf
        done
        chown redis.redis -R ${INSTALL_DIR}
        systemctl daemon-reload
        [ $? -eq 0 ] &&action "${DSL_NUM}个$VERSION创建成功,请查看$INSTALL_DIR目录" ||  { action "redis 实例创建失败" false;exit; }
elif    [ "$DSL_NUM" -eq 0 ];then
        chown redis.redis -R ${INSTALL_DIR}
        systemctl daemon-reload
        [ $? -eq 0 ] &&action "单个$VERSION创建成功,请查看$INSTALL_DIR目录" ||  { action "单个redis创建失败" false;exit; }
else
        continue;
fi
}
redis_install
dsl_install
##from https://blog.csdn.net/DLWH_HWLD/article/details/119812990
