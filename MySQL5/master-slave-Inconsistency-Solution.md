# 《MySQL主从不一致情形与解决方法》

## 一、MySQL主从不同步情况
### 1.1 网络的延迟
由于mysql主从复制是基于binlog的一种异步复制
通过网络传送binlog文件，理所当然网络延迟是主从不同步的绝大多数的原因，特别是跨机房的数据同步出现这种几率非常的大，所以做读写分离，注意从业务层进行前期设计。  

### 1.2 主从两台机器的负载不一致
由于mysql主从复制是主数据库上面启动1个io线程，而从上面启动1个sql线程和1个io线程，当中任何一台机器的负载很高，忙不过来，导致其中的任何一个线程出现资源不足，都将出现主从不一致的情况。
### 1.3 max_allowed_packet设置不一致
主数据库上面设置的max_allowed_packet比从数据库大，当一个大的sql语句，能在主数据库上面执行完毕，从数据库上面设置过小，无法执行，导致的主从不一致。
### 1.4 自增键不一致
key自增键开始的键值跟自增步长设置不一致引起的主从不一致。
### 1.5 同步参数设置问题
mysql异常宕机情况下，如果未设置sync_binlog=1或者
innodb_flush_log_at_trx_commit=1很有可能出现binlog或者relaylog文件出现损坏，导致主从不一致。
### 1.6 自身bug
mysql本身的bug引起的主从不同步
### 1.7 版本不一致
特别是高版本是主，低版本为从的情况下，主数据库上面支持的功能，从数据库上面不支持该功能。
### 1.8 主从不一致优化配置
基于以上情况，先保证max_allowed_packet，自增键开始点和增长点设置一致
再者牺牲部分性能在主上面开启sync_binlog，对于采用innodb的库，推荐配置下面的内容
innodb_flush_logs_at_trx_commit = 1
innodb-support_xa = 1 # Mysql 5.0 以上
innodb_safe_binlog # Mysql 4.0
同时在从上面推荐加入下面两个参数
skip_slave_start
read_only

## 二、解决主从不同步的方法
### 2.1 主从不同步场景描述
今天发现Mysql的主从数据库没有同步  
```bash
先上Master库：  
mysql>show processlist;
查看下进程是否Sleep太多。发现很正常。
show master status;
查看主库状态也正常。
mysql> show master status;FilePositionBinlog_Do_DBBinlog_Ignore_DBmysqld-bin.0000013260mysql,test,information_schema
1 row in set (0.00 sec)
复制代码再到Slave上查看
mysql> show slave statusG
Slave_IO_Running: Yes
Slave_SQL_Running: No
复制代码由此可见是Slave不同步
```
### 2.2 解决方法一：忽略错误后，继续同步
该方法适用于主从库数据相差不大，或者要求数据可以不完全统一的情况，数据要求不严格的情况
解决： 
 
```bash
stop slave;
复制代码
表示跳过一步错误，后面的数字可变
set global sql_slave_skip_counter =1;
start slave;
复制代码
之后再用mysql> show slave statusG 查看：
Slave_IO_Running: Yes
Slave_SQL_Running: Yes
复制代码ok，现在主从同步状态正常了。。。
```  
### 2.3 方式二：重新做主从，完全同步
该方法适用于主从库数据相差较大，或者要求数据完全统一的情况
解决步骤如下：  
````bash  
1.先进入主库，进行锁表，防止数据写入
使用命令：
mysql> flush tables with read lock;
注意：该处是锁定为只读状态，语句不区分大小写
2.进行数据备份
把数据备份到mysql.bak.sql文件
[root@server01 mysql]#mysqldump -uroot -p -hlocalhost > mysql.bak.sql
这里注意一点：数据库备份一定要定期进行，可以用shell脚本或者python脚本，都比较方便，确保数据万无一失
3.查看master 状态
mysql> show master status;
+——————-+———-+————–+——————————-+
| File | Position | Binlog_Do_DB | Binlog_Ignore_DB |
+——————-+———-+————–+——————————-+
| mysqld-bin.000001 | 3260 | | mysql,test,information_schema |
+——————-+———-+————–+——————————-+
1 row in set (0.00 sec)
复制代码
4.把mysql备份文件传到从库机器，进行数据恢复
使用scp命令
[root@server01 mysql]# scp mysql.bak.sql root@192.168.1.206:/tmp/
5.停止从库的状态
mysql> stop slave;
6.然后到从库执行mysql命令，导入数据备份
mysql> source /tmp/mysql.bak.sql
7.设置从库同步，注意该处的同步点，就是主库show master status信息里的| File| Position两项
change master to master_host = ‘192.168.1.206’, master_user = ‘rsync’, master_port=3306, master_password=”, master_log_file = ‘mysqld-bin.000001’, master_log_pos=3260;
8.重新开启从同步
mysql> start slave;
9.查看同步状态
mysql> show slave statusG 查看：
Slave_IO_Running: Yes
Slave_SQL_Running: Yes
好了，同步完成啦  

