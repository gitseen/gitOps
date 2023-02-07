# MySQL主从复制的原理
主从复制是指将主数据库的DDL和DML操作通过二进制日志传到从库服务器中，然后在从库上对这些日志重新执行(也叫重做)，从而使得从库和主库的数据保持同步。 

MySQL支持一台主库同时向多台从库进行复制， 从库同时也可以作为其他从服务器的主库，实现链状复制。
## MySQL 复制的优点主要包含以下三个方面
   + 1.主库出现问题，可以快速切换到从库提供服务。
   + 2.实现读写分离，降低主库的访问压力。
   + 3.可以在从库中执行备份，以避免备份期间影响主库服务
## 复制步骤
   + 1.Master 主库在事务提交时，会把数据变更记录在二进制日志文件 Binlog 中。
   + 2.从库读取主库的二进制日志文件 Binlog ，写入到从库的中继日志 Relay Log 。
   + 3.slave重做中继日志中的事件，将改变反映它自己的数据。
![MySQL主从复](https://p3-sign.toutiaoimg.com/tos-cn-i-qvj2lq49k0/f6ca963a4ac748d699e931ba33d87ccb~noop.image?_iz=58558&from=article.pc_detail&x-expires=1676337972&x-signature=whHLaThph2BdSe3ux87S87yQSXs%3D)  


# master-conf  
```
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
````

# slave-conf
```
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
````


# 手动清理master日志，最好关闭日志，在/etc/my.cnf
```
mysql> show master status; #手动刷新日志
mysql> reset slave; rest master; #删除全部
mysql> PURGE MASTER LOGS TO 'MySQL-bin.004' #删除MySQL-bin.004
```

# 彻底解除主从复制关系
```
      1)stop slave ;RESET MASTER ;reset slave;reset slave;
      2)reset slave; 或直接删除master.info和relay-log.info这两个文件；
      stop slave ;RESET MASTER ;reset slave
      show variables like '%log_bin%';
      show engine innodb status \G
      show binlog events;
      show binlog events in 'mysql-bin.000002';
      show binary logs;
```

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

