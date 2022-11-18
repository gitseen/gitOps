# master-conf

[mysqld] 
log_bin=/var/lib/mysql/mysql_binary_log  #标识唯一id（必须），一般使用ip最后位
server-id=1                              #标识唯一id（必须），一般使用ip最后位 
binlog-ignore-db=mysql,performance_schema,sys #不同步的数据库，可设置多个
binlog-do-db=test,xx                     #指定需要同步的数据库（和slave是相互匹配的），可以设置多个 

binlog_format=MIXED                      #设置存储模式不设置默认
expire_logs_days=7                       #日志清理时间 
max_binlog_size=100m                     #日志大小 
binlog_cache_size=4m                     #缓存大小
max_binlog_cache_size=521m               #最大缓存大小


# slave-conf
  #开启二进制日志
log_bin=/var/lib/mysql/mysql_binary_log
server-id=2 
  #binlog-ignore-db=information_schema,performance_schema,mysql

  #与主库配置保持一致
replicate-ignore-db=mysql,performance_schema,sys
replicate-do-db=test,xx 
log-slave-updates 
slave-skip-errors=all 
#slave-skip-errors = 1032,1062,1007
slave-net-timeout=60 



# 手动清理master日志，最好关闭日志，在/etc/my.cnf
mysql> show master status; #手动刷新日志
mysql> reset slave; rest master; #删除全部
mysql> PURGE MASTER LOGS TO 'MySQL-bin.004' #删除MySQL-bin.004


# 彻底解除主从复制关系
      1)stop slave ;RESET MASTER ;reset slave;reset slave;
      2)reset slave; 或直接删除master.info和relay-log.info这两个文件；
      stop slave ;RESET MASTER ;reset slave
      show variables like '%log_bin%';
      show engine innodb status \G
      show binlog events;
      show binlog events in 'mysql-bin.000002';
      show binary logs;


# 同步所有数据库
## Master(产环境主库不能设置read_only不然业务炸了)
```bash
[mysqld]
datadir=/var/lib/mysql
socket=/var/lib/mysql/mysql.sock
transaction-isolation = READ-COMMITTED
symbolic-links = 0
key_buffer_size = 32M
max_allowed_packet = 32M
thread_stack = 256K
thread_cache_size = 64
query_cache_limit = 8M
query_cache_size = 64M
query_cache_type = 1
max_connections = 3000
max_binlog_size = 512M
sync_binlog = 1
expire_logs_days = 7
max_binlog_size = 100
binlog_cache_size = 4m
log_bin=/var/lib/mysql/mysql_binary_log
server_id=1
binlog_format = mixed
read_buffer_size = 2M
read_rnd_buffer_size = 16M
sort_buffer_size = 8M
join_buffer_size = 8M
innodb_file_per_table = 1
innodb_flush_log_at_trx_commit  = 2
innodb_log_buffer_size = 64M
innodb_buffer_pool_size = 4G
innodb_thread_concurrency = 8
innodb_flush_method = O_DIRECT
innodb_log_file_size = 512M
sql_mode=STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION,NO_ZERO_DATE,NO_ZERO_IN_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER
lower_case_table_names=1
character-set-server=utf8
collation-server=utf8_general_ci
explicit_defaults_for_timestamp=true
log_slave_updates
auto-increment-increment = 2
auto-increment-offset = 1     # 自增值的偏移量
slave-skip-errors = all        #跳过从库错误

[mysqld_safe]
log-error=/var/log/mysqld.log
pid-file=/var/lib/mysql/mysqld.pid

[client]
socket=/var/lib/mysql/mysql.sock

```

## Slave
```bash
[mysqld]
datadir=/var/lib/mysql
socket=/var/lib/mysql/mysql.sock
transaction-isolation = READ-COMMITTED
symbolic-links = 0
key_buffer_size = 32M
max_allowed_packet = 32M
thread_stack = 256K
thread_cache_size = 64
query_cache_limit = 8M
query_cache_size = 64M
query_cache_type = 1
max_connections = 3000
max_binlog_size = 512M
sync_binlog = 1
expire_logs_days = 7
max_binlog_size = 100
binlog_cache_size = 4m
log_bin=/var/lib/mysql/mysql_binary_log
server_id=2
binlog_format = mixed
read_buffer_size = 2M
read_rnd_buffer_size = 16M
sort_buffer_size = 8M
join_buffer_size = 8M
innodb_file_per_table = 1
innodb_flush_log_at_trx_commit  = 2
innodb_log_buffer_size = 64M
innodb_buffer_pool_size = 4G
innodb_thread_concurrency = 8
innodb_flush_method = O_DIRECT
innodb_log_file_size = 512M
sql_mode=STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION,NO_ZERO_DATE,NO_ZERO_IN_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER
lower_case_table_names=1
character-set-server=utf8
collation-server=utf8_general_ci
explicit_defaults_for_timestamp=true
log_slave_updates
auto-increment-increment = 2
auto-increment-offset = 1
slave-skip-errors = all
#relay-log=relay-log-bin
#relay-log-index=slave-relay-bin.index
[mysqld_safe]
log-error=/var/log/mysqld.log
pid-file=/var/lib/mysql/mysqld.pid
[client]
socket=/var/lib/mysql/mysql.sock

```

# 指定数据库
master
```bash

````

slave
```bash

```