```  
## 三、如何监控mysql主从之间的延迟
### 3.1 前言：
日常工作中，对于MYSQL主从复制的检查有两方面  
保证复制的整体结构是否完整；  
需要检查数据是否一致；  
对于前者我们可以通过监控复制线程是否工作正常以及主从延时是否在容忍范围内，对于后者则可以通过分别校验主从表中数据的md5码是否一致，来保证数据一致，可以使用Maatkit工具包中的mk-table-checksum工具去检查。  
如何检查主从延迟的问题,主从延迟判断的方法，通常有两种方法：Seconds_Behind_Master和mk-heartbeat  
### 3.2方法1.
通过监控show slave statusG命令输出的Seconds_Behind_Master参数的值来判断，是否有发生主从延时。  
```bash  
mysql> show slave statusG;
1. row **
 Slave_IO_State: Waiting for master to send event
 Master_Host: 192.168.1.205
 Master_User: repl
 Master_Port: 3306
 Connect_Retry: 30
 Master_Log_File: edu-mysql-bin.000008
 Read_Master_Log_Pos: 120
 Relay_Log_File: edu-mysql-relay-bin.000002
 Relay_Log_Pos: 287
 Relay_Master_Log_File: edu-mysql-bin.000008
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
 Exec_Master_Log_Pos: 120
 Relay_Log_Space: 464
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
 Master_Server_Id: 205
 Master_UUID: 7402509d-fd14-11e5-bfd0-000c2963dd15
 Master_Info_File: /home/mysql/data/master.info
 SQL_Delay: 0
 SQL_Remaining_Delay: NULL
 Slave_SQL_Running_State: Slave has read all relay log; waiting for the slave I/O thread to update it
 Master_Retry_Count: 86400
 Master_Bind: 
 Last_IO_Error_Timestamp: 
 Last_SQL_Error_Timestamp: 
 Master_SSL_Crl: 
 Master_SSL_Crlpath: 
 Retrieved_Gtid_Set: 
 Executed_Gtid_Set: 
 Auto_Position: 0
1 row in set (0.00 sec)
复制代码以上是show slave statusG的输出结果，这些结构给我们的监控提供了很多有意义的参数。
Slave_IO_Running
该参数可作为io_thread的监控项，Yes表示io_thread的和主库连接正常并能实施复制工作，No则说明与主库通讯异常，多数情况是由主从间网络引起的问题；
Slave_SQL_Running
该参数代表sql_thread是否正常，具体就是语句是否执行通过，常会遇到主键重复或是某个表不存在。
Seconds_Behind_Master
是通过比较sql_thread执行的event的timestamp和io_thread复制好的event的timestamp(简写为ts)进行比较，而得到的这么一个差值；NULL—表示io_thread或是sql_thread有任何一个发生故障，也就是该线程的Running状态是No，而非Yes。0 — 该值为零，是我们极为渴望看到的情况，表示主从复制良好，可以认为lag不存在。
正值 — 表示主从已经出现延时，数字越大表示从库落后主库越多。负值 — 几乎很少见，我只是听一些资深的DBA说见过，其实，这是一个BUG值，该参数是不支持负值的，也就是不应该出现。
备注Seconds_Behind_Master的计算方式可能带来的问题
我们都知道的relay-log和主库的bin-log里面的内容完全一样，在记录sql语句的同时会被记录上当时的ts，所以比较参考的值来自于binlog，其实主从没有必要与NTP进行同步，也就是说无需保证主从时钟的一致。你也会发现，其实比较真正是发生在io_thread与sql_thread之间，而io_thread才真正与主库有关联，于是，问题就出来了，
当主库I/O负载很大或是网络阻塞
io_thread不能及时复制binlog（没有中断，也在复制），而sql_thread一直都能跟上io_thread的脚本，这时Seconds_Behind_Master的值是0，
也就是我们认为的无延时，但是，实际上不是，你懂得。
这也就是为什么大家要批判用这个参数来监控数据库是否发生延时不准的原因，但是这个值并不是总是不准，
如果当io_thread与master网络很好的情况下，那么该值也是很有价值的。’‘之前，提到Seconds_Behind_Master这个参数会有负值出现，我们已经知道该值是io_thread的最近跟新的ts与sql_thread执行到的ts差值，
前者始终是大于后者的，唯一的肯能就是某个event的ts发生了错误，比之前的小了，那么当这种情况发生时，负值出现就成为可能。  

```  
## 3.2 方法2.
mk-heartbeat：Maatkit万能工具包中的一个工具，被认为可以准确判断复制延时的方法。  

mk-heartbeat的实现也是借助timestmp的比较实现的，它首先需要保证主从服务器必须要保持一致，通过与相同的一个NTP server同步时钟。它需要在主库上创建一个heartbeat的表，里面至少有id与ts两个字段，id为server_id，ts就是当前的时间戳now()，该结构也会被复制到从库上，表建好以后，会在主库上以后台进程的模式去执行一行更新操作的命令，定期去向表中的插入数据，这个周期默认为1秒，同时从库也会在后台执行一个监控命令，与主库保持一致的周期去比较，复制过来记录的ts值与主库上的同一条ts值，差值为0表示无延时，差值越大表示延时的秒数越多。我们都知道复制是异步的ts不肯完全一致，所以该工具允许半秒的差距，在这之内的差异都可忽略认为无延时。这个工具就是通过实打实的复制，巧妙的借用timestamp来检查延时。  
