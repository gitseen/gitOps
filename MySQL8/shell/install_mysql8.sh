#!/bin/bash
set -E
#set -x
trap '[ "$?" -ne 77 ] ||  exit 77' ERR

###########################################################
#       settings
###########################################################
SCRIPTDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOGFILE=${SCRIPTDIR}/run.log

MySQLDB_SERVER_CONF_FILE="./CFG/my.cnf"
MYSQLDB_SERVER_PKG_DIR="./PKG"

ARGS1=$1
ARGS2=$2
ARGS3=$3

# mysql cfg
MYSQL_ROOT_PASS="asb#1234"
MYSQL_REMOTE_CONNECT=true
MYSQL_DATA_PATH=/var/lib/mysql
MYSQL_INSTALL_PATH=/usr/local/mysql
MYSQL_FILE=mysql-8.0.30-el7-x86_64
ZZJZ_DB_USER="zzjz"
ZZJZ_DB_PASSWD="wJ6tAgSqJidznI98esvA"

###########################################################
#       log function
#   @Description(描述):
###########################################################
function log() {
        echo -e "$(date +%Y-%m-%d_%H%M)" "$1" >>"${LOGFILE}"
        if [ "$2" != "noecho" ]; then
                echo -e "$1"
        fi
}

###########################################################
#       uninstallDB
#   @Description(描述):
###########################################################
function uninstallDB() {
        rpm -qa | grep mariadb | xargs rpm -e --nodeps
        rm -rf /var/log/mysql*
        rm -rf /var/lib/mysql*
        rm -rf /usr/local/mysql;rm -rf /usr/local/mysql-*
}

