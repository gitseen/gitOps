# MySQL8.0.[13、31]主从部署

## 一、MySQL8主从复制原理  

MySQL的主从复制中主要有三个线程: master(binlog dump thread)、slave(I/O thread 、SQL thread)

- master服务器将数据的改变记入二进制binlog日志,当master上的数据发生改变时,则将其改变写入二进制日志中  

- slave服务器会在一定时间间隔内对master二进制日志进行探测其是否发生改变,如果发生改变,则开始一个I/OThread请求master二进制事件   

- 同时主节点为每个I/O线程启动一个dump线程,用于向其发送二进制事件,并保存至从节点本地的中继日志中;从节点启动SQL线程从中继日志中读取二进制日志,在本地重放,使得其数据和主节点的保持一致;最后I/OThread和SQLThread将进入睡眠状态,等待下一次被唤醒     

## 二、MySQL8主从部署

**环境信息**  
|  NAME     |      Ip   |    port    | 
| --------- | :-------: | :--------: | 
| MySQL-Master | 26.64.60.1 | 13306  | 
| MySQL-Slave  | 26.64.60.2 | 13306  |


1、MySQL8安装  
```bash
#下载https://dev.mysql.com/downloads/mysql
#mysql-8.0.13-linux-glibc2.12-x86_64.tar.xz安装包
mysql_base_dir="/data/mysql"       #mysql家目录
mysql_data_dir="/data/mysql/data"  #mysql家目录
yum install -y ncurses-compat-libs-6.1-9.20180224.el8.x86_64  libaio-devel

useradd -s /sbin/nologin  mysql  &&  chown -R mysql ${mysql_data_dir}

#${mysql_base_dir}/bin/mysqld --console  --datadir=${mysql_data_dir} --initialize-insecure --user=mysql
bin/mysqld --defaults-file=/data/mysql/my.cnf  --initialize-insecure --user=mysql --basedir=/data/mysql  --datadir=/data/mysql/data


#Add auto-mysqld-services
cat >/usr/lib/systemd/system/mysqld.service <<EOF
[Unit]
Description=MYSQL server
After=network.target

[Service]
Type=forking
TimeoutSec=0
PermissionsStartOnly=true
ExecStart=/data/mysql/bin/mysqld --defaults-file=/data/mysql/my.cnf --daemonize $OPTIONS
ExecReload=/bin/kill -HUP -$MAINPID
ExecStop=/bin/kill -QUIT $MAINPID
KillMode=process
LimitNOFILE=65535
Restart=on-failure
RestartSec=10
RestartPreventExitStatus=1
PrivateTmp=false

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload  &&   systemctl enable --now  mysqld
export PATH=$PATH:/data/mysql/bin

#启动后空code
mysqladmin -uroot  password  'SnT_oPs#2024inkKRD'
#SHOW GLOBAL VARIABLES LIKE "%lower%";   #检查不区分大小写是否为1
#update user set password=PASSWORD("SnT_oPs#2024inkKRD")where user="root";
#update user set password=password("SnT_oPs#2024inkKRD") where user='root' and host='localhost';
#flush privileges;

mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY 'SnT_oPs#2024inkKRD' PASSWORD EXPIRE NEVER;"
CREATE USER 'root'@'%' IDENTIFIED BY 'SnT_oPs#2024inkKRD';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;
ALTER USER 'root'@'%' IDENTIFIED WITH mysql_native_password BY 'SnT_oPs#2024inkKRD' PASSWORD EXPIRE NEVER;
#mysql -uroot -pSnT_oPs#2024inkKRD -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;"
#mysql -uroot -pSnT_oPs#2024inkKRD  -e "ALTER USER 'root'@'%' IDENTIFIED WITH mysql_native_password BY 'SnT_oPs#2024inkKRD' PASSWORD EXPIRE NEVER;"
```

>由于mysql8以上的版本会区分表名大小写,所以添加这个lower_case_table_names参数,不会区分大小写,可以避免很多问题!    


2、 MySQL8主从配置  

2.1 Master上配置slave同步账号(ip和账号为Slave节点)
```bash
create user 'repl'@'26.64.60.2' identified by 'sNt_repl@2MySQL';
#grant replication slave,replication client on *.* to 'slave'@'%';
grant replication slave,replication client on *.* to 'repl'@'26.64.60.2';
grant all on *.* to 'repl'@'26.64.60.2' with grant option;
flush privileges;  #刷新权限
show grants for 'repl'@'26.64.60.2';  #查看用户权限
select host,user from mysql.user;
show master status;
show plugins;

#查MySQL主服务Binlog Dump线程
mysql -uroot -pSnT_oPs#2024inkKRD -e "show processlist" |grep "Binlog Dump" 

mysql: [Warning] Using a password on the command line interface can be insecure.
8601	repl	26.64.60.2:54250	NULL	Binlog Dump	85482	Master has sent all binlog to slave; waiting for more updates	NULL
```

2.2 Slave上配置master同步binlog及pos点位  
```bash
#change master to master_host='26.64.60.1',master_port=13306,master_user='repl',master_password='sNt_repl@2MySQL',master_log_file='mysql-bin.00003',master_log_pos=0;
change master to master_host='26.64.60.1',master_port=13306,master_user='repl',master_password='sNt_repl@2MySQL',master_log_file='mysql-bin.000003',master_log_pos=155;
start slave;
show slave status \G
show processlist; 

mysql -uroot -pSnT_oPs#2024inkKRD  -e "show slave status\G" |grep -E "Slave_IO_Running|Slave_SQL_Running|Seconds_Behind_Master|Exec_Master_Log_Pos" #主从同步状态
```

>网络测试  
Last_IO_Error: error connecting to master 'repl@26.64.60.1:13306' - retry-time: 60  retries: 3  
mysql -h26.64.60.1 -P13306 -urepl -psNt_repl@2MySQL #测试连通性  


