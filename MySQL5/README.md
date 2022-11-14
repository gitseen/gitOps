# MySQL
  MySQL是一个关系型数据库管理系统,由瑞典MySQLAB公司开发,目前属于Oracle旗下公司  
  MySQL最流行的关系型数据库管理系统(关系数据库将数据保存在不同的表中,不是将所有数据放在一个大仓库内,这样增加了速度并提高了灵活性)  
  在WEB应用方面MySQL是最好的RDBMS(Relational Database Management System)关系数据库管理系统) 应用软件之一  

## 1、存储引擎
   MyISAMMySQL5.0之前的默认数据库引擎,最为常用。拥有较高的插入,查询速度,但不支持事务  
   InnoDB事务型数据库的首选引擎,MYSQL5.5之后默认引擎为InnoDB;Innodb支持行级锁定、支持ACID事务、支持事物、外键等功能。    
   BDB源自BerkeleyDB,事务型数据库的另一种选择,支持Commit和Rollback等其他事务特性  
```bash
   InnoDB事务型数据库的首选引擎,支持ACID事务ACID包括
    1 原子性（Atomicity）
    2 一致性（Consistency）
    3 隔离性（Isolation）
    4 持久性（Durability）
    一个支持事务(Transaction)的数据库,必需要具有这四种特性,否则在执行事务过程无法保证数据的正确性   
```
### MyISAM和innoDB区别
```bash
MyISAM类型的数据库表强调的是性能,其执行数度比InnoDB类型更快,但不提供事务支持,如果执行大量的SELECT(查询)操作,MyISAM是更好的选择,支持表锁。
InnoDB提供事务支持事务、外部键、行级锁等高级数据库功能,执行大量的INSERT或UPDATE,出于性能方面的考虑,可以考虑使用InnoDB引擎。
```

## 2、索引功能
   索引是一种特殊的文件(InnoDB数据表上的索引是表空间的一个组成部分),它们包含着对数据表里所有记录的引用指针。索引不是万能的,索引可以加快数据检索操作,但会使数据修改操作变慢。从理论上讲,完全可以为数据表里的每个字段分别建一个索引,但MySQL把同一个数据表里的索引总数限制为16个。
### 索引类别
```bash
   1．普通索引
      #普通索引"由关键字KEY或INDEX定义的索引"的任务是加快对数据的访问速度
   2．索引
      #普通索引允许被索引的数据列包含重复的值
   3．主索引
      #在前面已经反复多次强调过：必须为主键字段创建一个索引,这个索引就是所谓的“主索引”。主索引区别是：前者在定义时使用的关键字是PRIMARY而不是UNIQUE
   4．外键索引
      #如果为某个外键字段定义了一个外键约束条件,MySQL 就会定义一个内部索引来帮助自己以最有效率的方式去管理和使用外键约束条件
   5．复合索引
      #索引可以覆盖多个数据列,如像INDEX(columnA, columnB)索引。这种索引的特点是MySQL可以有选择地使用一个这样的索引    
```
## 3、应用架构
### 3.1 集群方案
- 集群的好处  
  1 高可用性：故障检测及迁移,多节点备份。  
  2 可伸缩性：新增数据库节点便利,方便扩容。  
  3 负载均衡：切换某服务访问某节点,分摊单个节点的数据库压力。  
- 集群要考虑的风险  
  1 网络分裂：群集还可能由于网络故障而拆分为多个部分,每部分内的节点相互连接,但各部分之间的节点失去连接。  
  2 脑裂：导致数据库节点彼此独立运行的集群故障称为“脑裂”。可能导致数据不一致,并且无法修复(如当两个数据库节点独立更新同一表上的同一行时)
- 集群方案(高可用方案)   
  主从复制架构 1主从复制(一主多从) 2MMM架构(双主多从,第3方方案) 3MHA架构(多主多从)  
  1 MySQL Replication #mysql官方提供的方案   
  2 MySQL Fabirc   
  3 MySQL Cluster  
  4 MySQL MHA/MMM  
