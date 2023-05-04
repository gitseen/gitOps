  See https://www.toutiao.com/article/7171330542800224802/  for details.

```bash
MySQL是一种关系型数据库管理系统,关系数据库将数据保存在不同的表中,而不是将所有数据放在一个大仓库内,这样就增加了速度并提高了灵活性。

Mysql性能优化方面涉及Sql语句,数据库引擎、数据类型、服务器硬件、Mysql参数配置优化 、读写分离、分库分表等方面。

一、SQL语句优化

1. 对查询进行优化,应避免全表扫描,首先应考虑 where 及 order by 涉及的列上建立索引

#根据字段查询内容,避免使用  “ * ”全表扫描查询 #
#查询#
select username,password,phone,address from users_info
#条件查询- 查询主键或查询索引字段提高查询效率#
select user_id,username,password,phone,address from users_info where user_id = '1000'
2.高频字段应建立索引,可提高响应时间

3.不要盲目建立 索引,根据需要建立

二、数据类型

数值类型


Mysql数据类型-数值类型

时间和日期类型


Mysql数据类型-日期与时间类型

字符串类型


Mysql数据类型-字符串类型

数据类型使用-知识要点
1.BIGINT 数据类型,在64位操作系统下使用

2. 一般业务环境下数据类型使用无符号类型

3.金额类字段使用int,金额单位用“分”方式存取,有效防止丢数值精度问题

如：使用货币单位 “分” ：100 = 10000

三、常用Mysql数据库引擎

1.InnoDB引擎

InnoDB是MySQL的默认引擎,使用的是可重复读级别的隔离,B+树是InnoDB的默认索引类型,并且支持事务和行锁,以及外键约束。

它的设计的目标就是处理大数据容量的数据库系统,MySQL 运行的时候,InnoDB 会在内存中建立缓冲池,用于缓冲数据和索引。但是InnoDB是不支持全文搜索,同时启动也比较的慢,它是不会保存表的行数的,所以当进行 selectcount(*) from table 指令的时候,需要进行扫描全表。由于锁的粒度小,写操作是不会锁定全表的,所以在并发度较高的场景下使用会提升效率的。

2.MyISAM引擎

Myisam 的存储文件有三个,后缀名分别是 .frm、.MYD、MYI,其中 .frm 是表的定义文件,.MYD 是数据文件,.MYI 是索引文件。

Myisam 只支持表锁,不支持事务。Myisam 由于有单独的索引文件,在读取数据方面的性能很高 。MyIASM 引擎是保存了表的行数,于是当进行 select count(*) from table 语句时,可以直接读取已经保存的值而不需要进行扫描全表。



四、硬件升级

提高服务器处理器、内存、硬盘配置
服务器硬盘应该选用高性能SSD,提高文件读写速度
五、Mysql参数配置

配置流程
1.MySQL文件目录中后缀名为.ini文件的就是MySQL的默认配置文件
2.程序启动会先加载配置文件中的的配置 之后才会真正启动程序；
3.更改完配置文件设置后需要重新启动服务端才可以生效；
优化方案一：服务器内存:4-8GB

key_buffer_size 384 MB, 用于索引的缓冲区大小
query_cache_size 192 MB, 查询缓存,不开启请设为0
tmp_table_size 512 MB, 临时表缓存大小
innodb_buffer_pool_size 512 MB, Innodb缓冲区大小
innodb_log_buffer_size 128 MB, Innodb日志缓冲区大小
sort_buffer_size 1024 KB * 连接数, 每个线程排序的缓冲大小
read_buffer_size 1024 KB * 连接数, 读入缓冲区大小
read_rnd_buffer_size 768 KB * 连接数, 随机读取缓冲区大小
join_buffer_size 2048 KB * 连接数, 关联表缓存大小
thread_stack 256 KB * 连接数, 每个线程的堆栈大小
binlog_cache_size 128 KB * 连接数, 二进制日志缓存大小(4096的倍数)
thread_cache_size 128 线程池大小
table_open_cache 384 表缓存
max_connections 300  最大连接数


优化方案二：服务器内存:8-16GB

key_buffer_size 512 MB, 用于索引的缓冲区大小
query_cache_size 256 MB, 查询缓存,不开启请设为0
tmp_table_size 1024 MB, 临时表缓存大小
innodb_buffer_pool_size 1024 MB, Innodb缓冲区大小
innodb_log_buffer_size 128 MB, Innodb日志缓冲区大小
sort_buffer_size 2048 KB * 连接数, 每个线程排序的缓冲大小
read_buffer_size 2048 KB * 连接数, 读入缓冲区大小
read_rnd_buffer_size 1024 KB * 连接数, 随机读取缓冲区大小
join_buffer_size 4096 KB * 连接数, 关联表缓存大小
thread_stack 384 KB * 连接数, 每个线程的堆栈大小
binlog_cache_size 192 KB * 连接数, 二进制日志缓存大小(4096的倍数)
thread_cache_size 192 线程池大小
table_open_cache 1024 表缓存
max_connections 400  最大连接数
优化方案三：服务器内存:8-16GB

key_buffer_size 1024 MB, 用于索引的缓冲区大小
query_cache_size 384 MB, 查询缓存,不开启请设为0
tmp_table_size 2048 MB, 临时表缓存大小
innodb_buffer_pool_size 4096 MB, Innodb缓冲区大小
innodb_log_buffer_size 128 MB, Innodb日志缓冲区大小
sort_buffer_size 4096 KB * 连接数, 每个线程排序的缓冲大小
read_buffer_size 4096 KB * 连接数, 读入缓冲区大小
read_rnd_buffer_size 2048 KB * 连接数, 随机读取缓冲区大小
join_buffer_size 8192 KB * 连接数, 关联表缓存大小
thread_stack 512 KB * 连接数, 每个线程的堆栈大小
binlog_cache_size 256 KB * 连接数, 二进制日志缓存大小(4096的倍数)
thread_cache_size 256 线程池大小
table_open_cache 2048 表缓存
max_connections 500  最大连接数
```