3、 MySQL8配置文件my.ccnf  
```bash
#master-my.cnf
[mysqld]
user=mysql
port = 13306
socket = /tmp/mysql.sock
datadir = /mysql/mysql/data
character-set-server=utf8
server-id = 1
max_connections = 10000
group_concat_max_len = 102400
max_connect_errors = 10
table_open_cache = 4096
event_scheduler = ON
skip_name_resolve = ON
lower_case_table_names = 1
max_allowed_packet = 64M
binlog_cache_size = 32M
max_heap_table_size = 256M
read_rnd_buffer_size = 64M
sort_buffer_size = 256M
join_buffer_size = 512M
thread_cache_size = 300
log_bin_trust_function_creators=1
key_buffer_size = 256M
read_buffer_size = 32M
read_rnd_buffer_size = 128M
bulk_insert_buffer_size = 512M
sql_mode=NO_ENGINE_SUBSTITUTION,STRICT_TRANS_TABLES
#READ-UNCOMMITTED, READ-COMMITTED, REPEATABLE-READ, SERIALIZABLE
transaction_isolation = READ-COMMITTED
tmp_table_size = 512M
log-bin=mysql-bin
binlog_format=mixed
sync_binlog = 1
binlog_expire_logs_seconds = 604800  #expire_logs_days = 7
max_binlog_size = 256M
binlog_group_commit_sync_delay = 100
#binlog-do-db = xxl  #指定同步
slow_query_log = 1
slow_query_log_file = /mysql/mysql/logs/slow.log
long_query_time = 5

####### InnoDB
innodb_buffer_pool_size = 512M
innodb_thread_concurrency = 16
innodb_flush_log_at_trx_commit = 2
innodb_log_buffer_size = 32M
innodb_log_file_size = 1024M
innodb_log_files_in_group = 4
innodb_max_dirty_pages_pct = 90
innodb_lock_wait_timeout = 120
#innodb_force_recovery=1

[mysqldump]
quick
max_allowed_packet = 64M

[mysql]
no-auto-rehash

[myisamchk]
key_buffer = 16M
sort_buffer_size = 16M
read_buffer = 8M
write_buffer = 8M

[mysqlhotcopy]
interactive-timeout

[mysqld_safe]
open-files-limit = 65535
log-error=/mysql/mysql/logs/mysqld.log
pid-file=/mysql/mysql/logs/mysqld.pid


----
#Slave-my.cnf
[mysqld]
user=mysql
port = 13306
socket = /tmp/mysql.sock
datadir = /mysql/mysql/data
character-set-server = utf8
server-id = 2
max_connections = 10000
group_concat_max_len = 102400
max_connect_errors = 10
table_open_cache = 4096
event_scheduler = ON
lower_case_table_names = 1
max_allowed_packet = 64M
binlog_cache_size = 32M
max_heap_table_size = 256M
read_rnd_buffer_size = 64M
sort_buffer_size = 256M
join_buffer_size = 512M
thread_cache_size = 300
log_bin_trust_function_creators=1
key_buffer_size = 256M
read_buffer_size = 32M
read_rnd_buffer_size = 128M
bulk_insert_buffer_size = 512M
sql_mode=NO_ENGINE_SUBSTITUTION,STRICT_TRANS_TABLES
#READ-UNCOMMITTED, READ-COMMITTED, REPEATABLE-READ, SERIALIZABLE
transaction_isolation = READ-COMMITTED
tmp_table_size = 512M
log-bin=mysql-slave-bin
binlog_format=mixed
binlog_expire_logs_seconds = 604800  #expire_logs_days = 7
log-error = /mysql/mysql/logs/mysql-error.log  #error LOG
general_log = 1
general_log_file = /mysql/mysql/logs/mysql-query.log #query LOG
slow_query_log = 1
slow_query_log_file = /mysql/mysql/logs/mysql-slow.log
long_query_time = 5
sync_binlog = 0
relay_log = ylw-mysql-relay-bin
relay_log_info_file = /mysql/mysql/logs/mysql-relay-log.info
relay_log_purge = ON
relay_log_recovery = ON
read_only = ON
#replicate-do-db = xxl
replicate-ignore-db = mysql,sys,information_schema,performance_schema
log_slave_updates = ON
slave_skip_errors = all
slave_net_timeout = 60
skip_name_resolve = ON
slave_parallel_workers = 8
slave_parallel_type = LOGICAL_CLOCK
slave_preserve_commit_order = 1

####### InnoDB
innodb_buffer_pool_size = 512M
innodb_thread_concurrency = 16
innodb_flush_log_at_trx_commit = 2
innodb_log_buffer_size = 32M
innodb_log_file_size = 1024M
innodb_log_files_in_group = 4
innodb_max_dirty_pages_pct = 90
innodb_lock_wait_timeout = 120
#innodb_force_recovery=1

[mysqldump]
quick
max_allowed_packet = 64M
[client]
character-set-server = utf8mb4
[mysql]
no-auto-rehash

[myisamchk]
key_buffer = 16M
sort_buffer_size = 16M
read_buffer = 8M
write_buffer = 8M

[mysqlhotcopy]
interactive-timeout

[mysqld_safe]
open-files-limit = 65535
```