### 3.2 单点Single适合小规模应用
```bash
单节点数据库的弊病
   单节点数据库无法满足大并发时性能上的要求
   单节点的数据库没有冗余设计,无法满足高可用
   单节点MySQL无法承载巨大的业务量,数据库负载巨大
   大型互联网程序用户群体庞大,所以架构需要特殊设计
```
### 3.3 复制Replication适合中小规模应用
MySQL 主从复制是通过重放binlog实现主库数据的异步复制。即当主库执行了一条sql命令,那么在从库同样的执行一遍,从而达到主从复制的效果  
MySQL Replication是一主多从的结构,主要目的是实现数据的多点备份(没有故障自动转移和负载均衡)  
Replication方案只能在Master数据库进行写操作,在Slave数据库进行读操作;如果在Slave数据库中写入数据Master数据库是不能知晓(单向同步的)  
- Replication优缺点 
  ```bash
   相比于单个的mysql,一主多从下的优势如下 
     1.读写分离,负载均衡
       #如果让后台读操作连接从数据库,让写操作连接主数据库,能起到读写分离的作用,这个时候多个从数据库可以做负载均衡。
     2.热备份
       #可以在某个从数据库中暂时中断复制进程,来备份数据,从而不影响主数据的对外服务(如果在master上执行backup,需要让master处于readonly状态,这也意味这所有的write请求需要阻塞)。
   就各个集群方案来说,其优劣势 
     优势 
       1.主从复制是mysql自带的,无需借助第三方
       2.数据被删除,可以从binlog日志中恢复
       3.配置较为简单方便
     劣势 
       1.从库要从binlog获取数据并重放,这肯定与主库写入数据存在时间延迟,因此从库的数据总是要滞后主库
       2.对主库与从库之间的网络延迟要求较高,若网络延迟太高,将加重上述的滞后,造成最终数据的不一致
       3.单点故障问题：单一的主节点挂了,将不能对外提供写服务
  ```
- MySQL Fabirc  
  mysql官方提供的,这是在MySQL Replication的基础上,增加了故障检测与转移,自动数据分片功能。不过依旧是一主多从的结构  
  MySQL Fabirc只有一个主节点,区别是当该主节点挂了以后,会从从节点中选择一个来当主节点  
  ```bash
     就各个集群方案来说,其优势为  
       1.mysql官方提供的工具,无需第三方插件
       2.数据被删除,可以从binlog日志中恢复
       3.单点故障问题：主节点挂了以后,能够自动从从节点中选择一个来当主节点,不影响持续对外提供写服务
     其劣势为：
       1.从库要从binlog获取数据并重放,这肯定与主库写入数据存在时间延迟,因此从库的数据总是要滞后主库
       2.对主库与从库之间的网络延迟要求较高,若网络延迟太高,将加重上述的滞后,造成最终数据的不一致
       3.事务及查询只支持在同一个分片内,事务中更新的数据不能跨分片,查询语句返回的数据也不能跨分片
       4.节点故障恢复30秒或更长(采用InnoDB存储引擎的都这样)
       #分片：分片可以简单定义为将大数据库分布到多个物理节点上的一个分区方案。每一个分区包含数据库的某一部分,称为一个片
       #分区：分区则是把一张表的数据分成N多个区块,这些区块可以在同一个磁盘上,也可以在不同的磁盘上
  ```
