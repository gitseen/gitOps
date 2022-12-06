  See https://www.toutiao.com/article/7171330542800224802/  for details.

```bash
MySQL是一种关系型数据库管理系统，关系数据库将数据保存在不同的表中，而不是将所有数据放在一个大仓库内，这样就增加了速度并提高了灵活性。

Mysql性能优化方面涉及Sql语句，数据库引擎、数据类型、服务器硬件、Mysql参数配置优化 、读写分离、分库分表等方面。

一、SQL语句优化

1. 对查询进行优化，应避免全表扫描，首先应考虑 where 及 order by 涉及的列上建立索引

#根据字段查询内容，避免使用  “ * ”全表扫描查询 #
#查询#
select username,password,phone,address from users_info
#条件查询- 查询主键或查询索引字段提高查询效率#
select user_id,username,password,phone,address from users_info where user_id = '1000'
2.高频字段应建立索引，可提高响应时间

3.不要盲目建立 索引，根据需要建立

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

3.金额类字段使用int，金额单位用“分”方式存取，有效防止丢数值精度问题

如：使用货币单位 “分” ：100 = 10000

三、常用Mysql数据库引擎

1.InnoDB引擎

InnoDB是MySQL的默认引擎，使用的是可重复读级别的隔离，B+树是InnoDB的默认索引类型，并且支持事务和行锁，以及外键约束。

它的设计的目标就是处理大数据容量的数据库系统，MySQL 运行的时候，InnoDB 会在内存中建立缓冲池，用于缓冲数据和索引。但是InnoDB是不支持全文搜索，同时启动也比较的慢，它是不会保存表的行数的，所以当进行 selectcount(*) from table 指令的时候，需要进行扫描全表。由于锁的粒度小，写操作是不会锁定全表的,所以在并发度较高的场景下使用会提升效率的。

2.MyISAM引擎

Myisam 的存储文件有三个，后缀名分别是 .frm、.MYD、MYI，其中 .frm 是表的定义文件，.MYD 是数据文件，.MYI 是索引文件。

Myisam 只支持表锁，不支持事务。Myisam 由于有单独的索引文件，在读取数据方面的性能很高 。MyIASM 引擎是保存了表的行数，于是当进行 select count(*) from table 语句时，可以直接读取已经保存的值而不需要进行扫描全表。



四、硬件升级

提高服务器处理器、内存、硬盘配置
服务器硬盘应该选用高性能SSD，提高文件读写速度
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