4、MySQL8常用指令  
```bash
#1、MySQL字符集
配置my.cnf添加参数及验证
character-set-server = utf8mb4         #show variables like 'character_set%';
collation-server = utf8mb4_unicode_ci  #show variables like 'collation%';

create  database ecology character set utf8mb4 collate utf8mb4_unicode_ci; 

#2、MySQL变量查询
mysql -uroot -pSnT_oPs#2024inkKRD  -e "show variables like '%log%';"
mysql -uroot -pSnT_oPs#2024inkKRD  -e "show variables like 'slave_skip_errors';"
select * from sys.schema_table_lock_waits;
select * from sys.metrics where variable_name like 'slave%delay%';


#3、MySQL锁表备份解锁
show engines; #存储引擎 MyISAM使用--lock-all-tables  InnoDB使用--single-transaction

flush tables with read lock;  #show variables like '%lock%';
set global read_only = ON;    #show variables like '%read_only%';

mysqldump -uroot -pSnT_oPs#2024inkKRD -A --master-data=2 --single-transaction --routines --triggers --flush-logs --events --all-databases   > all.sql
mysqldump -uroot -pSnT_oPs#2024inkKRD -q --single-transaction --flush-logs -E -R  --triggers -B performance_check > all.sql
mysqldump -uroot -pSnT_oPs#2024inkKRD -q --default-character-set=utf8mb4 --single-transaction --compress --flush-logs -E -R  --triggers -B ecology > all.sql #-B和--no-create-db互斥 

unlock tables;
set global read_only = OFF;

#MySQL导入数据库报错问题："MySQL8使用mysqldump导出后导入数据库报错Unknown command '\''. " #系统识别\为命令,使用系统字符来解决如：LANG=en_US.UTF-8


#4、MySQL主从同步日志
mysqlbinlog -v mysql-bin.000005  测试binlog日志



#5、MySQL中查数据库大小与表大小

#MySQL中查数据库大小
use mysql;
SELECT table_schema "ecology",sum(data_length + index_length) / 1024 / 1024 /1024 "Size(GB)" from information_schema.TABLES GROUP BY table_schema; 


#mysql中查数据库表的大小
use mysql;
SELECT 
    table_name AS 'cc',
    ROUND(data_length/1024/1024/1024, 2) AS '数据大小(MB)',
    ROUND(index_length/1024/1024/1024, 2) AS '索引大小(MB)',
    ROUND((data_length + index_length)/1024/1024/1024, 2) AS '总大小(GB)',
    table_rows AS '行数'
FROM 
    information_schema.tables
WHERE 
    table_schema = 'ecology'
ORDER BY 
    (data_length + index_length) DESC;
```



See https://www.toutiao.com/article/7189143834964656643/  for xx



---

## 三、环境介绍  

2023-01-16 15:09·潇洒sword  
MySQL8.0.31主从复制配置(单机环境下的一主两从架构)

 
通过在单机环境下三个不同的目录和端口3306、3307、3308来搭建。

3、系统准备  

```
a、查看系统版本  

# more /etc/redhat-release  

CentOS Linux release 7.9.2009 (Core)  

b、关闭防火墙  

systemctl stop firewalld.service 或者 systemctl stop firewalld  

systemctl disable firewalld.service 或者 systemctl disable firewalld  

systemctl status firewalld  

c、关闭selinux

getenforce

setenforce 0

vim /etc/selinux/config

SELINUX=disabled

d、/etc/hosts解析

e、配置yum源，安装依赖rpm包

yum -y groupinstall "DeveLopment tools"

yum -y install ncurses ncurses-devel openssl-devel bison gcc gcc-c++ make

f、清理系统环境

Linux7版本的系统默认自带安装了MariaDB，需要先清理。

## 查询已安装的mariadb

rpm -qa |grep mariadb

或

yum list installed | grep mariadb

## 卸载mariadb包，文件名为上述命令查询出来的文件

rpm -e --nodeps mariadb-libs-5.5.60-1.el7_5.x86_64

yum -y remove mariadb-libs.x86_64
```