### 3.4 集群Cluster适合大规模应用
mysql官方提供的,多主多从结构  
- MySQL Cluster优缺点
```bash
   优点  
       1.mysql官方提供的工具,无需第三方插件。
       2.多个主节点,没有单点故障的问题,节点故障恢复通常小于1秒。
       3.负载均衡优秀,可同时用于读操作、写操作都都密集的应用,也可以使用SQL和NOSQL接口访问数据。
       4.高可用性和可伸缩性
          #可以自动切分数据,方便数据库的水平拓展
          #能跨节点冗余数据(其数据集并不是存储某个特定的MySQL实例上,而是被分布在多个DataNodes中,即一个table的数据可能被分散在多个物理节点上,任何数据都会在多个DataNodes上冗余备份。任何一个数据变更操作,都将在一组DataNodes上同步,以保证数据的一致性)。
   缺点  
       1.架构模式和原理很复杂
       2.只能使用存储引擎NDB,与平常使用的InnoDB有很多明显的差距,可能会导致日常开发出现意外如下：
         #事务(其事务隔离级别只支持ReadCommitted,即一个事务在提交前,查询不到在事务内所做的修改)
         #外键(虽然最新的NDB 存储引擎已经支持外键,但性能有问题,因为外键所关联的记录可能在别的分片节点)
         #表限制
       3.对节点之间的内部互联网络带宽要求高
         #作为分布式的数据库系统,各个节点之间存在大量的数据通讯,比如所有访问都是需要经过超过一个节点(至少有一个SQLNode和一个NDBNode)才能完成
       4.对内存要求大 
         #Data Node数据会被尽量放在内存中,对内存要求大,而且重启的时候,数据节点将数据load到内存需要很长时间     
```
### 3.5 高可用方案
- 主从架构  
  ```bash
     单向主从模式：Master ——> Slave  
     双向主从模式：Master <====> Master  
     级联主从模式：Master ——> Slave1 ——> Slave2  
     一主多从模式  
     多主一从模式  
  ```
- 主从复制功能
  ```bash
  实时灾备、读写分离、高可用、从库数据统计、从库数据备份
     #实时灾备,用于故障切换（高可用）
     #读写分离,提供查询服务（读扩展）
     #数据备份,避免影响业务（高可用）
  ```