---
# mysql 主从同步延迟高的原因
MySQL 主从同步延迟高可能有很多原因,下面列举了一些可能得的因素,建议是意一一对照来排查问题
- 网络延迟：主从数据库之间的网络带宽不足或者网络延迟较高,可能导致同步延迟  
      ```
      使用 ping 命令测试主从服务器之间的网络延迟
      使用 traceroute 或 tracert 命令检查网络路径
      使用 iperf 工具测试主从服务器之间的网络带宽
      ```
- 磁盘IO性能：主从服务器的磁盘IO性能不足,导致写入慢,从而影响同步速度  
      ```
      使用 iostat 命令检查主从服务器的磁盘IO性能
      使用 fio 或其他压力测试工具,对主从服务器的磁盘进行性能测试
      检查服务器硬件,例如磁盘类型、RAID配置等,以确定是否存在瓶颈
      ```
- 数据库负载：主数据库写入负载较高,导致主库binlog日志生成速度加快,从库同步数据压力增大,进而导致延迟增高  
      ```
      使用 SHOW PROCESSLIST 命令查看数据库当前的运行状态和查询
      使用 SHOW STATUS 或 SHOW GLOBAL STATUS 查看数据库性能相关指标
      使用慢查询日志分析工具（如pt-query-digest）分析慢查询,优化慢查询以减轻主库负担
      ```
- 复制策略：MySQL复制策略有两种,一种是基于语句的复制SBR,另一种是基于行的复制RBR,SBR在复杂的SQL场景下可能导致从库执行效率较低,从而导致同步延迟  
      ```
      检查主库的 binlog_format 设置,评估是否有必要切换为基于行的复制（RBR）以减少从库的执行负担
      检查SQL语句,优化复杂的SQL语句,以提高从库执行效率
      ```
- 从库性能：从库服务器硬件性能较低,如CPU、内存等,可能导致处理同步数据的速度较慢,从而产生延迟  
      ```
      检查从库服务器的硬件资源,如CPU使用率、内存使用情况等,确认是否有性能瓶颈
      使用 SHOW SLAVE STATUS 命令查看从库复制状态,确认是否有执行延迟
      ```
- 并行复制限制：MySQL5.6及更早版本的从库只支持单线程复制,导致同步效率较低。MySQL5.7及更高版本引入了多线程复制,但如果并行度设置不合理,可能导致延迟  
      ```
      检查从库的 slave_parallel_workers 参数,评估并调整合适的并行度
      检查从库的 slave_parallel_type 参数,选择合适的并行类型
      ```
- 主从复制参数配置：MySQL的复制参数设置不当,可能导致同步延迟。例如,sync_binlog 参数设置过大或者过小,都可能影响复制效率  
      ```
      检查主库的 sync_binlog 参数,根据实际需求进行调整
      检查从库的 read_buffer_size 和 read_rnd_buffer_size 参数,根据实际情况进行调整
      ```
- 二进制日志格式：如果主库使用了非常大的二进制日志格式,可能导致从库解析binlog日志变慢,从而影响同步速度  
      ```
      检查主库的 max_binlog_size 参数,评估是否需要调整二进制日志大小
      检查主库的 binlog_row_image 参数,评估是否可以使用MINIMAL或NOBLOB选项以减少日志大小
      ```
- 长事务：长时间运行的事务可能导致从库同步进程阻塞,从而产生同步延迟
      ```
      使用 SHOW PROCESSLIST 命令查看长时间运行的事务
      使用 innodb_kill_idle_transaction 参数设置空闲事务超时时间,以自动终止长时间未提交的事务
      ```
**要解决主从同步延迟高的问题,可以从上述原因出发,进行逐一排查和优化。例如,优化网络环境、提高服务器硬件性能、调整复制策略、优化参数配置等。同时,监控主从复制状态,定期检查主从延迟情况,以便及时发现和解决问题**