4、安装MySQL数据库
```
a、root用户操作创建目录

mkdir -p /usr/local/mysql/

mkdir -p /usr/local/mysql/conf

mkdir -p /usr/local/mysql/mysql3306/data/

mkdir -p /usr/local/mysql/mysql3306/pid/

mkdir -p /usr/local/mysql/mysql3306/socket/

mkdir -p /usr/local/mysql/mysql3306/log/

mkdir -p /usr/local/mysql/mysql3306/binlog/

mkdir -p /usr/local/mysql/mysql3306/relaylog/

mkdir -p /usr/local/mysql/mysql3306/slowlog/

mkdir -p /usr/local/mysql/mysql3306/tmp/



mkdir -p /usr/local/mysql/mysql3307

mkdir -p /usr/local/mysql/mysql3307/data/

mkdir -p /usr/local/mysql/mysql3307/pid/

mkdir -p /usr/local/mysql/mysql3307/socket/

mkdir -p /usr/local/mysql/mysql3307/log/

mkdir -p /usr/local/mysql/mysql3307/binlog/

mkdir -p /usr/local/mysql/mysql3307/relaylog/

mkdir -p /usr/local/mysql/mysql3307/slowlog/

mkdir -p /usr/local/mysql/mysql3307/tmp/



mkdir -p /usr/local/mysql/mysql3308/

mkdir -p /usr/local/mysql/mysql3308/data/

mkdir -p /usr/local/mysql/mysql3308/pid/

mkdir -p /usr/local/mysql/mysql3308/socket/

mkdir -p /usr/local/mysql/mysql3308/log/

mkdir -p /usr/local/mysql/mysql3308/binlog/

mkdir -p /usr/local/mysql/mysql3308/relaylog/

mkdir -p /usr/local/mysql/mysql3308/slowlog/

mkdir -p /usr/local/mysql/mysql3308/tmp/

b、创建数据库用户和组

groupadd mysql

useradd -g mysql mysql

chown -R mysql:mysql /mysql

passwd mysql

c、上传解压安装包并重命名

mysql用户操作：

cd /usr/local/

md5sum
mysql-8.0.31-linux-glibc2.12-x86_64.tar.xz --检验 MD5 值和官方网站一致说明软件未被修改。

tar xvf mysql-8.0.31-linux-glibc2.12-x86_64.tar.xz

mv mysql-8.0.31-linux-glibc2.12-x86_64 mysql8.0.31

d、配置 mysql 用户环境变量

vim ~/.bash_profile

MYSQL_HOME=/usr/local/mysql8.0.31

PATH=$PATH:$HOME/.local/bin:$HOME/bin:$MYSQL_HOME/bin

source ~/.bash_profile

which mysql

5、创建参数文件

由于是二进制文件安装，数据库参数文件需要自己配置，以下是简单的参数配置。

其他参数可依照个人需求添加。

vim my3306.cnf

[mysqld]

# basic settings #

server_id = 863306

basedir = /usr/local/mysql8.0.31

datadir = /usr/local/mysql/mysql3306/data/

socket = /usr/local/mysql/mysql3306/socket/mysql3306.sock

pid_file = /usr/local/mysql/mysql3306/pid/mysqld3306.pid

port = 3306

default-time_zone = '+8:00'

character_set_server = utf8mb4

explicit_defaults_for_timestamp = 1

autocommit = 1

transaction_isolation = READ-COMMITTED

secure_file_priv = "/usr/local/mysql/mysql3306/tmp/"

max_allowed_packet = 64M

lower_case_table_names = 1

default_authentication_plugin = mysql_native_password

sql_mode = 'STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION'



# connection #

back_log = 500

interactive_timeout = 300

wait_timeout = 300

lock_wait_timeout = 300

max_user_connections = 800

skip_name_resolve = 1

max_connections = 3000

max_connect_errors = 1000



#table cache performance settings

#table_open_cache = 1024

#table_definition_cache = 1024

#table_open_cache_instances = 16



#session memory settings #

#read_buffer_size = 16M

#read_rnd_buffer_size = 32M

#sort_buffer_size = 32M

#tmp_table_size = 64M

#join_buffer_size = 128M

#thread_cache_size = 256



# log settings #

slow_query_log = ON

slow_query_log_file = /usr/local/mysql/mysql3306/slowlog/slow3306.log

log_error = /usr/local/mysql/mysql3306/log/mysqld3306.log

log_error_verbosity = 3

log_bin = /usr/local/mysql/mysql3306/binlog/mysql_bin

log_bin_index = /usr/local/mysql/mysql3306/binlog/mysql_binlog.index

# general_log_file = /usr/local/mysql/mysql57_3306/generallog/general.log

log_queries_not_using_indexes = 1

log_slow_admin_statements = 1

#log_slow_slave_statements = 1

#expire_logs_days = 15

binlog_expire_logs_seconds = 2592000

long_query_time = 2

min_examined_row_limit = 100

log_throttle_queries_not_using_indexes = 1000

#log_bin_trust_function_creators = 1

log_slave_updates = 1

mysqlx_port = 33060

mysqlx_socket = /usr/local/mysql/mysql3306/socket/mysqlx.sock



# innodb settings #

innodb_buffer_pool_size = 512M

#innodb_buffer_pool_instances = 16

innodb_log_buffer_size = 100M

innodb_buffer_pool_load_at_startup = 1

innodb_buffer_pool_dump_at_shutdown = 1

innodb_lru_scan_depth = 4096

innodb_lock_wait_timeout = 20

innodb_io_capacity = 5000

innodb_io_capacity_max = 10000

innodb_flush_method = O_DIRECT

innodb_log_file_size = 1G

innodb_log_files_in_group = 2

innodb_purge_threads = 4

innodb_thread_concurrency = 200

innodb_print_all_deadlocks = 1

innodb_strict_mode = 1

innodb_sort_buffer_size = 32M

innodb_write_io_threads = 16

innodb_read_io_threads = 16

innodb_file_per_table = 1

innodb_stats_persistent_sample_pages = 64

innodb_autoinc_lock_mode = 2

innodb_online_alter_log_max_size = 1G

innodb_open_files = 4096

innodb_buffer_pool_dump_pct = 25

innodb_page_cleaners = 16

innodb_undo_log_truncate = 1

innodb_max_undo_log_size = 2G

innodb_purge_rseg_truncate_frequency = 128

innodb_flush_log_at_trx_commit = 1



# replication settings #

master_info_repository = TABLE

relay_log_info_repository = TABLE

sync_binlog = 1

binlog_format = ROW

gtid_mode = ON

enforce_gtid_consistency = ON

relay_log_recovery = 1

relay_log = /usr/local/mysql/mysql3306/relaylog/relay.log

relay_log_index = /usr/local/mysql/mysql3306/relaylog/mysql_relay.index

slave_parallel_type = LOGICAL_CLOCK

slave_parallel_workers = 16

binlog_gtid_simple_recovery = 1

slave_preserve_commit_order = 1

binlog_rows_query_log_events = 1

slave_transaction_retries = 10

log_timestamps = system

report_host = 172.16.90.10

report_port = 3306

--report_host复制副本注册期间要报告给源库的复制副本的主机名或IP地址。

此值显示在源服务器上显示副本的输出中。如果不希望复制副本向源注册，请将该值保留为未设置。

其他两节点参数文件 my3307.cnf、my3308.cnf中将上述文件中的 3306 全部替换为 3307、3308 即可。

6、数据库初始化

mysql 用户操作，注意同主机参数文件名 my3306.cnf?各不相同，间隔约两分钟分别初始化三个 MySQL 实例。?

[root@MongoDB data]# mysqld --defaults-file=/usr/local/mysql/conf/my3306.cnf --initialize --user=mysql --basedir=/usr/local/mysql --datadir=/usr/local/mysql/mysql3306/data

[root@MongoDB data]# mysqld --defaults-file=/usr/local/mysql/conf/my3307.cnf --initialize --user=mysql --basedir=/usr/local/mysql --datadir=/usr/local/mysql/mysql3307/data

[root@MongoDB data]# mysqld --defaults-file=/usr/local/mysql/conf/my3308.cnf --initialize --user=mysql --basedir=/usr/local/mysql --datadir=/usr/local/mysql/mysql3308/data

[root@MongoDB data]#

7、启动三个数据库实例

[root@MongoDB data]# mysqld_safe --defaults-file=/usr/local/mysql/conf/my3306.cnf --user=mysql &

[1] 14888

[root@MongoDB data]# 2023-01-13T09:07:30.093437Z mysqld_safe Logging to '/usr/local/mysql/mysql3306/log/mysqld3306.log'.

2023-01-13T09:07:30.116360Z mysqld_safe Starting mysqld daemon with databases from /usr/local/mysql/mysql3306/data

[root@MongoDB data]# mysqld_safe --defaults-file=/usr/local/mysql/conf/my3307.cnf --user=mysql &

[2] 16075

[root@MongoDB data]# 2023-01-13T09:07:38.635738Z mysqld_safe Logging to '/usr/local/mysql/mysql3307/log/mysqld3307.log'.

2023-01-13T09:07:38.657100Z mysqld_safe Starting mysqld daemon with databases from /usr/local/mysql/mysql3307/data

[root@MongoDB data]#

[root@MongoDB data]# mysqld_safe --defaults-file=/usr/local/mysql/conf/my3308.cnf --user=mysql &

[3] 17531

[root@MongoDB data]# 2023-01-13T09:07:43.190806Z mysqld_safe Logging to '/usr/local/mysql/mysql3308/log/mysqld3308.log'.

2023-01-13T09:07:43.212370Z mysqld_safe Starting mysqld daemon with databases from /usr/local/mysql/mysql3308/data

[root@MongoDB data]#

[root@MongoDB data]#

[root@MongoDB data]# ps -ef |grep mysql

root 14888 30844 0 17:07 pts/0 00:00:00 /bin/sh /usr/local/mysql/bin/mysqld_safe --defaults-file=/usr/local/mysql/conf/my3306.cnf --user=mysql

mysql 15999 14888 7 17:07 pts/0 00:00:02 /usr/local/mysql/bin/mysqld --defaults-file=/usr/local/mysql/conf/my3306.cnf --basedir=/usr/local/mysql --datadir=/usr/local/mysql/mysql3306/data --plugin-dir=/usr/local/mysql/lib/plugin --user=mysql --log-error=/usr/local/mysql/mysql3306/log/mysqld3306.log --pid-file=/usr/local/mysql/mysql3306/pid/mysqld3306.pid --socket=/usr/local/mysql/mysql3306/socket/mysql3306.sock --port=3306

root 16075 30844 0 17:07 pts/0 00:00:00 /bin/sh /usr/local/mysql/bin/mysqld_safe --defaults-file=/usr/local/mysql/conf/my3307.cnf --user=mysql

mysql 17471 16075 12 17:07 pts/0 00:00:02 /usr/local/mysql/bin/mysqld --defaults-file=/usr/local/mysql/conf/my3307.cnf --basedir=/usr/local/mysql8.0.31 --datadir=/usr/local/mysql/mysql3307/data --plugin-dir=/usr/local/mysql/lib/plugin --user=mysql --log-error=/usr/local/mysql/mysql3307/log/mysqld3307.log --pid-file=/usr/local/mysql/mysql3307/pid/mysqld3307.pid --socket=/usr/local/mysql/mysql3307/socket/mysq3307.sock --port=3307

root 17531 30844 0 17:07 pts/0 00:00:00 /bin/sh /usr/local/mysql/bin/mysqld_safe --defaults-file=/usr/local/mysql/conf/my3308.cnf --user=mysql

mysql 18641 17531 14 17:07 pts/0 00:00:01 /usr/local/mysql/bin/mysqld --defaults-file=/usr/local/mysql/conf/my3308.cnf --basedir=/usr/local/mysql8.0.31 --datadir=/usr/local/mysql/mysql3308/data --plugin-dir=/usr/local/mysql/lib/plugin --user=mysql --log-error=/usr/local/mysql/mysql3308/log/mysqld3308.log --pid-file=/usr/local/mysql/mysql3308/pid/mysqld3308.pid --socket=/usr/local/mysql/mysql3308/socket/mysq3308.sock --port=3308

[root@MongoDB data]#

8、查看初始化root密码并修改

[root@MongoDB data]# more /usr/local/mysql/mysql3306/log/mysqld3306.log|grep password

2023-01-13T17:04:10.726444+08:00 0 [Note] [MY-010309] [Server] Auto generated RSA key files through --sha256_password_auto_generate_rsa_keys are placed in data directory.

2023-01-13T17:04:10.726469+08:00 0 [Note] [MY-010308] [Server] Skipping generation of RSA key pair through --caching_sha2_password_auto_generate_rsa_keys as key files are present in data directory.

2023-01-13T17:04:10.727595+08:00 6 [Note] [MY-010454] [Server] A temporary password is generated for root@localhost: nZ%*8,pZ=Gz7

2023-01-13T17:07:36.078915+08:00 0 [Note] [MY-010308] [Server] Skipping generation of RSA key pair through --sha256_password_auto_generate_rsa_keys as key files are present in data directory.

2023-01-13T17:07:36.078929+08:00 0 [Note] [MY-010308] [Server] Skipping generation of RSA key pair through --caching_sha2_password_auto_generate_rsa_keys as key files are present in data directory.

[root@MongoDB data]# more /usr/local/mysql/mysql3307/log/mysqld3307.log|grep password

2023-01-13T17:05:54.406475+08:00 0 [Note] [MY-010309] [Server] Auto generated RSA key files through --sha256_password_auto_generate_rsa_keys are placed in data directory.

2023-01-13T17:05:54.406498+08:00 0 [Note] [MY-010308] [Server] Skipping generation of RSA key pair through --caching_sha2_password_auto_generate_rsa_keys as key files are present in data directory.

2023-01-13T17:05:54.407574+08:00 6 [Note] [MY-010454] [Server] A temporary password is generated for root@localhost: *jw,Ko#6p>R(

2023-01-13T17:07:45.249704+08:00 0 [Note] [MY-010308] [Server] Skipping generation of RSA key pair through --sha256_password_auto_generate_rsa_keys as key files are present in data directory.

2023-01-13T17:07:45.249713+08:00 0 [Note] [MY-010308] [Server] Skipping generation of RSA key pair through --caching_sha2_password_auto_generate_rsa_keys as key files are present in data directory.

[root@MongoDB data]# more /usr/local/mysql/mysql3308/log/mysqld3308.log|grep password

2023-01-13T17:06:50.478139+08:00 0 [Note] [MY-010309] [Server] Auto generated RSA key files through --sha256_password_auto_generate_rsa_keys are placed in data directory.

2023-01-13T17:06:50.478160+08:00 0 [Note] [MY-010308] [Server] Skipping generation of RSA key pair through --caching_sha2_password_auto_generate_rsa_keys as key files are present in data directory.

2023-01-13T17:06:50.479228+08:00 6 [Note] [MY-010454] [Server] A temporary password is generated for root@localhost: V.QRzK>hd9:o

2023-01-13T17:07:49.095543+08:00 0 [Note] [MY-010308] [Server] Skipping generation of RSA key pair through --sha256_password_auto_generate_rsa_keys as key files are present in data directory.

2023-01-13T17:07:49.095551+08:00 0 [Note] [MY-010308] [Server] Skipping generation of RSA key pair through --caching_sha2_password_auto_generate_rsa_keys as key files are present in data directory.

[root@MongoDB data]#

[root@MongoDB data]# mysql -uroot -p -P 3306 -S /usr/local/mysql/mysql3306/socket/mysql3306.sock

[root@MongoDB data]# mysql -uroot -p -P 3307 -S /usr/local/mysql/mysql3307/socket/mysql3307.sock

[root@MongoDB data]# mysql -uroot -p -P 3308 -S /usr/local/mysql/mysql3308/socket/mysql3308.sock

从数据库3306端口

[root@MongoDB data]# mysql -uroot -p -P 3306 -S /usr/local/mysql/mysql3306/socket/mysql3306.sock

Enter password:

Welcome to the MySQL monitor. Commands end with ; or \g.

Your MySQL connection id is 8

Server version: 8.0.31

Copyright (c) 2000, 2022, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its

affiliates. Other names may be trademarks of their respective

owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> alter user root@'localhost' identified by 'root'; 修改用户root密码

Query OK, 0 rows affected (0.20 sec)

mysql> create user root@'%' identified by 'root'; 修改用户root可以任意地址连接

Query OK, 0 rows affected (0.06 sec)

mysql> grant all privileges on *.* to root@'%' with grant option; 修改权限

Query OK, 0 rows affected (0.04 sec)

mysql> \q

Bye

从数据库3307端口

[root@MongoDB data]# mysql -uroot -p -P 3307 -S /usr/local/mysql/mysql3307/socket/mysql3307.sock

Enter password:

Welcome to the MySQL monitor. Commands end with ; or \g.

Your MySQL connection id is 8

Server version: 8.0.31

Copyright (c) 2000, 2022, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its

affiliates. Other names may be trademarks of their respective

owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> alter user root@'localhost' identified by 'root';

Query OK, 0 rows affected (0.06 sec)

mysql> create user root@'%' identified by 'root';

Query OK, 0 rows affected (0.04 sec)

mysql> grant all privileges on *.* to root@'%' with grant option;

Query OK, 0 rows affected (0.06 sec)

mysql> \q

Bye

从数据库3308端口

[root@MongoDB data]# mysql -uroot -p -P 3308 -S /usr/local/mysql/mysql3308/socket/mysql3308.sock

Enter password:

Welcome to the MySQL monitor. Commands end with ; or \g.

Your MySQL connection id is 8

Server version: 8.0.31

Copyright (c) 2000, 2022, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its

affiliates. Other names may be trademarks of their respective

owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> alter user root@'localhost' identified by 'root';

Query OK, 0 rows affected (0.04 sec)

mysql> create user root@'%' identified by 'root';

Query OK, 0 rows affected (0.04 sec)

mysql> grant all privileges on *.* to root@'%' with grant option;

Query OK, 0 rows affected (0.05 sec)

mysql> \q

Bye

[root@MongoDB data]#
```
三、构建主从环境  
```
1、主库 3306 创建复制账号 rep  

[root@MongoDB data]# mysql -uroot -p -P 3306 -S /usr/local/mysql/mysql3306/socket/mysql3306.sock

Enter password:

Welcome to the MySQL monitor. Commands end with ; or \g.

Your MySQL connection id is 9

Server version: 8.0.31 MySQL Community Server - GPL

Copyright (c) 2000, 2022, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its

affiliates. Other names may be trademarks of their respective

owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> create user rep@'%' identified by 'rep';

Query OK, 0 rows affected (0.10 sec)

mysql> grant REPLICATION CLIENT,REPLICATION SLAVE on *.* to rep@'%';

Query OK, 0 rows affected (0.05 sec)

mysql> show master status;

+------------------+----------+--------------+------------------+------------------------------------------+

| File | Position | Binlog_Do_DB | Binlog_Ignore_DB | Executed_Gtid_Set |

+------------------+----------+--------------+------------------+------------------------------------------+

| mysql_bin.000002 | 1486 | | | 367eca03-9321-11ed-bf75-005056b3a8d0:1-5 |

+------------------+----------+--------------+------------------+------------------------------------------+

1 row in set (0.00 sec)

mysql>

我这里需要置空 gtid 信息。

mysql> reset master;

Query OK, 0 rows affected (0.20 sec)

mysql> show master status;

+------------------+----------+--------------+------------------+-------------------+

| File | Position | Binlog_Do_DB | Binlog_Ignore_DB | Executed_Gtid_Set |

+------------------+----------+--------------+------------------+-------------------+

| mysql_bin.000001 | 157 | | | |

+------------------+----------+--------------+------------------+-------------------+

1 row in set (0.00 sec)

mysql>

2、快速构建主从

1）登录3307

[root@MongoDB data]# mysql -uroot -p -P 3307 -S /usr/local/mysql/mysql3307/socket/mysql3307.sock

Enter password:

Welcome to the MySQL monitor. Commands end with ; or \g.

Your MySQL connection id is 9

Server version: 8.0.31 MySQL Community Server - GPL

Copyright (c) 2000, 2022, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its

affiliates. Other names may be trademarks of their respective

owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> change master to master_host='172.16.90.10',master_port=3306,master_user='rep',master_password='rep',master_auto_position=1;

Query OK, 0 rows affected, 8 warnings (0.36 sec)

mysql> show slave status\G

*************************** 1. row ***************************

Slave_IO_State:

Master_Host: 172.16.90.10

Master_User: rep

Master_Port: 3306

Connect_Retry: 60

Master_Log_File:

Read_Master_Log_Pos: 4

Relay_Log_File: relay.000001

Relay_Log_Pos: 4

Relay_Master_Log_File:

Slave_IO_Running: No

Slave_SQL_Running: No

Replicate_Do_DB:

Replicate_Ignore_DB:

Replicate_Do_Table:

Replicate_Ignore_Table:

Replicate_Wild_Do_Table:

Replicate_Wild_Ignore_Table:

Last_Errno: 0

Last_Error:

Skip_Counter: 0

Exec_Master_Log_Pos: 0

Relay_Log_Space: 157

Until_Condition: None

Until_Log_File:

Until_Log_Pos: 0

Master_SSL_Allowed: No

Master_SSL_CA_File:

Master_SSL_CA_Path:

Master_SSL_Cert:

Master_SSL_Cipher:

Master_SSL_Key:

Seconds_Behind_Master: NULL

Master_SSL_Verify_Server_Cert: No

Last_IO_Errno: 0

Last_IO_Error:

Last_SQL_Errno: 0

Last_SQL_Error:

Replicate_Ignore_Server_Ids:

Master_Server_Id: 0

Master_UUID:

Master_Info_File: mysql.slave_master_info

SQL_Delay: 0

SQL_Remaining_Delay: NULL

Slave_SQL_Running_State:

Master_Retry_Count: 86400

Master_Bind:

Last_IO_Error_Timestamp:

Last_SQL_Error_Timestamp:

Master_SSL_Crl:

Master_SSL_Crlpath:

Retrieved_Gtid_Set:

Executed_Gtid_Set: 74b9b8c1-9321-11ed-85dc-005056b3a8d0:1-3

Auto_Position: 1

Replicate_Rewrite_DB:

Channel_Name:

Master_TLS_Version:

Master_public_key_path:

Get_master_public_key: 0

Network_Namespace:

1 row in set, 1 warning (0.00 sec)

mysql> start slave;

Query OK, 0 rows affected, 1 warning (0.28 sec)

mysql> show slave status\G

*************************** 1. row ***************************

Slave_IO_State: Waiting for source to send event

Master_Host: 172.16.90.10

Master_User: rep

Master_Port: 3306

Connect_Retry: 60

Master_Log_File: mysql_bin.000001

Read_Master_Log_Pos: 157

Relay_Log_File: relay.000003

Relay_Log_Pos: 373

Relay_Master_Log_File: mysql_bin.000001

Slave_IO_Running: Yes

Slave_SQL_Running: Yes

Replicate_Do_DB:

Replicate_Ignore_DB:

Replicate_Do_Table:

Replicate_Ignore_Table:

Replicate_Wild_Do_Table:

Replicate_Wild_Ignore_Table:

Last_Errno: 0

Last_Error:

Skip_Counter: 0

Exec_Master_Log_Pos: 157

Relay_Log_Space: 730

Until_Condition: None

Until_Log_File:

Until_Log_Pos: 0

Master_SSL_Allowed: No

Master_SSL_CA_File:

Master_SSL_CA_Path:

Master_SSL_Cert:

Master_SSL_Cipher:

Master_SSL_Key:

Seconds_Behind_Master: 0

Master_SSL_Verify_Server_Cert: No

Last_IO_Errno: 0

Last_IO_Error:

Last_SQL_Errno: 0

Last_SQL_Error:

Replicate_Ignore_Server_Ids:

Master_Server_Id: 863306

Master_UUID: 367eca03-9321-11ed-bf75-005056b3a8d0

Master_Info_File: mysql.slave_master_info

SQL_Delay: 0

SQL_Remaining_Delay: NULL

Slave_SQL_Running_State: Replica has read all relay log; waiting for more updates

Master_Retry_Count: 86400

Master_Bind:

Last_IO_Error_Timestamp:

Last_SQL_Error_Timestamp:

Master_SSL_Crl:

Master_SSL_Crlpath:

Retrieved_Gtid_Set:

Executed_Gtid_Set: 74b9b8c1-9321-11ed-85dc-005056b3a8d0:1-3

Auto_Position: 1

Replicate_Rewrite_DB:

Channel_Name:

Master_TLS_Version:

Master_public_key_path:

Get_master_public_key: 0

Network_Namespace:

1 row in set, 1 warning (0.00 sec)

mysql>

[root@MongoDB data]# mysql -uroot -p -P 3308 -S /usr/local/mysql/mysql3308/socket/mysql3308.sock

Enter password:

Welcome to the MySQL monitor. Commands end with ; or \g.

Your MySQL connection id is 9

Server version: 8.0.31 MySQL Community Server - GPL

Copyright (c) 2000, 2022, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its

affiliates. Other names may be trademarks of their respective

owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> \s

--------------

mysql Ver 8.0.31 for Linux on x86_64 (MySQL Community Server - GPL)

Connection id: 9

Current database:

Current user: root@localhost

SSL: Not in use

Current pager: stdout

Using outfile: ''

Using delimiter: ;

Server version: 8.0.31 MySQL Community Server - GPL

Protocol version: 10

Connection: Localhost via UNIX socket

Server characterset: utf8mb4

Db characterset: utf8mb4

Client characterset: utf8mb4

Conn. characterset: utf8mb4

UNIX socket: /usr/local/mysql/mysql3308/socket/mysql3308.sock

Binary data as: Hexadecimal

Uptime: 12 min 7 sec

Threads: 2 Questions: 10 Slow queries: 0 Opens: 149 Flush tables: 3 Open tables: 65 Queries per second avg: 0.013

--------------

mysql> change master to master_host='172.16.90.10',master_port=3306,master_user='rep',master_password='rep',master_auto_position=1;

Query OK, 0 rows affected, 8 warnings (0.37 sec)

mysql> start slave;

Query OK, 0 rows affected, 1 warning (0.17 sec)

mysql> show slave status\G

*************************** 1. row ***************************

Slave_IO_State: Waiting for source to send event

Master_Host: 172.16.90.10

Master_User: rep

Master_Port: 3306

Connect_Retry: 60

Master_Log_File: mysql_bin.000001

Read_Master_Log_Pos: 157

Relay_Log_File: relay.000002

Relay_Log_Pos: 373

Relay_Master_Log_File: mysql_bin.000001

Slave_IO_Running: Yes

Slave_SQL_Running: Yes

Replicate_Do_DB:

Replicate_Ignore_DB:

Replicate_Do_Table:

Replicate_Ignore_Table:

Replicate_Wild_Do_Table:

Replicate_Wild_Ignore_Table:

Last_Errno: 0

Last_Error:

Skip_Counter: 0

Exec_Master_Log_Pos: 157

Relay_Log_Space: 573

Until_Condition: None

Until_Log_File:

Until_Log_Pos: 0

Master_SSL_Allowed: No

Master_SSL_CA_File:

Master_SSL_CA_Path:

Master_SSL_Cert:

Master_SSL_Cipher:

Master_SSL_Key:

Seconds_Behind_Master: 0

Master_SSL_Verify_Server_Cert: No

Last_IO_Errno: 0

Last_IO_Error:

Last_SQL_Errno: 0

Last_SQL_Error:

Replicate_Ignore_Server_Ids:

Master_Server_Id: 863306

Master_UUID: 367eca03-9321-11ed-bf75-005056b3a8d0

Master_Info_File: mysql.slave_master_info

SQL_Delay: 0

SQL_Remaining_Delay: NULL

Slave_SQL_Running_State: Replica has read all relay log; waiting for more updates

Master_Retry_Count: 86400

Master_Bind:

Last_IO_Error_Timestamp:

Last_SQL_Error_Timestamp:

Master_SSL_Crl:

Master_SSL_Crlpath:

Retrieved_Gtid_Set:

Executed_Gtid_Set: 9691ccb3-9321-11ed-8d09-005056b3a8d0:1-3

Auto_Position: 1

Replicate_Rewrite_DB:

Channel_Name:

Master_TLS_Version:

Master_public_key_path:

Get_master_public_key: 0

Network_Namespace:

1 row in set, 1 warning (0.00 sec)

mysql>

登录主库 3306 查看

[root@MongoDB data]# mysql -uroot -p -P 3306 -S /usr/local/mysql/mysql3306/socket/mysql3306.sock

Enter password:

Welcome to the MySQL monitor. Commands end with ; or \g.

Your MySQL connection id is 13

Server version: 8.0.31 MySQL Community Server - GPL

Copyright (c) 2000, 2022, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its

affiliates. Other names may be trademarks of their respective

owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> show slave hosts;

+-----------+--------------+------+-----------+--------------------------------------+

| Server_id | Host | Port | Master_id | Slave_UUID |

+-----------+--------------+------+-----------+--------------------------------------+

| 863308 | 172.16.90.10 | 3308 | 863306 | 9691ccb3-9321-11ed-8d09-005056b3a8d0 |

| 863307 | 172.16.90.10 | 3307 | 863306 | 74b9b8c1-9321-11ed-85dc-005056b3a8d0 |

+-----------+--------------+------+-----------+--------------------------------------+

2 rows in set, 1 warning (0.00 sec)

mysql>

mysql> show processlist;

+----+-----------------+--------------------+------+------------------+------+-----------------------------------------------------------------+------------------+

| Id | User | Host | db | Command | Time | State | Info |

+----+-----------------+--------------------+------+------------------+------+-----------------------------------------------------------------+------------------+

| 5 | event_scheduler | localhost | NULL | Daemon | 826 | Waiting on empty queue | NULL |

| 11 | rep | 172.16.90.10:36728 | NULL | Binlog Dump GTID | 164 | Source has sent all binlog to replica; waiting for more updates | NULL |

| 12 | rep | 172.16.90.10:36730 | NULL | Binlog Dump GTID | 69 | Source has sent all binlog to replica; waiting for more updates | NULL |

| 13 | root | localhost | NULL | Query | 0 | init | show processlist |

+----+-----------------+--------------------+------+------------------+------+-----------------------------------------------------------------+------------------+

4 rows in set (0.00 sec)

mysql>

两从库分别修改参数限制只读模式

mysql> show variables like '%read_only%';

+-----------------------+-------+

| Variable_name | Value |

+-----------------------+-------+

| innodb_read_only | OFF |

| read_only | OFF |

| super_read_only | OFF |

| transaction_read_only | OFF |

+-----------------------+-------+

4 rows in set (0.01 sec)

mysql> set global read_only=1;

Query OK, 0 rows affected (0.00 sec)

mysql> set global super_read_only=1;

Query OK, 0 rows affected (0.00 sec)

mysql> show variables like '%read_only%';

+-----------------------+-------+

| Variable_name | Value |

+-----------------------+-------+

| innodb_read_only | OFF |

| read_only | ON |

| super_read_only | ON |

| transaction_read_only | OFF |

+-----------------------+-------+

4 rows in set (0.00 sec)
```