### 3.5.1 MySQL主从复制(一主多从) 
MySQL主从模式是指数据可以从一个MySQL数据库服务器主节点复制到一个或多个从节点  
MySQL默认采用异步复制方式,这样从节点不用一直访问主服务器来更新自己的数据,从节点可以复制主数据库中的所有数据库,或者特定的数据库,或者特定的表
- 主从复制原理
  ![主从复制原理](https://img-blog.csdnimg.cn/906ad8c9260f4694b8de3add16b4fbd1.png?x-oss-process=image/watermark,type_ZHJvaWRzYW5zZmFsbGJhY2s,shadow_50,text_Q1NETiBAQWJkdWxsYWjmuIU=,size_20,color_FFFFFF,t_70,g_se,x_16 "1")
  MYSQL复制有3个步骤
  ```bash
     1、master将改变记录到二进制日志(binary log)中(这些记录叫做二进制日志事件,binary log events)
     2、slave将master的binary log events拷贝到它的中继日志(relay log)
     3、slave重做中继日志中的事件,将改变反映它自己的数据
    #首先在master上开启bin-log日志功能,bin-log日志用于记录在Master库中执行的增、删、修改
    #整个过程需要开启3个线程,分别是Master开启IO线程,slave开启IO线程和SQL线程
  ```
  Mysql主从复制架构图  
  ![Mysql主从复制架构图](https://img-blog.csdnimg.cn/f15462c6736b498f9acd3cf9f676cb9b.jpg?x-oss-process=image/watermark,type_ZHJvaWRzYW5zZmFsbGJhY2s,shadow_50,text_Q1NETiBAc2VuZHFtYWls,size_20,color_FFFFFF,t_70,g_se,x_16 "1")  
  主从复制原理
  ```bash
     1、Master数据库的bin-log(记录所有sql语句)文件只要发生变化,立马记录到Binary log日志文件中
     2、Slave数据库启动一个I/O thread连接Master数据库,请求Master变化的二进制日志
     3、SlaveI/O获取到的二进制日志,保存到自己的Relay log日志文件中
     4、Slave有一个SQL thread定时检查Realy log是否变化,变化那么就更新数据
  ```
- 主从同步原理
  ![同步](https://img-blog.csdnimg.cn/20200514112347655.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3llbWluZ182NjY=,size_16,color_FFFFFF,t_70 "f")
  ```bash
     1、在master上开启bin-log日志功能,记录更新、插入、删除的语句
     2、必须开启三个线程,主上开启io线程,从上开启io线程和sql线程
     3、从上io线程去连接master,master通过io线程检查有slave过来的请求,请求日志、postsion位置
     4、master将这些相应的日志返回给slave,slave自己去下载到本地的realy_log里面,写入一个master-info日志记录同步的点
     5、slave的sql线程检查到realy-log日志有更新,然后在本地去exec执行
  ```
- 主从复制方式
  ```bash
     1、异步模式(mysql async-mode)
        #是MySQL默认的复制方式,主库写入binlog,从库重写过程      
     2、半同步模式(mysql semi-sync)
        #MySQL5.5版本之后引入了半同步复制,从库接收完成主库传递过来的binlog内容已经写入到自己的relaylog后才会通知主库上面的等待线程
     3、全同步模式
        #是指主节点和从节点全部执行了commit并确认才会向客户端返回成功
     4、GTID复制
        #GTID又叫全局事务ID,是一个以提交事务的编号,并且是一个全局唯一的编号。GTID是由server_uuid和事务id组成
  ```
- 主从部署必要条件
  ```bash
     1、从库服务器能连通主库
     2、主库开启binlog日志（设置binlog参数）
     3、主从server-id不同
  ```
- binlog模式
  binlog文件的格式也有三种：STATEMENT、ROW、 MIXED
  基于SQL语句的复制(statement-based replication SBR);基于行的复制(row-based replication RBR);混合模式复制(mixed-based replication MBR) 
  ```bash
     1、STATMENT模式: 基于SQL语句的复制(statement-based replication, SBR),每一条会修改数据的sql语句会记录到binlog中
        #优点：不需要记录每一条SQL语句与每行的数据变化,这样子binlog的日志也会比较少,减少了磁盘IO,提高性能
        #缺点：有一些使用了函数之类的语句无法被记录复制。master与slave中的数据不一致(如sleep()函数等会出现问题)
     2、ROW模式: 基于行的复制(row-based replication, RBR)：不记录每一条SQL语句的上下文信息,仅需记录哪条数据被修改了,修改成了什么样了
        #优点：不会出现某些特定情况下的存储过程、或function、或trigger的调用和触发无法被正确复制的问题。
        #缺点：会产生大量的日志,尤其是alter table的时候会让日志暴涨。
     3、MIXED模式: 混合模式复制(mixed-based replication, MBR)：以上两种模式的混合使用
        #一般的复制使用STATEMENT模式保存binlog,对于STATEMENT模式无法复制的操作使用ROW模式保存binlog,MySQL会根据执行的SQL语句选择日志保存方式
  ```
### 3.5.2 MySQLMMM方案(双主多从)  
MMM是在MySQL Replication的基础上,对其进行优化。MMM(Master Replication Manager for MySQL)是双主多从结构  
是Google的开源项目,使用Perl语言来对MySQL Replication做扩展,提供一套支持双主故障切换和双主日常管理的脚本程序,主要用来监控mysql主主复制并做失败转移  
```bash
这里的双主节点,虽然叫做双主复制,但是业务上同一时刻只允许对一个主进行写入,另一台备选主上提供部分读服务,以加速在主主切换时刻备选主的预热 
优点：
    1.自动的主主Failover切换,一般3s以内切换备机
    2.多个从节点读的负载均衡
缺点
    1.无法完全保证数据的一致性。如主1挂了,MMM monitor已经切换到主2上来了,而若此时双主复制中,主2数据落后于主1(即还未完全复制完毕),那么此时的主2已经成为主节点,对外提供写服务,从而导致数据不一。
    2.由于是使用虚拟IP浮动技术,类似Keepalived,故RIP(真实IP)要和VIP(虚拟IP)在同一网段。如果是在不同网段也可以,需要用到虚拟路由技术。但是绝对要在同一个IDC机房,不可跨IDC机房组建集群
```
### 3.5.3 MySQLMHA架构(多主多从)  
```bash
   
```