###########################################################
#       installMysql
#   @Description:
###########################################################
function installMysql() {
        # 检测是否安装 mysql
        #which mysql >/dev/null 2>&1
        #if [ $? -eq 0 ]; then
#               log "检测到已安装mysql数据库，跳过数据库安装"
#               return 0;
#       fi

        log "卸载mariadb-libs组件包"
        yum -y remove mariadb-libs.x86_64
        uninstallDB

        log "创建MySQL服务用户"
        if ! id mysql >/dev/null 2>&1; then
                groupadd -g 1200 mysql
                useradd -r -g mysql -u 1200 -s /sbin/nologin mysql
        fi

        log " 创建MySQL数据目录: ${MYSQL_DATA_PATH}"
        mkdir -p ${MYSQL_DATA_PATH}

        log "解压MySQL: ${MYSQL_FILE}.tar.gz"
        tar -xf ./PKG/${MYSQL_FILE}.tar.gz -C /usr/local/
        if [ $? -ne 0 ]; then
                ERROR '解压失败请检查安装包完整性'
                exit 1
        fi

        ln -s /usr/local/${MYSQL_FILE} /usr/local/mysql

        log "配置MySQL服务管理 systemd"
        cp ${MYSQL_INSTALL_PATH}/support-files/mysql.server /etc/init.d/mysqld.sh
        sed -i "s@^basedir=.*@basedir=${MYSQL_INSTALL_PATH}@" /etc/init.d/mysqld.sh
        sed -i "s@^datadir=.*@datadir=${MYSQL_INSTALL_PATH}@" /etc/init.d/mysqld.sh
        chmod +x /etc/init.d/mysqld.sh
        #chkconfig --add mysqld
        #chkconfig mysqld on

        log "创建环境变量"
        echo "export PATH=${MYSQL_INSTALL_PATH}/bin:\$PATH" >>/etc/profile
        . /etc/profile

        log "创建MySQL配置文件: /etc/my.cnf"
        cat >/etc/my.cnf <<EOF
[mysqld]
datadir=$MYSQL_DATA_PATH
socket=$MYSQL_DATA_PATH/mysql.sock
transaction-isolation = READ-COMMITTED
# Disabling symbolic-links is recommended to prevent assorted security risks;
# to do so, uncomment this line:
#symbolic-links = 0
key_buffer_size = 32M
max_allowed_packet = 32M
thread_stack = 256K
thread_cache_size = 64
#query_cache_limit = 8M
#query_cache_size = 64M
#query_cache_type = 1

max_connections = 3000
#expire_logs_days = 10
#max_binlog_size = 100M

#log_bin should be on a disk with enough free space.
#Replace '/var/lib/mysql/mysql_binary_log' with an appropriate path for your
#system and chown the specified folder to the mysql user.
log_bin=$MYSQL_DATA_PATH/mysql_binary_log

#In later versions of MySQL, if you enable the binary log and do not set
#a server_id, MySQL will not start. The server_id must be unique within
#the replicating group.
server_id=1
binlog_format = mixed
read_buffer_size = 2M
read_rnd_buffer_size = 16M
sort_buffer_size = 8M
join_buffer_size = 8M

# InnoDB settings
innodb_file_per_table = 1
innodb_flush_log_at_trx_commit  = 2
innodb_log_buffer_size = 64M
innodb_buffer_pool_size = 4G
innodb_thread_concurrency = 8
innodb_flush_method = O_DIRECT
innodb_log_file_size = 512M
#sql_mode=STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION,NO_ZERO_DATE,NO_ZERO_IN_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER
sql_mode=STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTIO
explicit_defaults_for_timestamp=1

[mysqld_safe]
log-error=/var/log/mysqld.log
pid-file=${MYSQL_DATA_PATH}/mysqld.pid

[client]
socket=${MYSQL_DATA_PATH}/mysql.sock
EOF

        log "初始化MySQL"
        chmod 600 /etc/my.cnf
        chown mysql.mysql -R ${MYSQL_DATA_PATH}
#       ${MYSQL_INSTALL_PATH}/bin/mysqld --defaults-file=/etc/my.cnf --initialize-insecure --user=mysql \
#               --basedir=${MYSQL_INSTALL_PATH} --datadir=${MYSQL_DATA_PATH} >/dev/null 2>&1
        ${MYSQL_INSTALL_PATH}/bin/mysqld --defaults-file=/etc/my.cnf --initialize-insecure --user=mysql \
               --basedir=${MYSQL_INSTALL_PATH} --datadir=${MYSQL_DATA_PATH} --console


        log "启动MySQL服务"
        cat >/usr/lib/systemd/system/mysqld.service<<EOF
[Unit]
Description=mysqld
#After=network.target remote-fs.target nss-lookup.target
After=rc-local.service

[Service]
Type=forking
ExecStart=/etc/init.d/mysqld.sh start
ExecReload=/etc/init.d/mysqld.sh restart
ExecStop=/etc/init.d/mysqld.sh stop
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF
        chmod +x /usr/lib/systemd/system/mysqld.service
        systemctl daemon-reload && systemctl enable mysqld && systemctl start mysqld

        log "设置MySQL密码"
        #mysql -e "grant all privileges on *.* to root@'127.0.0.1' identified by \"${MYSQL_ROOT_PASS}\" with grant option;"
        #mysql -e "grant all privileges on *.* to root@'localhost' identified by \"${MYSQL_ROOT_PASS}\" with grant option;"
        #mysql -uroot -p${MYSQL_ROOT_PASS} -e "show databases;"
        mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY 'asb#1234' PASSWORD EXPIRE NEVER;"
        mysql -uroot -p${MYSQL_ROOT_PASS} -e "CREATE USER 'root'@'%' IDENTIFIED BY 'asb#1234' PASSWORD EXPIRE NEVER;"
        mysql -uroot -p${MYSQL_ROOT_PASS} -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;"
        mysql -uroot -p${MYSQL_ROOT_PASS} -e "ALTER USER 'root'@'%' IDENTIFIED WITH mysql_native_password BY 'asb#1234' PASSWORD EXPIRE NEVER;"

        #if [ "${MYSQL_REMOTE_CONNECT}" == 'true' ]; then
        #       log "启用MySQL root用户远程登入"
        #       mysql -uroot -p${MYSQL_ROOT_PASS} -e "grant all privileges on *.* to root@'%' identified by \"${MYSQL_ROOT_PASS}\" with grant option;"
        #fi
}

###########################################################
#       grantUserPrivileges
#   @Description:
###########################################################
function grantUserPrivileges
{
        log "设置zzjz服务远程访问Mysql权限"
        mysql -h${ARGS1} -uroot -p${ARGS2} -e "grant all privileges on *.* to zzdevops@'%' identified by \"${ZZJZ_DB_PASSWD}\" with grant option;"
        mysql -h${ARGS1} -uroot -p${ARGS2} -e "grant all privileges on *.* to zzdevops@'localhost' identified by \"${ZZJZ_DB_PASSWD}\" with grant option;"
        DI_HOST_NAME=`hostname`
        mysql -h${ARGS1} -uroot -p${ARGS2} -e "grant all privileges on *.* to zzdevops@\"${DI_HOST_NAME}\" identified by \"${ZZJZ_DB_PASSWD}\" with grant option;"

        log "查看当前用户信息"
        mysql -h${ARGS1} -uroot -p${ARGS2} -e "SELECT DISTINCT CONCAT('User: ''',user,'''@''',host,''';') AS query FROM mysql.user;"
}

###########################################################
#       main
#   @Description(描述):
###########################################################
function main() {
        currentUser=$(whoami)
        [ $currentUser = "root" ] || (log "ERROR: PLZ USE ROOT !" && exit 77)

        cd ${SCRIPTDIR}

        if [ $ARGS3 == "db" ]; then
                installMysql
        fi

#       grantUserPrivileges

}

main $@

###############
# rpm -qa |grep mysql|xargs rpm -e  --nodeps
# rm -rf /var/lib/mysql/*
###############

