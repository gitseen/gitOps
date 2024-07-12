# Redis  
Redis是完全开源免费的,遵守BSD协议,是一个高性能的key-value数据库[多图深入理解 Redis](https://mp.weixin.qq.com/s/ESOQeQS9q-BCf1jmqAhgfQ)  
**Redis****特点**

```bash
1、        性能极高  Redis能读的速度是110000次/s,写的速度是81000次/s 。
2、        丰富的数据类型  Redis支持二进制案例的Strings、Lists、Hashes、Sets、Ordered Sets、zset 数据类型操作。
3、        原子 Redis的所有操作都是原子性；要么成功执行要么失败完全不执行。单个操作是原子性的。多个操作也支持事务,即原子性,通过MULTI和EXEC指令包起来。
4、        丰富的特性  Redis还支持publish/subscribe, 通知, key过期等特性。
```

## 1、Redis和memcache的区别,Redis支持的数据类型应用场景 
```bash
  1、数据类型 redis支持的数据结构更丰富(strings、hashes、lists、sets、zsets)  memcache只支持key-value的存储
  2、存储方式 Memecache把数据全部存在内存之中,断电后会丢失,数据不能超过内存大小。 Redis可以持久化数据
  3、使用底层模型不同,它们之间底层实现方式以及与客户端之间通信的应用协议不一样 Redis直接自己构建了VM机制
  4、value值大小同Redis最大可以达到512M; memcache只有1mb
  5、redis的速度比memcache快
  6、Redis支持数据的备份,即master-slave模式的数据备份
  7、redis原生支持集群,memcache没有原生的集群模式  
```
##  2、Redis单线程模型
redis 单线程处理请求流程  ![Alt text](https://p3-sign.toutiaoimg.com/tos-cn-i-qvj2lq49k0/908e6f8b82514599b49093f5dbb7cee0~noop.image?_iz=58558&from=article.pc_detail&x-expires=1667461922&x-signature=jWpKAwuhz0IBoN8Sk1Jikn4cGyY%3D "1")  

```bash
redis 采用IO多路复用机制来处理请求,采用reactorIO模型,处理流程如下
1、首先接收到客户端的socket请求,多路复用器将socket转给连接应答处理器；
2、连接应答处理器将AE_READABLE事件与命令请求处理器关联(这里是把socket事件放入一个队列)；
3、命令请求处理器从socket中读到指令,再内存中执行,并将AE_WRITEABLE事件与命令回复处理器关联；
4、命令回复处理器将结果返回给socket,并解除关联。
```
redis 单线程效率高的原因(单线程的redis为什么这么快)
```bash
1、非阻塞IO复用机制;I/O多路复用分派事件,事件处理器处理事件(这个可以理解为注册的一段函数,定义了事件发生的时候应该执行的动作),这里分派事件和处理事件其实都是同一个线程  
2、纯内存操作效率高
3、单线程避免了频繁的上下文切换
```
##  3、Redis过期策略
  -  对key设置有效期,redis的删除策略: 定期删除+惰性删除
```bash
1、定期删除指的是redis默认每100ms就随机抽取一些设置了过期事件的key,检查是否过期,如果过期就删除。如果redis设置了10万个key都设置了过期时间,
   每隔几百毫秒就要检查10万个key那CPU负载就很高了,所以redis并不会每隔100ms就检查所有的key,而是随机抽取一些key来检查 
2、但这样会导致有些key过期了并没有被删除,所以采取了惰性删除。意思是在获取某个key的时候发现过期了,如果key过期了就删除掉不会返回
```
  -  最大内存淘汰(maxmemory-policy)  
     如果redis内存占用太多,就会进行内存淘汰。有如下策略:
```bash
1、noeviction: 如果内存不足以写入数据,新写入操作直接报错；
2、allkeys-lru: 内存不足以写入数据,移除最近最少使用的key(最常用的策略)；
3、allkeys-random: 内存不足随机移除几个key；
4、volatile-lru: 在设置了过期时间的key中,移除最近最少使用；
5、volatile-random: 设置了过期的时间的key中,随机移除几个
```
##  4、Redis持久化
### 4.1 RDB
  -  RDB原理 
        RDB持久化（原理是将Reids在内存中的数据库记录定时dump到磁盘上的RDB持久化） 
        RDB持久化是指在指定的时间间隔内将内存中的数据集快照写入磁盘,实际操作过程是fork一个子进程,先将数据集写入临时文件,写入成功后,再替换之前的文件,用二进制压缩存储。 
        RDB(Redis DataBase)是将某一个时刻的内存快照(Snapshot),以二进制的方式写入磁盘的过程。  
        ```bash
         RDB有两种方式save和bgsave:  
            save: 执行就会触发Redis的持久化,但同时也是使Redis处于阻塞状态,直到RDB持久化完成,才会响应其他客户端发来的命令； 
            bgsave: bgsave会fork()一个子进程来执行持久化,整个过程中只有在fork()子进程时有短暂的阻塞,当子进程被创建之后,Redis的主进程就可以响应其他客户端的请求了。   
        ```
        RDB持久化 快照（snapshot）原理  
        ```bash
           在默认情况下,Redis将数据库快照保存在名字为dump.rdb的二进制文件中。你可以对Redis进行设置, 让它在“M秒内数据集至少有N个改动”这一条件被满足时,自动保存一次数据集。你也可以通过调用SAVE或者BGSAVE,手动让Redis进行数据集保存操作。这种持久化方式被称为快照。当Redis需要保存dump.rdb文件时,服务器执行以下操作:
             1        Redis创建一个子进程。
             2        子进程将数据集写入到一个临时快照文件中。
             3        当子进程完成对新快照文件的写入时,Redis用新快照文件替换原来的快照文件,并删除旧的快照文件。
        ```
  -  RDB配置
     除了使用save和bgsave命令触发之外, RDB支持自动触发。
     自动触发策略可配置Redis在指定的时间内,数据发生了多少次变化时,会自动执行bgsave命令。在redis配置文件中配置:
     ```bash
          在时间m秒内,如果Redis数据至少发生了n次变化,那么就自动执行BGSAVE命令。
          save m n  
          RDB持久化配置
            save 900 1         #在900秒(15分钟)之后,如果至少有1个key发生变化,则dump内存快照。
            save 300 10        #在300秒(5分钟)之后,如果至少有10个key发生变化,则dump内存快照。
            save 60 10000      #60秒(1分钟)之后,如果至少有10000个key发生变化,则dump内存快照。
     ```
  - RDB优缺点
    ```bash
       优点
          1  它保存了某个时间点的数据集,非常适用于数据集的备份(冷备)
          2  很方便传送到另一个远端数据中心（可能加密）,非常适用于灾难恢复
          3  RDB对redis对外提供读写服务的性能影响非常小,redis是通过fork主进程的一个子进程操作磁盘IO来进行持久化的(父不做IO操作可以最大化redis的性能)
          4  相对于AOF,基于RDB来恢复reids数据更快
       缺点
          1 使用RDB来恢复数据,会丢失一部分数据,因为RDB是定时生成的快照文件(必然做不到实时持久化;比如断电)
          2 快照是fork子进程来保存数据集到硬盘。当数据集大时,fork的过程是非常耗时的,会导致Redis在一些毫秒级内不能响应客户端的请求(影响对外提供服务)
    ```
### 4.2 AOF
  -  AOF原理[AOF原理](https://blog.csdn.net/ymb615ymb/article/details/123391983)
        AOF(append only file)持久化(原理是将Reids的操作日志以追加的方式写入文件） 
        AOF持久化以日志的形式记录服务器所处理的每一个写、删除操作,查询操作不会记录,以文本的方式记录,可以打开文件看到详细的操作记录。  
        AOF持久化原理 
        
        ```bash
        redis对每条写入命令进行日志记录,以append-only 的方式写入一个日志文件,redis重启的时候通过重放日志文件来恢复数据集;
        rewrite即把日志文件压缩,通过bgrewriteaof触发重写;
        AOF rewrite后台执行的方式和RDB有类似的地方,fork一个子进程,主进程仍进行服务,子进程执行AOF持久化,数据被dump到磁盘上;
        与RDB不同的是,后台子进程持久化过程中,主进程会记录期间的所有数据变更（主进程还在服务）,并存储在server.aof_rewrite_buf_blocks中
        后台子进程结束后,Redis更新缓存追加到AOF文件中,是 RDB 持久化所不具备的
           工作流程：
              1 Redis执行写命令后,把这个命令写入到AOF文件内存中（write系统调用）；
              2 Redis根据配置的 AOF 刷盘策略,把AOF内存数据刷到磁盘上（fsync系统调用）；
              3 根据rewrite相关的配置触发rewrite流程。
        ```
  -  AOF配置
        AOF持久化配置
        ```bash
             appendonly: 是否启用AOF(yes | no) 
             appendfsync: 刷盘的机制
               appendfsync always        #每次有数据修改发生时都会写入AOF文件。
               appendfsync everysec      #每秒钟同步一次,该策略为AOF的缺省策略。
               appendfsync no            #从不同步。高效但是数据不会被持久化。
             auto-laof-rewrite-percentage #当aof文件相较于上一版本的aof文件大小的百分比达到多少时触发AOF重写
             auto-aof-rewite-min-size    #最小能容忍aof文件大小,超过这个大小必须进行AOF重写；
             no-appendfsync-on-rewrite   #设置为yes表示rewrite期间对新写操作不fsync暂时存在内存中,等rewrite完成后再写入,默认为 no
        ```
  - AOF优缺点
    ```bash
       优点
          1 可以更好的保证数据不丢失(秒级持久化),一般AOF每隔1s通过一个后台线程来执行fsync(强制刷新磁盘页缓存),最多丢失1s的数据  
            #数据相对更可靠,丢失少,因可以配置每秒持久化、每个命令执行完就持久化  
          2 AOF以append-only的方式写入(顺序追加),没有磁盘寻址开销,性能很高;  
            #持久化的速度快,因为每次都只是追加,rdb每次都全量持久化  
          3 AOF即使文件很大,触发后台rewrite的操作的时候一般也不会影响客户端的读写(rewrite的时候会对其中指令进行压缩,创建出一份恢复需要的最小日志出来)。
       缺点
          1 同一份数据,因为AOF记录的命令会比RDB快照文件更大
            #灾难性恢复的时候过慢,因为aof每次都只追加原命令,导致aof文件过大,但是后面会rewrite,但是相对于rdb也是慢的
          2 AOF开启后,支持写的QPS会比RDB支持写的QPS要低,毕竟AOF有写磁盘的操作
            #会对主进程对外提供请求的效率造成影响,接收请求、处理请求、写aof文件这三步是串行原子执行的。而非异步多线程执行的Redis单线程
          
    ```
### 4.3 持久化总结： 
    AOF和RDB该如何选择：两者综合使用; 
    将AOF配置成每秒fsync一次。RDB作为冷备,AOF用来保证数据不丢失的恢复第一选择,当AOF文件损坏或不可用的时候还可以使用RDB来快速恢复。  

##  5、Redis集群
### 5.1 主从复制模式  
  -  基本原理
    主从复制模式中包含一个主数据库实例master与一个或多个从数据库实例slave如下图
    ![Alt text](https://img2020.cnblogs.com/other/632381/202003/632381-20200316092434553-1122086987.png "如图")  

  客户端可对主数据库进行读写操作,对从数据库进行读操作,主数据库写入的数据会实时自动同步给从数据库。具体工作机制为： 
  ```bash
     1 slave启动向master发送SYNC命令,master接收到SYNC命令后通过bgsave保存快照(即文所介绍的RDB持久化),并使用缓冲区记录保存快照这段时间内执行的写命令
     2 master将保存的快照文件发送给slave,并继续记录执行的写命令
     3 slave接收到快照文件后,加载快照文件,载入数据
     4 master快照发送完后开始向slave发送缓冲区的写命令,slave接收命令并执行,完成复制初始化
    5 此后master每次执行一个写命令都会同步发送给slave,保持master与slave之间数据的一致性
  ```
  -  主从复制的优缺点  
     ```bash
        优点：
           1 master能自动将数据同步到slave,可以进行读写分离,分担master的读压力  
           2 master、slave之间的同步是以非阻塞的方式进行的,同步期间,客户端仍然可以提交查询或更新请求 
        缺点： 
           1 不具备自动容错与恢复功能,master或slave的宕机都可能导致客户端请求失败,需要等待机器重启或手动切换客户端IP才能恢复
           2 master宕机,如果宕机前数据没有同步完,则切换IP后会存在数据不一致的问题
           3 难以支持在线扩容,Redis的容量受限于单机配置
     ```
  -  主从复制原理
     ```bash
          1 从服务器连接主服务器,发送SYNC命令；
          2 主服务器接收到SYNC命名后,开始执行BGSAVE命令生成RDB文件并使用缓冲区记录此后执行的所有写命令；
          3 主服务器BGSAVE执行完后,向所有从服务器发送快照文件,并在发送期间继续记录被执行的写命令；
          4 从服务器收到快照文件后丢弃所有旧数据,载入收到的快照；
          5 主服务器快照发送完毕后开始向从服务器发送缓冲区中的写命令；
          6 从服务器完成对快照的载入,开始接收命令请求,并执行来自主服务器缓冲区的写命令；
     ```
  -  主从同步流程
     主从同步流程图![Alt text](https://p3-sign.toutiaoimg.com/tos-cn-i-qvj2lq49k0/cda5a022bd764b129808181d03db5106~noop.image?_iz=58558&from=article.pc_detail&x-expires=1667461922&x-signature=GYDj2XyaYkTOdoZ9ItT%2FD8QTL5s%3D "图") 
     主从同步流程  
     ```bash
        1、当slave启动时会发送一个psync命令给master；
        2、如果是重新连接master,则master node会复制给slave缺少的那部分数据；
        3、如果是slave第一次连接master,则会触发一次全量复制(full resynchronization)。开始full resynchronization的时候,master会生成一份rdb 快照,同时将客户端命令缓存在内存,rdb生成完后,就发送给slave,slave先写入磁盘在加载到内存。然后master将缓存的命令发送给slave。
    ```
### 5.2 Sentinel哨兵模式  
Redis的主从复制下,一旦主节点由于故障不能提供服务,需要人工干预,对于很多应用场景这种故障处理的方法是无法接受的。Redis从2.8开始正式提供了Redis Sentinel(哨兵)架构来解决这个问题;  
哨兵模式基于主从复制模式,只是引入了哨兵来监控与自动处理故障。如图![Alt text](https://img2020.cnblogs.com/other/632381/202003/632381-20200316092434904-227928571.png "图")
  -  哨兵功能
     ```bash
        1 集群监控：负责监控master和slave是否正常工作  
          #监控(Monitoring)-Sentinel会不断地检查你的主服务器和从服务器是否运作正常
        2 消息通知：如果某个redis实例有故障, 哨兵负责发消息通知管理员 
          #提醒(Notification)-当被监控的某个Redis服务器出现问题时,Sentinel可以通过API向管理员或者其他应用程序发送通知
        3 故障转移: 如果master、node发生故障,会自动切换到slave  
          #自动故障迁移（Automatic failover）
        4 配置中心：如果故障转移发生了,通知客户端新的master地址
     ```
  -  哨兵核心知识
     ```bash
        1 哨兵至少三个,保证自己的高可用
        2 哨兵+主从的部署架构是用来保证 redis 集群高可用的,并非保证数据不丢失
        3 哨兵(Sentinel)需要通过不断的测试和观察才能保证高可用
      哨兵模式的优缺点
         优点：
             1 哨兵模式基于主从复制模式,所以主从复制模式有的优点,哨兵模式也有
             2 哨兵模式下,master挂掉可以自动进行切换,系统可用性更高
        缺点：
             1 同样也继承了主从模式难以在线扩容的缺点,Redis的容量受限于单机配置
             2 需要额外的资源来启动sentinel进程,实现相对复杂一点,同时slave节点作为备份节点不提供服务
     ```
 -  哨兵核心底层原理
     哨兵模式工作机制[机制](https://www.cnblogs.com/spec-dog/p/12501895.html?share_token=861EDD38-711C-40D5-AF88-BB0EB15FA361)
     ```bash
        1 sdown和odown两种失败状态
          #sdown是主观宕机,就是一个哨兵觉得master宕机了,达成条件是如果一个哨兵ping master超过了is-master-down-after-milliseconds指定的毫秒数后就认为主观宕机
          #odown是客观宕机,如果一个哨兵在指定时间内收到了majority(大多数)数量的哨兵也认为那个master宕机了,就是客观宕机
        2 哨兵之间的互相发现:哨兵是通过redis的pub/sub实现  
     ```

### 5.3 Cluster模式  
在主从部式上,虽然实现了一定程度的高并发,并保证了高可用,但是有如下限制
    #master数据和slave数据一模一样,master的数据量就是集群的限制瓶颈
    #redis 集群的写能力也受到了master节点的单机限制 
哨兵模式解决了主从复制不能自动故障转移,达不到高可用的问题,但还是存在难以在线扩容,Redis容量受限于单机配置的问题
Cluster模式实现了Redis的分布式存储,即每台节点存储不同的内容,来解决在线扩容的问题(去中心化结构)在高版本的Redis已经原生支持集群(cluster)模式,可以多master多slave部署,横向扩展Redis集群的能力。
RedisCluster支持N个master node ,每个master node可以挂载多个slave node
  -  基本原理
     Cluster采用无中心结构；Cluster模式的具体工作机制
     ```bash
     Cluster采用无中心结构,它的特点如下：
        1 所有的redis节点彼此互联(PING-PONG机制),内部使用二进制协议优化传输速度和带宽
        2 节点的fail是通过集群中超过半数的节点检测失效时才生效
        3 客户端与redis节点直连,不需要中间代理层.客户端不需要连接集群所有节点,连接集群中任何一个可用节点即可
    Cluster模式的具体工作机制：
        1 在Redis的每个节点上,都有一个插槽（slot）,取值范围为0-16383
        2 当我们存取key的时候,Redis会根据CRC16的算法得出一个结果,然后把结果对16384求余数,这样每个key都会对应一个编号在0-16383之间的哈希槽,通过这个值,去找到对应的插槽所对应的节点,然后直接自动跳转到这个对应的节点上进行存取操作
        3 为了保证高可用,Cluster模式也引入主从复制模式,一个主节点对应一个或者多个从节点,当主节点宕机的时候,就会启用从节点
        4 当其它主节点ping一个主节点A时,如果半数以上的主节点与A通信超时,那么认为主节点A宕机了。如果主节点A和它的从节点都宕机了,那么该集群就无法再提供服务了
    #Cluster模式集群节点最小配置6个节点(3主3从,因为需要半数以上),其中主节点提供读写操作,从节点作为备用节点,不提供请求,只作为故障转移使用。
    ```
  -  Cluster模式优缺点
     ```bash
     优点：
        1 无中心架构,数据按照slot分布在多个节点。
        2 集群中的每个节点都是平等的关系,每个节点都保存各自的数据和整个集群的状态。每个节点都和其他所有节点连接,而这些连接保持活跃,这样保证了我们只需连接集群中的任意一个节点,就可以获取到其他节点的数据。
        3 可线性扩展到1000多个节点,节点可动态添加或删除
        4 能够实现自动故障转移,节点之间通过gossip协议交换状态信息,用投票机制完成slave到master的角色转换
     缺点：
        1 客户端实现复杂,驱动要求实现Smart Client,缓存slots mapping信息并及时更新,提高了开发难度。目前仅JedisCluster相对成熟,异常处理还不完善,比如常见的“max redirect exception”
        2 节点会因为某些原因发生阻塞（阻塞时间大于 cluster-node-timeout）被判断下线,这种failover是没有必要的
        3 数据通过异步复制,不保证数据的强一致性
        4 slave充当“冷备”,不能缓解读压力
        5 批量操作限制,目前只支持具有相同slot值的key执行批量操作,对mset、mget、sunion等操作支持不友好
        6 key事务操作支持有线,只支持多key在同一节点的事务操作,多key分布不同节点时无法使用事务功能
        7 不支持多数据库空间,单机redis可以支持16个db,集群模式下只能使用一个,即db0
    #Redis Cluster模式不建议使用pipeline和multi-keys操作,减少max redirect产生的场景。
    ```

  -  Cluster简介
     ```bash
        1 自动将数据切片,每个master上放一部分数据
        2 提供内置的高可用支持,部分master不可用时还是能够工作
        3 RedisCluster模式下每个redis要开放两个端口6379和10000+以后的端口(如16379)是用来节点之间通信的,使用的是cluster bus集群总线。cluster bus用来做故障检测,配置更新,故障转移授权。
     ```
  -  Cluster负载均衡
     ```bash
        RedisCluster采用一致性hash+虚拟节点来负载均衡
        rediscluster有固定的16384个slot(2^14),对每个key做CRC16值计算,然后对16384mod。可以获取每个key的slot
        rediscluster每个master都会持有部分slot,比如三个master那么每个master就会持有5000 多个slot;
        #hash lot让node的添加和删除变得很简单,增加一个master,就将其他master的slot移动部分过去,减少一个就分给其他master,这样让集群扩容的成本变得很低。
     ```
  -  Cluster基础通信原理(gossip协议)
     ```bash
        1 与集中式不同(用ZK进行分布式协调注册),RedisCluster使用的是gossip协议进行通信。并不是将集群元数据存储在某个节点上,而是不断的互相通信,保持整个集群的元数据是完整的
          #gossip协议所有节点都持有一份元数据,不同节点的元数据发生了变更,就不断的将元数据发送给其他节点,让其他节点也进行元数据的变更
        2 集中式的好处：元数据的读取和更新时效性很好,一旦元数据变化就更新到集中式存储,缺点就是元数据都在一个地方,可能导致元数据的存储压力
        3 对于gossip来说：元数据的更新会有延时,会降低元数据的压力,缺点是操作是元数据更新可能会导致集群的操作有一些滞后
     ```
  -  Cluster主备切换与高可用
     ```bash
        1 判断节点宕机：如果有一个节点认为另外一个节点宕机,那就是pfail主观宕机。如果多个节点认为一个节点宕机,那就是fail,客观宕机。跟哨兵的原理一样
        2 对宕机的master从其所有的slave中选取一个切换成master node,再次之前会进行一次过滤,检查每个slave与master的断开时间,如果超过了cluster-node-timeout*cluster-slave-validity-factor 就没有资格切换成master
        3 从节点选取：每个从节点都会根据从master复制数据的offset,来设置一个选举时间,offset 越大的从节点,选举时间越靠前,master node开始给slave选举投票,如果大部分master(n/2+1)都投给了某个slave,那么选举通过(与zk有点像,选举时间类似于epochid)
        4 整个流程与哨兵类似,可以说rediscluster集成了哨兵的功能,更加的强大
        5 Redis集群部署相关问题redis机器的配置,多少台机器,能达到多少qps
            #机器标准:8 核+32G
            #集群: 5 主+5 从(每个 master 都挂一个 slave)
            #效果: 每台机器最高峰每秒大概5W,5台机器最多就是25W,每个master都有一个从节点,任何一个节点挂了都有备份可切换成主节点进行故障转移
        6 脑裂问题哨兵模式下:
            #master下挂载了3个slave,如果master由于网络抖动被哨兵认为宕机了,执行了故障转移,从slave里面选取了一个作为新的master,这个时候老的master又恢复了,刚好又有client连的还是老的master,就会产生脑裂,数据也会不一致,比如incr全局id也会重复。
            #redis对此的解决方案是min-slaves-to-write 1至少有一个slave连接min-slaves-max-lag 10 slave与master主从复制延迟时间如果连接到master的slave数小于最少slave的数量,并且主从复制延迟时间超过配置时间,master就拒绝写入
            #client连接redis多tcp连接的考量首先redisserver虽然是单线程来处理请求, 但是他是多路复用的, 单tcp连接肯定是没有多tcp连接性能好, 多路复用一个io周期得到的就绪io事件越多,处理的就越多。这也不是绝对的,如果使用pipeline的方式传输,单连接会比多连接性能好,因为每一个pipeline的单次请求过多也会导致单周期到的命令太多,性能下降多少个连接比较合适这个问题,rediscluser控制在每个节点100个连接以内
     ```

##  6、Redis总结     
Redis集群方案的三种模式,其中主从复制模式能实现读写分离,但是不能自动故障转移  
Sentinel哨兵模式基于主从复制模式,能实现自动故障转移,达到高可用,但与主从复制模式一样,不能在线扩容,容量受限于单机的配置  
Cluster模式通过无中心化架构,实现分布式存储,可进行线性扩展,也能高可用,但对于像批量操作、事务操作等的支持性不够好。三种模式各有优缺点(可根据实际场景进行选择)  

# Redis面试试题
知识点总结思维导图 ![Alt text](https://imgconvert.csdnimg.cn/aHR0cHM6Ly93d3cua2FpY3ouY29tL3VlZGl0b3IvcGhwL3VwbG9hZC9pbWFnZS8yMDIwMDExNS8xNTc5MDgyNzQ3MjI4NjQ0LmpwZw?x-oss-process=image/format,png "导图") 
面试试题 [from](https://blog.csdn.net/qq_14887565/article/details/103994088?share_token=BADDD7D0-16D6-4B85-B575-A32678BED965)  
```bash
1、什么是Redis?
Redis是完全开源免费的,遵守BSD协议,是1个高性能的key-value数据库。

Redis与其他key-value缓存产品有以下三个特点：
（1）Redis支持数据的持久化,可以将内存中的数据保存在磁盘中,重启的时候可以再次加载进行应用
（2）Redis不仅仅支持简单的key-value类型的数据,同时还提供list,set,zset,hash等数据结构的存储
（3）Redis支持数据的备份,即master-slave模式的数据备份

Redis优越性
（1）性能极高–Redis能读的速度是110000次/s,写的速度是81000次/s。
（2）丰富的数据类型–Redis支持二进制案例的Strings,Lists,Hashes,Sets及OrderedSets数据类型操作。
（3）原子–Redis的所有操作都是原子性的,意思就是要么成功执行要么失败完全不执行。单个操作是原子性的。多个操作也支持事务,即原子性,通过MULTI和EXEC指令包起来。
（4）丰富的特性–Redis还支持publish/subscribe,通知,key过期等等特性。

Redis与其他key-value存储有什么不同？
（1）Redis有着更为复杂的数据结构并且提供对他们的原子性操作,这是1个不同于其他数据库的进化路径。Redis的数据类型都是基于基本数据结构的同时对程序员透明,无需进行额外的抽象。
（2）Redis运行在内存中但是可以持久化到磁盘,所以在对不同数据集进行高速读写时需要权衡内存,因为数据量不能大于硬件内存。在内存数据库方面的另一个优点是,相比在磁盘上相同的复杂的数据结构,在内存中操作起来非常简单,这样Redis可以做很多内部复杂性很强的事情。同时,在磁盘格式方面他们是紧凑的以追加的方式产生的,因为他们并不需要进行随机访问。

2、Redis的基本数据类型？
答：Redis支持五种数据类型：string（字符串）,hash（哈希）,list（列表）,set（集合）及zsetsortedset：有序集合)。
我们实际项目中比较常用的是string,hash如果你是Redis中高级用户,还需要加上下面几种数据结构HyperLogLog、Geo、Pub/Sub。
倘若你说还玩过RedisModule,像BloomFilter,RedisSearch,Redis-ML,面试官得眼睛就开始发亮了。

3、应用Redis有哪些好处？
（1）速度快,因为数据存在内存中,类似于HashMap,HashMap的优越性就是查找和操作的时间复杂度都是O1)
（2）支持丰富数据类型,支持string,list,set,Zset,hash等
（3）支持事务,操作都是原子性,所谓的原子性就是对数据的更改要么全部执行,要么全部不执行
（4）丰富的特性：可用于缓存,消息,按key设置过期时间,过期后将会自动删除

4、Redis相比Memcached有哪些优越性？
（1）Memcached所有的值均是简单的字符串,redis作为其替代者,支持更为丰富的数据类
（2）Redis的速度比Memcached快很
（3）Redis可以持久化其数据

5、Memcache与Redis的区别都有哪些？
（1）存储方式Memecache把数据全部存在内存之中,断电后会挂掉,数据不能超过内存大小。Redis有部份存在硬盘上,这样能保证数据的持久性。
（2）数据支持类型Memcache对数据类型支持相对简单。Redis有复杂的数据类型。
（3）应用底层模型不同它们之间底层实现方式以及与客户端之间通信的应用协议不一样。Redis直接自己构建了VM机制,因为一般的系统调用系统函数的话,会浪费一定的时间去移动和请求。

6、Redis 是单进程单线程的？
答：Redis 是单进程单线程的,redis 利用队列技术将并发访问变为串行访问,消除了传统数据库串行控制的开销。

7、一个字符串类型的值能存储最大容量是多少？
答：512M

8、Redis的持久化机制是什么？各自的优缺点？
   Redis提供两种持久化机制RDB和AOF机制:
   1、RDBRedisDataBase)持久化方式：
   是指用数据集快照的方式半持久化模式)记录redis数据库的所有键值对,在某个时间点将数据写入一个临时文件,持久化结束后,用这个临时文件替换上次持久化的文件,达到数据恢复。
   优点：
    （1）只有一个文件dump.rdb,方便持久化。
    （2）容灾性好,一个文件可以保存到安全的磁盘。
    （3）性能最大化,fork子进程来完成写操作,让主进程继续处理命令,所以是IO最大化。使用单独子进程来进行持久化,主进程不会进行任何IO操作,保证了redis的高性能)
    （4）相对于数据集大时,比AOF的启动效率更高。
   缺点：
      数据安全性低。RDB是间隔一段时间进行持久化,如果持久化之间redis发生故障,会发生数据丢失。所以这种方式更适合数据要求不严谨的时候
   2、AOFAppend-onlyfile)持久化方式：
      是指所有的命令行记录以redis命令请求协议的格式完全持久化存储)保存为aof文件。
   优点：
    （1）数据安全,aof持久化可以配置appendfsync属性,有always,每进行一次命令操作就记录到aof文件中一次。
    （2）通过append模式写文件,即使中途服务器宕机,可以通过redis-check-aof工具解决数据一致性问题。
    （3）AOF机制的rewrite模式。AOF文件没被rewrite之前（文件过大时会对命令进行合并重写）,可以删除其中的某些命令（比如误操作的flushall）)
   缺点：
    （1）AOF文件比RDB文件大,且恢复速度慢。
    （2）数据集大的时候,比rdb启动效率低。

9、Redis常见性能问题和解决方案：
（1）Master最好不要写内存快照,如果Master写内存快照,save命令调度rdbSave函数,会阻塞主线程的工作,当快照比较大时对性能影响是非常大的,会间断性暂停服务
（2）如果数据比较重要,某个Slave开启AOF备份数据,策略设置为每秒同步一
（3）为了主从复制的速度和连接的稳定性,Master和Slave最好在同一个局域网
（4）尽量避免在压力很大的主库上增加从
（5）主从复制不要用图状结构,用单向链表结构更为稳定,即：Master<-Slave1<-Slave2<-Slave3…这样的结构方便解决单点故障问题,实现Slave对Master的替换。如果Master挂了,可以立刻启用Slave1做Master,其他不变。

10、Redis过期键的删除策略？
（1）定时删除:在设置键的过期时间的同时,创建一个定时器timer).让定时器在键的过期时间来临时,立即执行对键的删除操作。
（2）惰性删除:放任键过期不管,但是每次从键空间中获取键时,都检查取得的键是否过期,如果过期的话,就删除该键;如果没有过期,就返回该键。
（3）定期删除:每隔一段时间程序就对数据库进行一次检查,删除里面的过期键。至于要删除多少过期键,以及要检查多少个数据库,则由算法决定。

11、Redis的回收策略（淘汰策略）?
volatile-lru：从已设置过期时间的数据集（server.db[i].expires）中挑选最近最少使用的数据淘汰
volatile-ttl：从已设置过期时间的数据集（server.db[i].expires）中挑选将要过期的数据淘汰
volatile-random：从已设置过期时间的数据集（server.db[i].expires）中任意选择数据淘汰
allkeys-lru：从数据集（server.db[i].dict）中挑选最近最少使用的数据淘汰
allkeys-random：从数据集（server.db[i].dict）中任意选择数据淘汰
no-enviction（驱逐）：禁止驱逐数据
    注意这里的6种机制,volatile和allkeys规定了是对已设置过期时间的数据集淘汰数据还是从全部数据集淘汰数据,后面的lru、ttl以及random是三种不同的淘汰策略,再加上一种no-enviction永不回收的策略。
使用策略规则：
 （1）如果数据呈现幂律分布,也就是一部分数据访问频率高,一部分数据访问频率低,则使用allkeys-lru
 （2）如果数据呈现平等分布,也就是所有的数据访问频率都相同,则使用allkeys-random

12、为什么Redis需要把所有数据放到内存中？
    Redis 为了达到最快的读写速度将数据都读到内存中,并通过异步的方式将数据写入磁盘。所以 redis 具有快速和数据持久化的特征。如果不将数据放在内存中,磁盘 I/O 速度为严重影响 redis 的性能。在内存越来越便宜的今天,redis 将会越来越受欢迎。如果设置了最大使用的内存,则数据已有记录数达到内存限值后不能继续插入新值。

13、Redis的同步机制了解么？   
    Redis 可以使用主从同步,从从同步。第一次同步时,主节点做一次 bgsave,并同时将后续修改操作记录到内存 buffer,待完成后将 rdb 文件全量同步到复制节点,复制节点接受完成后将 rdb 镜像加载到内存。加载完后,再通知主节点将期间修改的操作记录同步到复制节点进行重放就完成了同步过程。

14、Pipeline 有什么好处,为什么要用 pipeline？
    可以将多次 IO 往返的时间缩减为一次,前提是 pipeline 执行的指令之间没有因果相关性。使用 redis-benchmark 进行压测的时候可以发现影响 redis 的 QPS峰值的一个重要因素是 pipeline 批次指令的数目。

15、是否使用过Redis集群,集群的原理是什么？
（1）Redis Sentinal 着眼于高可用,在 master 宕机时会自动将 slave 提升为master,继续提供服务。
（2）Redis Cluster 着眼于扩展性,在单个 redis 内存不足时,使用 Cluster 进行分片存储。

16、Redis 集群方案什么情况下会导致整个集群不可用？
有 A,B,C 三个节点的集群,在没有复制模型的情况下,如果节点 B 失败了,那么整个集群就会以为缺少 5501-11000 这个范围的槽而不可用。

17、Redis 支持的 Java 客户端都有哪些？官方推荐用哪个？
Redisson、Jedis、lettuce 等等,官方推荐使用 Redisson。

18、Jedis与Redisson对比有什么优缺点？
   Jedis是Redis的Java实现的客户端,其API提供了比较全面的Redis命令的支持；Redisson实现了分布式和可扩展的Java数据结构,和Jedis相比,功能较为简单不支持字符串操作,不支持排序、事务、管道、分区等Redis特性。
   Redisson的宗旨是促进使用者对Redis的关注分离,从而让使用者能够将精力更集中地放在处理业务逻辑上。

19、Redis如何设置密码及验证密码？
设置密码：config set requirepass 123456
授权密码：auth 123456

20、说说Redis哈希槽的概念？
Redis集群没有使用一致性hash,而是引入了哈希槽的概念,Redis集群有16384个哈希槽,每个key通过CRC16校验后对16384取模来决定放置哪个槽,集群的每个节点负责一部分hash槽。

21、Redis 集群的主从复制模型是怎样的？
    为了使在部分节点失败或者大部分节点无法通信的情况下集群仍然可用,所以集群使用了主从复制模型,每个节点都会有 N-1 个复制品.

22、Redis集群会有写操作丢失吗？为什么？
    Redis并不能保证数据的强一致性,这意味这在实际中集群在特定的条件下可能会丢失写操作。

23、Redis集群之间是如何复制的？
    异步复制

24、Redis集群最大节点个数是多少？
     16384 个。

25、Redis集群如何选择数据库？
    Redis集群目前无法做数据库选择,默认在0数据库。

26、怎么测试Redis的连通性？
    使用ping命令。

27、怎么理解Redis事务？
   （1）事务是一个单独的隔离操作：事务中的所有命令都会序列化、按顺序地执行。事务在执行的过程中,不会被其他客户端发送来的命令请求所打断。
   （2）事务是一个原子操作：事务中的命令要么全部被执行,要么全部都不执行。

28、Redis 事务相关的命令有哪几个？
    MULTI、EXEC、DISCARD、WATCH

29、Redis-key的过期时间和永久有效分别怎么设置？
    EXPIRE和PERSIST 命令。

30、Redis 如何做内存优化？
    尽可能使用散列表（hashes）,散列表（是说散列表里面存储的数少）使用的内存非常小,所以你应该尽可能的将你的数据模型抽象到一个散列表里面。比如你的web系统中有一个用户对象,不要为这个用户的名称,姓氏,邮箱,密码设置单独的key,而是应该把这个用户的所有信息存储到一张散列表里面。

31、Redis 回收进程如何工作的？
    一个客户端运行了新的命令,添加了新的数据。Redi 检查内存使用情况,如果大于 maxmemory 的限制, 则根据设定好的策略进行回收。一个新的命令被执行,等等。所以我们不断地穿越内存限制的边界,通过不断达到边界然后不断地回收回到边界以下。如果一个命令的结果导致大量内存被使用（例如很大的集合的交集保存到一个新的键）,不用多久内存限制就会被这个内存使用量超越。

32、都有哪些办法可以降低Redis的内存使用情况呢？
    如果你使用的是32位的Redis实例,可以好好利用Hash,list,sorted set,set等集合类型数据,因为通常情况下很多小的key-Value可以用更紧凑的方式存放到一起。

33、Redis 的内存用完了会发生什么？
    如果达到设置的上限,Redi的写命令会返回错误信息（但是读命令还可以正常返回。）或者你可以将Redis当缓存来使用配置淘汰机制,当Redis达到内存上限时会冲刷掉旧的内容。

34、一个 Redis 实例最多能存放多少的 keys？List、Set、Sorted Set 他们最多能存放多少元素？
    理论上Redis可以处理多达232的keys,并且在实际中进行了测试,每个实例至少存放了2亿5千万的keys。我们正在测试一些较大的值。任何 list、set、和 sorted set 都可以放 232 个元素。换句话说,Redis的存储极限是系统中的可用内存值。

35、MySQL里有2000w数据,redis中只存20w的数据,如何保证redis中的数据都是热点数据？
    Redis内存数据集大小上升到一定大小的时候,就会施行数据淘汰策略。
    相关知识：Redis 提供 6 种数据淘汰策略：
       volatile-lru：从已设置过期时间的数据集（server.db[i].expires）中挑选最近最少使用的数据淘汰
       volatile-ttl：从已设置过期时间的数据集（server.db[i].expires）中挑选将要过期的数据淘汰
       volatile-random：从已设置过期时间的数据集（server.db[i].expires）中任意选择数据淘汰
       allkeys-lru：从数据集（server.db[i].dict）中挑选最近最少使用的数据淘汰
       allkeys-random：从数据集（server.db[i].dict）中任意选择数据淘汰
       no-enviction（驱逐）：禁止驱逐数据

36、Redis最合适的场景？
1、会话缓存（Session Cache）
    最常用的一种使用Redis的情景是会话缓存（session cache）。用Redis缓存会话比其他存（如Memcached）的优势在于：Redis提供持久化。当维护一个不是严格要求一致性的缓存时,如果用户的购物车信息全部丢失,大部分人都会不高兴的,现在,他们还会这样吗？ 幸运的是,随着 Redis 这些年的改进,很容易找到怎么恰当的使用 Redis 来缓存会话的文档。甚至广为人知的商业平台Magento 也提供 Redis 的插件。
2、全页缓存（FPC）
    除基本的会话token之外,Redis还提供很简便的FPC平台。回到一致性问题,即使重启了Redis实例,因为有磁盘的持久化,用户也不会看到页面加载速度的下降,这是一个极大改进,类似PHP本地FPC。 再次以Magento为例,Magento提供一个插件来使用Redis作为全页缓存后端。 此外,对WordPress的用户来说,Pantheon有一个非常好的插件wp-redis,这个插件能帮助你以最快速度加载你曾浏览过的页面。
3、队列
    Reids 在内存存储引擎领域的一大优点是提供list和set 操作,这使得Redis能作为一个很好的消息队列平台来使用。Redis作为队列使用的操作,就类似于本地程序语言（如Python）对list的push/pop 操作。 如果你快速的在 Google中搜索“Redis queues”,你马上就能找到大量的开源项目,这些项目的目的就是利用Redis创建非常好的后端工具,以满足各种队列需求。例如Celery有一个后台就是使用Redis作为broker,你可以从这里去查看。
4,排行榜/计数器
    Redis 在内存中对数字进行递增或递减的操作实现的非常好。集合（Set）和有序集合（Sorted Set）也使得我们在执行这些操作的时候变的非常简单,Redis 是正好提供了这两种数据结构。所以,我们要从排序集合中获取到排名最靠前的 10个用户–我们称之为“user_scores”,我们只需要像下面一样执行即可： 当然,这是假定你是根据你用户的分数做递增的排序。如果你想返回用户及用户的分数,你需要这样执行：ZRANGE user_scores 0 10 WITHSCORES Agora Games 就是一个很好的例子,用 Ruby 实现的,它的排行榜就是使用 Redis 来存储数据的,你可以在这里看到。
5、发布/订阅
    最后（但肯定不是最不重要的）是Redis的发布/订阅功能。发布/订阅的使用场景确实非常多。我已看见人们在社交网络连接中使用,还可作为基于发布/订阅的脚本触发器,甚至用Redis的发布/订阅功能来建立聊天系统！

37、假如Redis里面有1 亿个key,其中有10w个key是以某个固定的已知的前缀开头的,如果将它们全部找出来？
    使用keys指令可以扫出指定模式的key列表。
    对方接着追问：如果这个redis正在给线上的业务提供服务,那使用keys指令会有什么问题？
      这个时候你要回答redis关键的一个特性：redis的单线程的。keys指令会导致线程阻塞一段时间,线上服务会停顿,直到指令执行完毕,服务才能恢复。这个时候可以使用scan指令,sca 指令可以无阻塞的提取出指定模式的 key列表,但是会有一定的重复概率,在客户端做一次去重就可以了,但是整体所花费的时间会比直接用keys指令长。

38、如果有大量的key需要设置同一时间过期,一般需要注意什么？
    如果大量的key过期时间设置的过于集中,到过期的那个时间点,redis可能会出现短暂的卡顿现象。一般需要在时间上加一个随机值,使得过期时间分散一些。

39、使用过Redis做异步队列么,你是怎么用的？
    一般使用list结构作为队列,rpush生产消息,lpop消费消息。当lpop没有消息的时候,要适当sleep一会再重试。如果对方追问可不可以不用sleep呢？list还有个指令叫blpop,在没有消息的时候,它会阻塞住直到消息到来。如果对方追问能不能生产一次消费多次呢？使用pub/sub 主题订阅者模式,可以实现1:N 的消息队列。
   如果对方追问pub/sub有什么缺点？
       在消费者下线的情况下,生产的消息会丢失,得使用专业的消息队列如 RabbitMQ等。
   如果对方追问 redis 如何实现延时队列？
       我估计现在你很想把面试官一棒打死如果你手上有一根棒球棍的话,怎么问的这么详细。但是你很克制,然后神态自若的回答道：使用sortedset,拿时间戳作为score,消息内容作为 key调用zadd来生产消息,消费者用 zrangebyscore指令获取N秒之前的数据轮询进行处理。到这里,面试官暗地里已经对你竖起了大拇指。但是他不知道的是此刻你却竖起了中指,在椅子背后。

40、使用过Redis分布式锁么,它是什么回事？
    先拿setnx来争抢锁,抢到之后,再用expire给锁加一个过期时间防止锁忘记了释放。
41、为什么 Redis 的吞吐量能这么高？  
    https://juejin.cn/post/6844904082176475144  
    

>Notice:Redis持久化rdb和aof都开启  


```
