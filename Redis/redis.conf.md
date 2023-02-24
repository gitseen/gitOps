# redis.conf
```
# Redis configuration file example.
#
# Note that in order to read the configuration file, Redis must be
# started with the file path as first argument:
# 要使用redis的这个配置文件，配置文件路径必须是redis-server的第一个参数
#
# ./redis-server /path/to/redis.conf

# Note on units: when memory size is needed, it is possible to specify
# it in the usual form of 1k 5GB 4M and so forth:
#
# 1k => 1000 bytes
# 1kb => 1024 bytes
# 1m => 1000000 bytes
# 1mb => 1024*1024 bytes
# 1g => 1000000000 bytes
# 1gb => 1024*1024*1024 bytes
# 
# 注意单位的区别，不带b的是1000进制
#
# units are case insensitive so 1GB 1Gb 1gB are all the same.
# 单位是大小写不敏感的

################################## INCLUDES ###################################

# Include one or more other config files here.  This is useful if you
# have a standard template that goes to all Redis servers but also need
# to customize a few per-server settings.  Include files can include
# other files, so use this wisely.
# 可以引入一个或多个配置文件。
# 如果你有一个标准模板，然后只有少量参数需要进行调整的情况下，这个include就很方便
# 引入的文件还可以再继续引入文件
#
# Notice option "include" won't be rewritten by command "CONFIG REWRITE"
# from admin or Redis Sentinel. Since Redis always uses the last processed
# line as value of a configuration directive, you'd better put includes
# at the beginning of this file to avoid overwriting config change at runtime.
#
# 注意：引入的文件不能被"CONFIG REWRITE"命令重写。
# 因为redis对于同一个配置总是使用最后一个配置参数。
# 所以你最好将include的配置文件放在前面，避免覆盖你在运行时进行的配置变更
#
# If instead you are interested in using includes to override configuration
# options, it is better to use include as the last line.
# 同理，如果你就是想要让include进来的配置覆盖其他的配置
# 就可以将include写在最后面
#
# include /path/to/local.conf
# include /path/to/other.conf

################################## MODULES #####################################

# Load modules at startup. If the server is not able to load modules
# it will abort. It is possible to use multiple loadmodule directives.
# redis4开始支持自定义扩展模块
# 在启动时加载
#
# loadmodule /path/to/my_module.so
# loadmodule /path/to/other_module.so

################################## NETWORK #####################################

# By default, if no "bind" configuration directive is specified, Redis listens
# for connections from all the network interfaces available on the server.
# It is possible to listen to just one or multiple selected interfaces using
# the "bind" configuration directive, followed by one or more IP addresses.
# 如果没有配置bind参数，redis将监听本机所有网卡的连接
# 可以通过配置bind参数来限定只监听某个或某几个网卡的连接
# 多说一句，bind后面配的是本机ip，不是外部要访问redis的哪些机器的ip
# 所以通常的配置是bind 本机对外ip 127.0.0.1
# 这样允许外部通过ip访问redis，也允许本机访问redis
# Examples:
#
# bind 192.168.1.100 10.0.0.1
# bind 127.0.0.1 ::1
#
# ~~~ WARNING ~~~ If the computer running Redis is directly exposed to the
# internet, binding to all the interfaces is dangerous and will expose the
# instance to everybody on the internet. So by default we uncomment the
# following bind directive, that will force Redis to listen only into
# the IPv4 loopback interface address (this means Redis will be able to
# accept connections only from clients running into the same computer it
# is running).
# 警告，如果允许redis的服务器直接连到了外网，监听所有是很危险的
# 所以默认情况下，我们没有注释掉bind 127.0.0.1
# 这样就只允许本机的连接
# 
# IF YOU ARE SURE YOU WANT YOUR INSTANCE TO LISTEN TO ALL THE INTERFACES
# JUST COMMENT THE FOLLOWING LINE.
# 如果你确定要开放给所有的连接，只需要注释掉这行
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
bind 127.0.0.1

# Protected mode is a layer of security protection, in order to avoid that
# Redis instances left open on the internet are accessed and exploited.
# 保护模式是一层保护机制，避免redis被访问和利用
#
# When protected mode is on and if:
#
# 1) The server is not binding explicitly to a set of addresses using the
#    "bind" directive.
# 2) No password is configured.
#
# The server only accepts connections from clients connecting from the
# IPv4 and IPv6 loopback addresses 127.0.0.1 and ::1, and from Unix domain
# sockets.
# 如果保护模式打开（默认就是）
# 并且没有配置bind限定可连接的ip
# 也没有配置密码
# 那么这个redis将只允许本机访问
# 
# By default protected mode is enabled. You should disable it only if
# you are sure you want clients from other hosts to connect to Redis
# even if no authentication is configured, nor a specific set of interfaces
# are explicitly listed using the "bind" directive.
# 保护模式默认就是打开的，只有你确定你不需要安全认证就可以允许其他主机连接时才可关闭
# 建议不要关闭安全模式。
protected-mode yes

# Accept connections on the specified port, default is 6379 (IANA #815344).
# If port 0 is specified Redis will not listen on a TCP socket.
# redis的监听端口
# 如果设置为0，将不会监听tcp的socket
port 6379

# TCP listen() backlog.
#
# In high requests-per-second environments you need an high backlog in order
# to avoid slow clients connections issues. Note that the Linux kernel
# will silently truncate it to the value of /proc/sys/net/core/somaxconn so
# make sure to raise both the value of somaxconn and tcp_max_syn_backlog
# in order to get the desired effect.
# tcp的连接队列长度
# Linux内核为每个TCP服务器程序维护两条backlog队列，一条是TCP层的未连接队列，一条是应用层的已连接队列，分别对应net.ipv4.tcp_max_syn_backlog和net.core.somaxconn两个内核参数。
# 在高并发场景下，需要更高的队列长度，以避免客户端连接慢的问题
# 注意linux内核会截断这个值到/proc/sys/net/core/somaxconn配置的值
# 也就是二者取小。所以别忘了修改somaxconn
tcp-backlog 511

# Unix socket.
#
# Specify the path for the Unix socket that will be used to listen for
# incoming connections. There is no default, so Redis will not listen
# on a unix socket when not specified.
# 指定一个unix socket,客户端可以通过这个socket文件来连接
# 如果没指定，redis就不会监听任何socket连接
# 客户端连接方式举例：redis-cli -s /tmp/redis.sock
#
# unixsocket /tmp/redis.sock
# unixsocketperm 700

# Close the connection after a client is idle for N seconds (0 to disable)
# 如果timeout时间内，客户端和redis服务端没有数据交互（客户端不向redis发送数据），redis将断开连接
# 0表示永不断开
timeout 0

# TCP keepalive.
#
# If non-zero, use SO_KEEPALIVE to send TCP ACKs to clients in absence
# of communication. This is useful for two reasons:
#
# 1) Detect dead peers.
# 2) Take the connection alive from the point of view of network
#    equipment in the middle.
# TCP探活
# 如果是非0值，使用linux的心跳机制SO_KEEPALIVE来探测连接
# 这个数值是客户端发送的最后一个数据包与redis发送的第一个保活探测报文之间的时间间隔。单位是秒
# On Linux, the specified value (in seconds) is the period used to send ACKs.
# 在linux系统，这个值会覆盖掉linux默认tcp_keepalive_time的值（7200秒）。
# Note that to close the connection the double of the time is needed.
# 注意关闭连接需要2倍的时间
# On other kernels the period depends on the kernel configuration.
# 在其他系统该配置不生效，比如mac系统，这个探测间隔就是内核参数的配置
# A reasonable value for this option is 300 seconds, which is the new
# Redis default starting with Redis 3.2.1.
tcp-keepalive 300

################################# GENERAL #####################################

# By default Redis does not run as a daemon. Use 'yes' if you need it.
# Note that Redis will write a pid file in /var/run/redis.pid when daemonized.
# redis默认不是后台运行
# 当设置后台运行后，redis将写一个pid文件在/var/run/redis.pid
daemonize no

# If you run Redis from upstart or systemd, Redis can interact with your
# supervision tree. Options:
#   supervised no      - no supervision interaction
#   supervised upstart - signal upstart by putting Redis into SIGSTOP mode
#   supervised systemd - signal systemd by writing READY=1 to $NOTIFY_SOCKET
#   supervised auto    - detect upstart or systemd method based on
#                        UPSTART_JOB or NOTIFY_SOCKET environment variables
# Note: these supervision methods only signal "process is ready."
#       They do not enable continuous liveness pings back to your supervisor.
# 如果需要对redis服务进行托管（upstart模式 或systemd模式），可以通过该选项来配置Redis。
# supervised no - 不会与supervised tree进行交互
# supervised upstart - 将Redis服务器添加到SIGSTOP 模式中
# supervised systemd - 将READY=1 写入 $NOTIFY_SOCKET
# supervised auto - 根据环境变量UPSTART_JOB 或 NOTIFY_SOCKET检测upstart 还是 systemd
# 上述 supervision 方法（upstart或systemd）仅发出“程序已就绪”信号，不会继续给supervisor返回ping回复

supervised no

# If a pid file is specified, Redis writes it where specified at startup
# and removes it at exit.
#
# When the server runs non daemonized, no pid file is created if none is
# specified in the configuration. When the server is daemonized, the pid file
# is used even if not specified, defaulting to "/var/run/redis.pid".
#
# Creating a pid file is best effort: if Redis is not able to create it
# nothing bad happens, the server will start and run normally.
# 如果指定了pid文件，redis在启动时会写这个文件，在redis退出时删除 
# 如果没有指定pid文件，并且不是用守护进行启动redis，那么不会生成pid文件
# 如果使用守护进程启动redis，并且没有指定pid文件，默认生成"/var/run/redis.pid"
# 创建pid文件是一件尽力而为的事，如果创建失败，redis依然会正常启动和运行
#
pidfile /var/run/redis_6379.pid

# Specify the server verbosity level.
# This can be one of:
# debug (a lot of information, useful for development/testing)
# verbose (many rarely useful info, but not a mess like the debug level)
# notice (moderately verbose, what you want in production probably)
# warning (only very important / critical messages are logged)
# 日志级别
# debug 大量信息，用于开发和测试
# verbose 会有很多少见的有用信息
# notice 适量信息，适合用于生产环境
# waning 只有严重的信息
loglevel notice

# Specify the log file name. Also the empty string can be used to force
# Redis to log on the standard output. Note that if you use standard
# output for logging but daemonize, logs will be sent to /dev/null
# 配置日志文件
# 空字符串会输出到标准输出中
# 如果配置成空字符串，又用后台启动，那么日志就到/dev/null了。俗话说没了
logfile ""

# To enable logging to the system logger, just set 'syslog-enabled' to yes,
# and optionally update the other syslog parameters to suit your needs.
# 可以启用syslog去记录redis的日志
# syslog-enabled no

# Specify the syslog identity.
# 使用syslog去记录redis日志的标识
# syslog-ident redis

# Specify the syslog facility. Must be USER or between LOCAL0-LOCAL7.
# 指定使用syslog的哪个设施来记录redis日志；默认是local0
# 在syslog中会有定义local0把日志记录到某个文件中
# syslog-facility local0

# Set the number of databases. The default database is DB 0, you can select
# a different one on a per-connection basis using SELECT <dbid> where
# dbid is a number between 0 and 'databases'-1
# 设置数据库的数量，默认是16个
# 客户端连上redis时默认使用的是DB 0
# 可以使用select指令切换数据库
databases 16

# By default Redis shows an ASCII art logo only when started to log to the
# standard output and if the standard output is a TTY. Basically this means
# that normally a logo is displayed only in interactive sessions.
#
# However it is possible to force the pre-4.0 behavior and always show a
# ASCII art logo in startup logs by setting the following option to yes.
always-show-logo yes

################################ SNAPSHOTTING  ################################
#
# Save the DB on disk:
#
#   save <seconds> <changes>
#
#   Will save the DB if both the given number of seconds and the given
#   number of write operations against the DB occurred.
#
#   In the example below the behaviour will be to save:
#   after 900 sec (15 min) if at least 1 key changed
#   after 300 sec (5 min) if at least 10 keys changed
#   after 60 sec if at least 10000 keys changed
#
#   Note: you can disable saving completely by commenting out all "save" lines.
#
#   It is also possible to remove all the previously configured save
#   points by adding a save directive with a single empty string argument
#   like in the following example:
#
#   save ""
# 数据落盘（做快照）的时间点
# 语法是  save (多少秒) （多少写操作）
# 含义是在多少秒内至少发生了多少次写操作，就进行一次数据落盘（写rdb文件）
# 这个多少秒我的理解是距离上次落盘操作后的时间
# 即上一次进行bgsave保存RDB文件后的时间
# save可以配置多条，他们直接是或的关系，只要有一条满足就进行落盘
# 下面的配置的含义是：
# 900秒内至少进行了一次写操作
# 300秒内至少进行了10次写操作
# 60秒内至少进行了10000次写操作
# 注意，如果将这些save全部注释掉，也就禁止了自动落盘
# 如果配置了 save ""，也等于将前面的save配置全部覆盖，也等于禁用了自动落盘
save 900 1
save 300 10
save 60 10000

# By default Redis will stop accepting writes if RDB snapshots are enabled
# (at least one save point) and the latest background save failed.
# This will make the user aware (in a hard way) that data is not persisting
# on disk properly, otherwise chances are that no one will notice and some
# disaster will happen.
# 默认情况下，当开启了RDB快照（也就是只要有一个save配置），并且最近的快照操作失败的时候，redis会停止写服务
# 这样可以让用户明确的意识到数据持久化有问题了
# If the background saving process will start working again Redis will
# automatically allow writes again.
# 如果后台落盘进程又好了，那么redis的写服务会自动恢复
#
# However if you have setup your proper monitoring of the Redis server
# and persistence, you may want to disable this feature so that Redis will
# continue to work as usual even if there are problems with disk,
# permissions, and so forth.
# 但是如果你有其他完善的监控，可以关闭这个特性。
# 因为快照失败就导致redis不可用，在生产环境影响太大。
# 我一般是关掉的
stop-writes-on-bgsave-error yes

# Compress string objects using LZF when dump .rdb databases?
# For default that's set to 'yes' as it's almost always a win.
# If you want to save some CPU in the saving child set it to 'no' but
# the dataset will likely be bigger if you have compressible values or keys.
# 写rdb时开启压缩
# 开启压缩会使用更多cpu，禁用压缩rdb文件会比较大
rdbcompression yes

# Since version 5 of RDB a CRC64 checksum is placed at the end of the file.
# This makes the format more resistant to corruption but there is a performance
# hit to pay (around 10%) when saving and loading RDB files, so you can disable it
# for maximum performances.
# 对rdb文件开启校验，会在rdb文件的最后加上crc64的校验和。
# 这可以保护rdb文件
# 但是在保存和加载rdb文件时会有10%左右的性能损耗
# 如果是为了追求最大性能，可以关闭
# RDB files created with checksum disabled have a checksum of zero that will
# tell the loading code to skip the check.
# 如果关闭rdbchecksum，在rdb文件中的checksum就是0，redis在加载rdb文件时如果发现checksum是0，就会跳过校验
rdbchecksum yes

# The filename where to dump the DB
# rdb文件名
dbfilename dump.rdb

# The working directory.
#
# The DB will be written inside this directory, with the filename specified
# above using the 'dbfilename' configuration directive.
#
# The Append Only File will also be created inside this directory.
#
# Note that you must specify a directory here, not a file name.
# 工作目录，
# 默认是当前目录，如果用redis-server启动就是执行启动命令的目录。如果用systemctl启动就是/
# 这个目录就是上面dump.rdb的存储目录。所以要注意启动用户必须要有写权限
# aof文件也会放在这
dir ./

################################# REPLICATION #################################

# Master-Replica replication. Use replicaof to make a Redis instance a copy of
# another Redis server. A few things to understand ASAP about Redis replication.
#
#   +------------------+      +---------------+
#   |      Master      | ---> |    Replica    |
#   | (receive writes) |      |  (exact copy) |
#   +------------------+      +---------------+
#
# 1) Redis replication is asynchronous, but you can configure a master to
#    stop accepting writes if it appears to be not connected with at least
#    a given number of replicas.
# 2) Redis replicas are able to perform a partial resynchronization with the
#    master if the replication link is lost for a relatively small amount of
#    time. You may want to configure the replication backlog size (see the next
#    sections of this file) with a sensible value depending on your needs.
# 3) Replication is automatic and does not need user intervention. After a
#    network partition replicas automatically try to reconnect to masters
#    and resynchronize with them.
#
# 主从复制。从节点使用replicaof主节点
# 1）redis的主从复制时异步的
# replicaof <masterip> <masterport>

# If the master is password protected (using the "requirepass" configuration
# directive below) it is possible to tell the replica to authenticate before
# starting the replication synchronization process, otherwise the master will
# refuse the replica request.
# 如果master加了密码。那么主从同步的从节点也必须配置上master的密码
# masterauth <master-password>

# When a replica loses its connection with the master, or when the replication
# is still in progress, the replica can act in two different ways:
# 当从与主失去连接，或者同步进程还在执行中是，备节点能否响应业务请求
# 1) if replica-serve-stale-data is set to 'yes' (the default) the replica will
#    still reply to client requests, possibly with out of date data, or the
#    data set may just be empty if this is the first synchronization.
# 1）设置为yes，可以响应业务请求。只是可能有过期数据
# 2) if replica-serve-stale-data is set to 'no' the replica will reply with
#    an error "SYNC with master in progress" to all the kind of commands
#    but to INFO, replicaOF, AUTH, PING, SHUTDOWN, REPLCONF, ROLE, CONFIG,
#    SUBSCRIBE, UNSUBSCRIBE, PSUBSCRIBE, PUNSUBSCRIBE, PUBLISH, PUBSUB,
#    COMMAND, POST, HOST: and LATENCY.
# 2）设置为no，备节点会返回 "SYNC with master in progress" 错误。
#     但是INFO, replicaOF, AUTH, PING, SHUTDOWN, REPLCONF, ROLE, CONFIG,
#    SUBSCRIBE, UNSUBSCRIBE, PSUBSCRIBE, PUNSUBSCRIBE, PUBLISH, PUBSUB,
#    COMMAND, POST, HOST: and LATENCY.这些命令可以响应
replica-serve-stale-data yes

# You can configure a replica instance to accept writes or not. Writing against
# a replica instance may be useful to store some ephemeral data (because data
# written on a replica will be easily deleted after resync with the master) but
# may also cause problems if clients are writing to it because of a
# misconfiguration.
# 配置从节点是否能处理写请求
# 实在不建议从节点也能写
# Since Redis 2.6 by default replicas are read-only.
# 从redis2.6开始，默认是只读
# Note: read only replicas are not designed to be exposed to untrusted clients
# on the internet. It's just a protection layer against misuse of the instance.
# Still a read only replica exports by default all the administrative commands
# such as CONFIG, DEBUG, and so forth. To a limited extent you can improve
# security of read only replicas using 'rename-command' to shadow all the
# administrative / dangerous commands.
# 注意，就算是只读的从节点也不要暴露给不信任的客户端
# 因为虽然只读了，但是仍然可以执行管理命令
# 建议使用'rename-command'重命名掉危险的命令
replica-read-only yes

# Replication SYNC strategy: disk or socket.
# 主从同步策略：disk模式和socket模式
# -------------------------------------------------------
# WARNING: DISKLESS REPLICATION IS EXPERIMENTAL CURRENTLY
# -------------------------------------------------------
# 警告：socket模式目前还是实验状态
# New replicas and reconnecting replicas that are not able to continue the replication
# process just receiving differences, need to do what is called a "full
# synchronization". An RDB file is transmitted from the master to the replicas.
# The transmission can happen in two different ways:
# 新的从节点或者重新连上的但有不能进行增量同步的从节点，就会进行全量同步
# rdb文件会从主节点传到从节点
# 这个传递有下面两种方式：
# 1) Disk-backed: The Redis master creates a new process that writes the RDB
#                 file on disk. Later the file is transferred by the parent
#                 process to the replicas incrementally.
# disk方式，主节点先把rdb文件写到硬盘，然后再启动一个进程传给从节点
# 2) Diskless: The Redis master creates a new process that directly writes the
#              RDB file to replica sockets, without touching the disk at all.
# Diskless方式，主节点直接将rdb写道从节点的socket，不需要写硬盘的动作
# With disk-backed replication, while the RDB file is generated, more replicas
# can be queued and served with the RDB file as soon as the current child producing
# the RDB file finishes its work. With diskless replication instead once
# the transfer starts, new replicas arriving will be queued and a new transfer
# will start when the current one terminates.
#
# When diskless replication is used, the master waits a configurable amount of
# time (in seconds) before starting the transfer in the hope that multiple replicas
# will arrive and the transfer can be parallelized.
#
# With slow disks and fast (large bandwidth) networks, diskless replication
# works better.
# 当硬盘很慢而网络快时，diskless方式会更好
repl-diskless-sync no

# When diskless replication is enabled, it is possible to configure the delay
# the server waits in order to spawn the child that transfers the RDB via socket
# to the replicas.
# 当启用上面的diskless方式同步时，要配置一个等待时间以便并行传递rdb文件
# This is important since once the transfer starts, it is not possible to serve
# new replicas arriving, that will be queued for the next RDB transfer, so the server
# waits a delay in order to let more replicas arrive.
# 因为一旦传递开始，以后到来的从节点的同步请求只能排队等这次传递结束
# 所以要配置一个等待时间，等更多的从节点的同步请求，以便并行传递rdb文件
# The delay is specified in seconds, and by default is 5 seconds. To disable
# it entirely just set it to 0 seconds and the transfer will start ASAP.
# 默认5秒，设置为0就不等待，立刻开始
repl-diskless-sync-delay 5

# Replicas send PINGs to server in a predefined interval. It's possible to change
# this interval with the repl_ping_replica_period option. The default value is 10
# seconds.
# 从节点周期性的向主节点发送ping包，即心跳间隔
# repl-ping-replica-period 10

# The following option sets the replication timeout for:
# 复制超时时间设置
# 1) Bulk transfer I/O during SYNC, from the point of view of replica.
# 2) Master timeout from the point of view of replicas (data, pings).
# 3) Replica timeout from the point of view of masters (REPLCONF ACK pings).
# 1.从节点的角度，没有收到master SYNC传输的rdb数据
# 2.从节点的角度，没有收到master的数据或者ping包
# 3.主节点的角度，没有收到从节点的ack确认
# 当redis检测到repl-timeout超时(默认值60s)，将会关闭主从之间的连接,redis slave发起重新建立主从连接的请求。
# It is important to make sure that this value is greater than the value
# specified for repl-ping-replica-period otherwise a timeout will be detected
# every time there is low traffic between the master and the replica.
# 这个值应该比上面的心跳间隔repl-ping-replica-period大
# repl-timeout 60

# Disable TCP_NODELAY on the replica socket after SYNC?
# 是否再发送SYNC之后，该socket禁用TCP_NODELAY
# If you select "yes" Redis will use a smaller number of TCP packets and
# less bandwidth to send data to replicas. But this can add a delay for
# the data to appear on the replica side, up to 40 milliseconds with
# Linux kernels using a default configuration.
# 设置为yes，就是禁用掉TCP_NODELAY，即可以稍微delay一下再发送，
# 这样可以攒多一点数据，也就是可以用更少的tcp包了，
# 但是这会增大主从之间的同步延迟
# linux内核的delay时间默认是40毫秒
#
# If you select "no" the delay for data to appear on the replica side will
# be reduced but more bandwidth will be used for replication.
# 设置为no,可以减少主从同步的延时。但是会用掉更大的带宽。
#
# By default we optimize for low latency, but in very high traffic conditions
# or when the master and replicas are many hops away, turning this to "yes" may
# be a good idea.
# 默认是no，因为我们通常希望主从同步尽量快
# 但是如果网络很拥堵或者主从之间需要很多跳，改成yes，减少包的数量可能会比较好
repl-disable-tcp-nodelay no

# Set the replication backlog size. The backlog is a buffer that accumulates
# replica data when replicas are disconnected for some time, so that when a replica
# wants to reconnect again, often a full resync is not needed, but a partial
# resync is enough, just passing the portion of data the replica missed while
# disconnected.
# 复制缓冲区的大小。
# 当从节点断联时，主从复制的数据先缓存到这个复制缓冲区。
# 等从节点重新连上，通常不需要全量复制。只需要进行增量复制，即把复制缓冲区的数据同步即可
# 
# The bigger the replication backlog, the longer the time the replica can be
# disconnected and later be able to perform a partial resynchronization.
# 所以，复制缓冲区越大，从节点允许的断连时间就越长（允许进行增加复制的时间）
# The backlog is only allocated once there is at least a replica connected.
# 复制缓存区是在只要有一个从节点连上的时候才会分配内存。
# 默认是1mb
#
# repl-backlog-size 1mb

# After a master has no longer connected replicas for some time, the backlog
# will be freed. The following option configures the amount of seconds that
# need to elapse, starting from the time the last replica disconnected, for
# the backlog buffer to be freed.
# 当master上没有任何从节点的连接，在超出一定时间后，就会释放复制缓冲器
# 这个时间从最后一个从节点断连开始算
# 
# Note that replicas never free the backlog for timeout, since they may be
# promoted to masters later, and should be able to correctly "partially
# resynchronize" with the replicas: hence they should always accumulate backlog.
# 从节点永远不会因为超时而释放backlog，因为他随时可能被选为master
#
# A value of 0 means to never release the backlog.
# 0标识从不释放backlog
# 
# repl-backlog-ttl 3600

# The replica priority is an integer number published by Redis in the INFO output.
# It is used by Redis Sentinel in order to select a replica to promote into a
# master if the master is no longer working correctly.
# 用于哨兵模式下的选举。
#
# A replica with a low priority number is considered better for promotion, so
# for instance if there are three replicas with priority 10, 100, 25 Sentinel will
# pick the one with priority 10, that is the lowest.
# 数字越小代表优先级越高
# 
# However a special priority of 0 marks the replica as not able to perform the
# role of master, so a replica with priority of 0 will never be selected by
# Redis Sentinel for promotion.
# 但是0标识这个从节点不能被选为master
#
# By default the priority is 100.
replica-priority 100

# It is possible for a master to stop accepting writes if there are less than
# N replicas connected, having a lag less or equal than M seconds.
# 可以配置master在少于n个从节点，或者主从延时大于m秒的情况下，停止接收写请求
# The N replicas need to be in "online" state.
# 需要n个从节点是online状态
# The lag in seconds, that must be <= the specified value, is calculated from
# the last ping received from the replica, that is usually sent every second.
# 主从同步必须小于等于指定的秒数
# 从最后一次收到从节点的ping包开始计算
# 通常每秒一次
# 原因：在主从完成同步之后，从节点默认会以每秒一次的频率，向master发送REPLCONF ACK命令，报告自身的复制偏移量
# 
# This option does not GUARANTEE that N replicas will accept the write, but
# will limit the window of exposure for lost writes in case not enough replicas
# are available, to the specified number of seconds.
# 这个配置不是保证会有N个从节点来处理写请求，而是为了防止丢失写操作
# 
# For example to require at least 3 replicas with a lag <= 10 seconds use:
#
# min-replicas-to-write 3
# min-replicas-max-lag 10
#
# Setting one or the other to 0 disables the feature.
# 设置为0标识禁用该特性
#
# By default min-replicas-to-write is set to 0 (feature disabled) and
# min-replicas-max-lag is set to 10.
# 默认min-replicas-to-write是0，min-replicas-max-lag是10

# A Redis master is able to list the address and port of the attached
# replicas in different ways. For example the "INFO replication" section
# offers this information, which is used, among other tools, by
# Redis Sentinel in order to discover replica instances.
# Another place where this info is available is in the output of the
# "ROLE" command of a master.
# master可以获知备节点的地址和端口。
# 途径有多种，比如通过INFO replication命令，这个命令会被其他工具使用，
# 比如哨兵模式使用info来发现从节点
# 另一个途径是Role命令
# The listed IP and address normally reported by a replica is obtained
# in the following way:
# 从节点的IP和端口这样获取：
#   IP: The address is auto detected by checking the peer address
#   of the socket used by the replica to connect with the master.
#   IP： 通过解析socket的对端地址
#   Port: The port is communicated by the replica during the replication
#   handshake, and is normally the port that the replica is using to
#   listen for connections.
#   port：通过主从建立连接的握手，获取从节点用于建立连接的端口
# 
# However when port forwarding or Network Address Translation (NAT) is
# used, the replica may be actually reachable via different IP and port
# pairs. The following two options can be used by a replica in order to
# report to its master a specific set of IP and port, so that both INFO
# and ROLE will report those values.
# 但是，如果从节点使用了端口转发做个做了nat，从节点的实际连接地址就和上面自动解析出来的不一样了。
# 这个时候可以用下面的参数，主动申报自己的ip和端口
# （这在云原生领域需要注意）
# There is no need to use both the options if you need to override just
# the port or the IP address.
# 不是必须两个一起用，根据需要可以只用一个
# 
# replica-announce-ip 5.5.5.5
# replica-announce-port 1234

################################## SECURITY ###################################

# Require clients to issue AUTH <PASSWORD> before processing any other
# commands.  This might be useful in environments in which you do not trust
# others with access to the host running redis-server.
# 在用户输入命令前，需要输入AUTH进行密码认证
#
# This should stay commented out for backward compatibility and because most
# people do not need auth (e.g. they run their own servers).
#
# Warning: since Redis is pretty fast an outside user can try up to
# 150k passwords per second against a good box. This means that you should
# use a very strong password otherwise it will be very easy to break.
# 警告，因为redis非常快，用户可以进行暴力测试破解。
# 所以应该设置一个非常复杂的密码
# 
# requirepass foobared

# Command renaming.
#
# It is possible to change the name of dangerous commands in a shared
# environment. For instance the CONFIG command may be renamed into something
# hard to guess so that it will still be available for internal-use tools
# but not available for general clients.
# 命令重命名
# 在一个共享的环境下，可以重命名掉危险的命令
# 比如可以把CONFIG命令重命名为一个难猜的字符串，这样我们自己还可以使用
# 但是外部用户就没法使用了
# Example:
#
# rename-command CONFIG b840fc02d524045429941cc15f59e41cb7be6c52
#
# It is also possible to completely kill a command by renaming it into
# an empty string:
# 重命名为空字符串就是直接禁用掉该命令
# 
# rename-command CONFIG ""
#
# Please note that changing the name of commands that are logged into the
# AOF file or transmitted to replicas may cause problems.
# 注意改名的命令是会记录到aof文件的，也会传递到从节点
# 所以如果从节点没有相应的改名，会有问题

################################### CLIENTS ####################################

# Set the max number of connected clients at the same time. By default
# this limit is set to 10000 clients, however if the Redis server is not
# able to configure the process file limit to allow for the specified limit
# the max number of allowed clients is set to the current file limit
# minus 32 (as Redis reserves a few file descriptors for internal uses).
# 设置允许的同时连接的客户端数量。默认是10000
# 但是如果系统的打开文件数限制的比较小，那么这个客户端限制受限于系统的最大文件数限制
# 并且要减去32（留给redis自己用）
# Once the limit is reached Redis will close all the new connections sending
# an error 'max number of clients reached'.
# 达到这个最大值会报'max number of clients reached'错误
# maxclients 10000

############################## MEMORY MANAGEMENT ################################

# Set a memory usage limit to the specified amount of bytes.
# When the memory limit is reached Redis will try to remove keys
# according to the eviction policy selected (see maxmemory-policy).
# 配置最大可用内存
# 当使用了达到最大内存时，redis将根据淘汰策略进行数据淘汰
#
# If Redis can't remove keys according to the policy, or if the policy is
# set to 'noeviction', Redis will start to reply with errors to commands
# that would use more memory, like SET, LPUSH, and so on, and will continue
# to reply to read-only commands like GET.
# 如果根据策略没有能删除的key，或者策略就是配置了'noeviction'（不淘汰）
# 那么对于需要增加内存的命令（如set，lpush等），redis会返回错误
# 但是对于get这种读请求，redis正常相应
# 
# This option is usually useful when using Redis as an LRU or LFU cache, or to
# set a hard memory limit for an instance (using the 'noeviction' policy).
# 这个配置在以下场景很有用的
# 将redis作为一个lru或lfu缓存使用
# 或者对redis实例限制内存使用量（配置noeviction策略）
#
# WARNING: If you have replicas attached to an instance with maxmemory on,
# the size of the output buffers needed to feed the replicas are subtracted
# from the used memory count, so that network problems / resyncs will
# not trigger a loop where keys are evicted, and in turn the output
# buffer of replicas is full with DELs of keys evicted triggering the deletion
# of more keys, and so forth until the database is completely emptied.
# 警告：复制缓冲区的大小是不算在使用的内存量里的
# 这个警告的内容不好理解，涉及到一些往事
# 在redis的低版本中出现过一个bug：
# 在多从节点的场景下，主节点设置了maxmemory，又设置了淘汰策略
# 可能会发生主节点数据被主键全部擦除的bug
# 原因是：当初主从复制buffer也是算在使用内存里的。这样当达到最大内存时，开始淘汰key
# 淘汰key，会记录为del key放在同步复制buffer中。如果从节点比较多，这个同步buffer会更大。
# 导致使用的内存更会触及mamemory，进而淘汰更多的key，进而同步bufeer继续变大。。。
# 最终形成恶性循环，导致所有的key被淘汰
# 现在就能理解这个警告了，解决这个bug的方案就是复制缓冲区的大小是不算在使用的内存量里
# 
# In short... if you have replicas attached it is suggested that you set a lower
# limit for maxmemory so that there is some free RAM on the system for replica
# output buffers (but this is not needed if the policy is 'noeviction').
# 总之，如果redis实例有多个从节点连接，那么maxmemory设置的小一点（不要和服务器内存一样大）
# 给复制缓冲器留一些空间。
# maxmemory <bytes>

# MAXMEMORY POLICY: how Redis will select what to remove when maxmemory
# is reached. You can select among five behaviors:
# 淘汰策略：当内存达到maxmemory时，选择哪些key进行淘汰
# 
# volatile-lru -> Evict using approximated LRU among the keys with an expire set.
# allkeys-lru -> Evict any key using approximated LRU.
# volatile-lfu -> Evict using approximated LFU among the keys with an expire set.
# allkeys-lfu -> Evict any key using approximated LFU.
# volatile-random -> Remove a random key among the ones with an expire set.
# allkeys-random -> Remove a random key, any key.
# volatile-ttl -> Remove the key with the nearest expire time (minor TTL)
# noeviction -> Don't evict anything, just return an error on write operations.
# 共有5种行为
# volatile-lru：使用近似LRU算法从设置了expire的key中选
# allkeys-lru：使用近似LRU算法从全部的key中选
# volatile-lfu：使用近似LFU算法从设置了expire的key中选
# allkeys-lfu：使用近似LFU算法从全部的key中选
# volatile-random:从设置了expire的key中随机选
# allkeys-random：从全部key中随机选
# volatile-ttl：删除剩余过期时间最小的
# noeviction：不淘汰。对写请求返回错误。默认是这个
#
# LRU means Least Recently Used
# LFU means Least Frequently Used
#
# Both LRU, LFU and volatile-ttl are implemented using approximated
# randomized algorithms.
# LRU, LFU and volatile-ttl 都是近似的，不是精准算法
# 
# Note: with any of the above policies, Redis will return an error on write
#       operations, when there are no suitable keys for eviction.
#
#       At the date of writing these commands are: set setnx setex append
#       incr decr rpush lpush rpushx lpushx linsert lset rpoplpush sadd
#       sinter sinterstore sunion sunionstore sdiff sdiffstore zadd zincrby
#       zunionstore zinterstore hset hsetnx hmset hincrby incrby decrby
#       getset mset msetnx exec sort
#
# 注意：对于以上所有策略，当redis发现没有key能删除时，都会返回错误。
# The default is:
#
# maxmemory-policy noeviction

# LRU, LFU and minimal TTL algorithms are not precise algorithms but approximated
# algorithms (in order to save memory), so you can tune it for speed or
# accuracy. For default Redis will check five keys and pick the one that was
# used less recently, you can change the sample size using the following
# configuration directive.
#
# The default of 5 produces good enough results. 10 Approximates very closely
# true LRU but costs more CPU. 3 is faster but not very accurate.
# lru，lfu和ttl算法都是近似算法，不是精确算法。这样可以节约内存。
# 可以设置参数对速度和准确性进行调整
# 默认情况下，redis会一次性抓取5个key，选中其中一个。可以调整采样数量。
#
# 默认的5已经可以得到足够好的结果，调成10的话，得到的结果更接近准确的算法，但是需要消耗更多的cpu
# 调整成3更快但是更不准确
# 
# maxmemory-samples 5

# Starting from Redis 5, by default a replica will ignore its maxmemory setting
# (unless it is promoted to master after a failover or manually). It means
# that the eviction of keys will be just handled by the master, sending the
# DEL commands to the replica as keys evict in the master side.
# 从redis5开始，默认从节点将忽略maxmemory配置
# 对key的淘汰由master负责，然后发送del命令到从节点
#
# This behavior ensures that masters and replicas stay consistent, and is usually
# what you want, however if your replica is writable, or you want the replica to have
# a different memory setting, and you are sure all the writes performed to the
# replica are idempotent, then you may change this default (but be sure to understand
# what you are doing).
# 这个行为可以确保主从的数据一致性。
# 但是如果你的从节点配置为可写的，或者你想要从节点有不同的memory配置
# 并且你确定对所有从节点的写是幂等的，你可以修改这个配置
# （最好不要这样搞）
#
# Note that since the replica by default does not evict, it may end using more
# memory than the one set via maxmemory (there are certain buffers that may
# be larger on the replica, or data structures may sometimes take more memory and so
# forth). So make sure you monitor your replicas and make sure they have enough
# memory to never hit a real out-of-memory condition before the master hits
# the configured maxmemory setting.
# 注意，因为从节点默认不会主动淘汰数据，他的内存可能比使用maxmemory设置的更大
# 也就是说从节点的内存使用量很可能比master节点的大
# 所以要确保从节点不会发生内存溢出
# 
# replica-ignore-maxmemory yes

############################# LAZY FREEING ####################################

# Redis has two primitives to delete keys. One is called DEL and is a blocking
# deletion of the object. It means that the server stops processing new commands
# in order to reclaim all the memory associated with an object in a synchronous
# way. If the key deleted is associated with a small object, the time needed
# in order to execute the DEL command is very small and comparable to most other
# O(1) or O(log_N) commands in Redis. However if the key is associated with an
# aggregated value containing millions of elements, the server can block for
# a long time (even seconds) in order to complete the operation.
# redis有两个用于删除key的原语
# 一个是DEl 命令。del是一个阻塞操作。指定del时会阻塞所有其他命令的执行，直到del完成。
# 如果时删除一个小对象，del的耗时会很短，和其他O(1) 或 O(log_N) 时间复杂度的命令相当。
# 但是如果是一个聚合数据，比如有几百万的数据元素，那么这个阻塞时间会很长（可能达到秒级）
#
# For the above reasons Redis also offers non blocking deletion primitives
# such as UNLINK (non blocking DEL) and the ASYNC option of FLUSHALL and
# FLUSHDB commands, in order to reclaim memory in background. Those commands
# are executed in constant time. Another thread will incrementally free the
# object in the background as fast as possible.
# 因为以上原因，redis提供了一个非阻塞的删除原语：UNLINK。
# flushall和flushdb增加了非阻塞操作async
# 可以在后台进行内存的回收
# 
# unlink和async的执行时间是一个常量
# 其他线程会继续在后台递增的删除数据
#   
# DEL, UNLINK and ASYNC option of FLUSHALL and FLUSHDB are user-controlled.
# It's up to the design of the application to understand when it is a good
# idea to use one or the other. However the Redis server sometimes has to
# delete keys or flush the whole database as a side effect of other operations.
# Specifically Redis deletes objects independently of a user call in the
# following scenarios:
# 我们会根据自己的业务，在代码中对del,unlink,flush-async进行主动的使用
# 但是有一些场景下，redis会受其他操作的影响而进行删除操作
# 比如以下场景
# 
# 1) On eviction, because of the maxmemory and maxmemory policy configurations,
#    in order to make room for new data, without going over the specified
#    memory limit.
# 1、淘汰。达到maxmemory了，根据淘汰策略会进行删除
# 2) Because of expire: when a key with an associated time to live (see the
#    EXPIRE command) must be deleted from memory.
# 2、过期。key过期进行删除
# 3) Because of a side effect of a command that stores data on a key that may
#    already exist. For example the RENAME command may delete the old key
#    content when it is replaced with another one. Similarly SUNIONSTORE
#    or SORT with STORE option may delete existing keys. The SET command
#    itself removes any old content of the specified key in order to replace
#    it with the specified string.
# 3、 对一个已经存在的key进行赋值，会发生对旧数据的删除
#    比如rename命令对key进行改名，如果新名字已经存在，会发生隐式的del操作
#    或者set类命令，如果已经存在。也会发生隐式的del操作 
# 4) During replication, when a replica performs a full resynchronization with
#    its master, the content of the whole database is removed in order to
#    load the RDB file just transferred.
# 4、在主从复制中，当进行全量同步后，会对全部数据库进行flush
#
# In all the above cases the default is to delete objects in a blocking way,
# like if DEL was called. However you can configure each case specifically
# in order to instead release memory in a non-blocking way like if UNLINK
# was called, using the following configuration directives:
# 在以上这些场景下，默认的删除操作都是阻塞的方式
# 可以使用下面的参数进行独立配置

lazyfree-lazy-eviction no
lazyfree-lazy-expire no
lazyfree-lazy-server-del no
replica-lazy-flush no

############################## APPEND ONLY MODE ###############################

# By default Redis asynchronously dumps the dataset on disk. This mode is
# good enough in many applications, but an issue with the Redis process or
# a power outage may result into a few minutes of writes lost (depending on
# the configured save points).
# 默认情况下，redis异步的dump数据到硬盘上。
# 这种模式一般够用，但是当redis进程突然当掉，或者主机突然断电，
# 会发生还没落盘的写数据丢失的问题
# 
# The Append Only File is an alternative persistence mode that provides
# much better durability. For instance using the default data fsync policy
# (see later in the config file) Redis can lose just one second of writes in a
# dramatic event like a server power outage, or a single write if something
# wrong with the Redis process itself happens, but the operating system is
# still running correctly.
# aof模式（日志追加模式）提供了更可靠的持久化保障
# 比如使用默认的刷盘策略，redis可以做到当发生主机断电灾难时只丢失1秒中的写数据
# 当发生redis进行宕机时只丢失最近一个写操作
# 
# AOF and RDB persistence can be enabled at the same time without problems.
# If the AOF is enabled on startup Redis will load the AOF, that is the file
# with the better durability guarantees.
# aof和rdb模式可以同时开启
# 如果aof是开启的，redis在启动时会加载aof文件。
# Please check http://redis.io/topics/persistence for more information.

appendonly no

# The name of the append only file (default: "appendonly.aof")
# aof文件名
appendfilename "appendonly.aof"

# The fsync() call tells the Operating System to actually write data on disk
# instead of waiting for more data in the output buffer. Some OS will really flush
# data on disk, some other OS will just try to do it ASAP.
# fsync()调用触发操作系统将数据写到硬盘，而不是在内存buffer中等更多的数据。
# 有的操作系统是真实的进行了刷盘，有的是尽力而为。
# 
# Redis supports three different modes:
# redis支持三种配置
# 
# no: don't fsync, just let the OS flush the data when it wants. Faster.
# always: fsync after every write to the append only log. Slow, Safest.
# everysec: fsync only one time every second. Compromise.
# no：不主动fsync，完全交给操作系统控制。最快
# always：每次写都触发一次fsync，最慢最安全
# everysec:每秒fsync一次。居中妥协
#
# The default is "everysec", as that's usually the right compromise between
# speed and data safety. It's up to you to understand if you can relax this to
# "no" that will let the operating system flush the output buffer when
# it wants, for better performances (but if you can live with the idea of
# some data loss consider the default persistence mode that's snapshotting),
# or on the contrary, use "always" that's very slow but a bit safer than
# everysec.
#
# 默认是everysec。没有特殊需要用这个就可以。
# 
# More details please check the following article:
# http://antirez.com/post/redis-persistence-demystified.html
#
# If unsure, use "everysec".

# appendfsync always
appendfsync everysec
# appendfsync no

# When the AOF fsync policy is set to always or everysec, and a background
# saving process (a background save or AOF log background rewriting) is
# performing a lot of I/O against the disk, in some Linux configurations
# Redis may block too long on the fsync() call. Note that there is no fix for
# this currently, as even performing fsync in a different thread will block
# our synchronous write(2) call.
# 当aof的fsync策略是always or everysec
# 如果此时有一个后台进行进行rdb保存或aof重写，这也会大量操作io
# 这就和主线程的aof操作发生了竞争，在某些操作系统下，fsync调用可能会被阻塞
#
# In order to mitigate this problem it's possible to use the following option
# that will prevent fsync() from being called in the main process while a
# BGSAVE or BGREWRITEAOF is in progress.
# 一个解决办法是，当进行BGSAVE or BGREWRITEAOF时，主线程禁止fsync调用
# 
# This means that while another child is saving, the durability of Redis is
# the same as "appendfsync none". In practical terms, this means that it is
# possible to lose up to 30 seconds of log in the worst scenario (with the
# default Linux settings).
# 这意味着当子线程进行save操作时，redis的 appendfsync设置为 no
# 就像上面说的，这种情况下要忍受丢部分数据的风险。
# 根据linux的默认设置，最多可能丢失30秒的写数据
# 
# If you have latency problems turn this to "yes". Otherwise leave it as
# "no" that is the safest pick from the point of view of durability.
# 如果你有这个阻塞的问题，可以设置为yes，不进行fsunc刷盘。只是将其放在缓冲区里，避免与命令的追加造成DISK IO上的冲突。
# 设置为no表示在进行BGSAVE or BGREWRITEAOF时，依然进行fsync刷盘
no-appendfsync-on-rewrite no

# Automatic rewrite of the append only file.
# 配置aof文件的自动重写
# Redis is able to automatically rewrite the log file implicitly calling
# BGREWRITEAOF when the AOF log size grows by the specified percentage.
# 当aof文件涨到指定的百分比时，自动触发BGREWRITEAOF进行aof文件重写
#
# This is how it works: Redis remembers the size of the AOF file after the
# latest rewrite (if no rewrite has happened since the restart, the size of
# the AOF at startup is used).
#
# This base size is compared to the current size. If the current size is
# bigger than the specified percentage, the rewrite is triggered. Also
# you need to specify a minimal size for the AOF file to be rewritten, this
# is useful to avoid rewriting the AOF file even if the percentage increase
# is reached but it is still pretty small.
# redis会记住上一次重写后的文件大小
# 然后和当前文件大小对比，如果达到了多处的百分比，就触发重写。
# 也同时需要设置一个最小文件大小。放置达到了重写的百分比但是文件依然很小的情况
# 
# Specify a percentage of zero in order to disable the automatic AOF
# rewrite feature.
# 将百分比设置为0，就仅用了自动重写

auto-aof-rewrite-percentage 100
auto-aof-rewrite-min-size 64mb

# An AOF file may be found to be truncated at the end during the Redis
# startup process, when the AOF data gets loaded back into memory.
# This may happen when the system where Redis is running
# crashes, especially when an ext4 filesystem is mounted without the
# data=ordered option (however this can't happen when Redis itself
# crashes or aborts but the operating system still works correctly).
#
# Redis can either exit with an error when this happens, or load as much
# data as possible (the default now) and start if the AOF file is found
# to be truncated at the end. The following option controls this behavior.
#
# If aof-load-truncated is set to yes, a truncated AOF file is loaded and
# the Redis server starts emitting a log to inform the user of the event.
# Otherwise if the option is set to no, the server aborts with an error
# and refuses to start. When the option is set to no, the user requires
# to fix the AOF file using the "redis-check-aof" utility before to restart
# the server.
#
# Note that if the AOF file will be found to be corrupted in the middle
# the server will still exit with an error. This option only applies when
# Redis will try to read more data from the AOF file but not enough bytes
# will be found.
# redis启动时会加载aof文件。首先会检查aof文件，如果发现aof文件的最后的命令有截断。
# 这个参数就是控制这种情况下redis怎么做
# 设置为yes，redis会忽略最后损坏的数据，加载前面正确的数据。
# 设置为no，redis会报错，无法启动。需要你手动使用redis-check-aof工具进行修复。
# 注意如果aof文件是在中间就损坏了，设置为yes也是无法加载的。

aof-load-truncated yes

# When rewriting the AOF file, Redis is able to use an RDB preamble in the
# AOF file for faster rewrites and recoveries. When this option is turned
# on the rewritten AOF file is composed of two different stanzas:
#
#   [RDB file][AOF tail]
#
# When loading Redis recognizes that the AOF file starts with the "REDIS"
# string and loads the prefixed RDB file, and continues loading the AOF
# tail.
# aof文件重写时，将aof文件重写为rdb格式。之后继续追加aof格式的数据。
# 因为rdb文件更小，重写更快。redis重启时加载也快
# 这样aof文件就会变成前半部分时rdb文件，后面时aof的情况
#  [RDB file][AOF tail]
aof-use-rdb-preamble yes

################################ LUA SCRIPTING  ###############################

# Max execution time of a Lua script in milliseconds.
#
# If the maximum execution time is reached Redis will log that a script is
# still in execution after the maximum allowed time and will start to
# reply to queries with an error.
#
# When a long running script exceeds the maximum execution time only the
# SCRIPT KILL and SHUTDOWN NOSAVE commands are available. The first can be
# used to stop a script that did not yet called write commands. The second
# is the only way to shut down the server in the case a write command was
# already issued by the script but the user doesn't want to wait for the natural
# termination of the script.
#
# Set it to 0 or a negative value for unlimited execution without warnings.
# 设置lua脚本的最大可执行时间
# 当到达执行时间后，redis会记录log，并返回错误
# 
lua-time-limit 5000

################################ REDIS CLUSTER  ###############################

# Normal Redis instances can't be part of a Redis Cluster; only nodes that are
# started as cluster nodes can. In order to start a Redis instance as a
# cluster node enable the cluster support uncommenting the following:
# 一般的redis实例不能用来组建cluster集群，必须以cluster模式启动
# 也就是将cluster-enabled设置为yes
# cluster-enabled yes

# Every cluster node has a cluster configuration file. This file is not
# intended to be edited by hand. It is created and updated by Redis nodes.
# Every Redis Cluster node requires a different cluster configuration file.
# Make sure that instances running in the same system do not have
# overlapping cluster configuration file names.
# 每个集群节点都有个集群配置文件。
# 这个文件是由redis节点生成和更新的。不要手动编辑。
# 每个节点的文件内容都不一样。
# 要注意在同一台服务器上允许多个redis节点时，这个文件不要相互覆盖。
# 
# cluster-config-file nodes-6379.conf

# Cluster node timeout is the amount of milliseconds a node must be unreachable
# for it to be considered in failure state.
# Most other internal time limits are multiple of the node timeout.
# 节点超时时间，默认15000毫秒。一个节点超出15秒没有响应会被标记为可能以失效
# 其他的超时配置通常都是这个cluster-node-timeout的倍数
# cluster-node-timeout 15000

# A replica of a failing master will avoid to start a failover if its data
# looks too old.
# 这个参数是控制什么样的从节点可以进行faiover（故障转移），变成master节点。
# 如果一个从节点的数据太久了，就不能faiover成master
# 
# There is no simple way for a replica to actually have an exact measure of
# its "data age", so the following two checks are performed:
#
# 1) If there are multiple replicas able to failover, they exchange messages
#    in order to try to give an advantage to the replica with the best
#    replication offset (more data from the master processed).
#    Replicas will try to get their rank by offset, and apply to the start
#    of the failover a delay proportional to their rank.
#
# 2) Every single replica computes the time of the last interaction with
#    its master. This can be the last ping or command received (if the master
#    is still in the "connected" state), or the time that elapsed since the
#    disconnection with the master (if the replication link is currently down).
#    If the last interaction is too old, the replica will not try to failover
#    at all.
# 没有一个简单的办法可以准确的判断数据的新旧程度。进行下面两个判断逻辑
# 1、 选主从同步offset最大的
# 2、 比较同master最后交互的时间。发送ping或者命令都算交互
#     如果这个时间间隔太长了，这个从节点将不能进行failover
# 
# The point "2" can be tuned by user. Specifically a replica will not perform
# the failover if, since the last interaction with the master, the time
# elapsed is greater than:
# 
#   (node-timeout * replica-validity-factor) + repl-ping-replica-period
# 第2点是可以配置的。根据上面这个公式，得到的是最大的间隔时间
# 
# So for example if node-timeout is 30 seconds, and the replica-validity-factor
# is 10, and assuming a default repl-ping-replica-period of 10 seconds, the
# replica will not try to failover if it was not able to talk with the master
# for longer than 310 seconds.
# 比如，node-timeout是30秒，replica-validity-factor是10，假设默认的repl-ping-replica-period是10
# 那么最后交互时间超过310秒的从节点就不能进行failover
# 
# A large replica-validity-factor may allow replicas with too old data to failover
# a master, while a too small value may prevent the cluster from being able to
# elect a replica at all.
# 这个从节点数据有效因子如果太大，可能导致比较旧的从节点failover成主节点。
# 如果太小，又可能导致没有从节点能failover成主节点。
# 
# For maximum availability, it is possible to set the replica-validity-factor
# to a value of 0, which means, that replicas will always try to failover the
# master regardless of the last time they interacted with the master.
# (However they'll always try to apply a delay proportional to their
# offset rank).
# 
# Zero is the only value able to guarantee that when all the partitions heal
# the cluster will always be able to continue.
# 为了保持最高的高可用性，可以将replica-validity-factor设置为0.
# 这样从节点总会尝试进行failover 
#
# cluster-replica-validity-factor 10

# Cluster replicas are able to migrate to orphaned masters, that are masters
# that are left without working replicas. This improves the cluster ability
# to resist to failures as otherwise an orphaned master can't be failed over
# in case of failure if it has no working replicas.
# 如果一个master没有任何在线的从节点。而另外的master有多个从节点。
# 那么多余的从节点可以迁移给这个孤立的master
# 使整个集群更平衡，避免这个孤立的master宕机，而没有能进行failover的从节点
# 
# Replicas migrate to orphaned masters only if there are still at least a
# given number of other working replicas for their old master. This number
# is the "migration barrier". A migration barrier of 1 means that a replica
# will migrate only if there is at least 1 other working replica for its master
# and so forth. It usually reflects the number of replicas you want for every
# master in your cluster.
# migration barrier这个参数就是来控制什么样的主节点上的从节点可以迁移。
# cluster-migration-barrier 1表示迁移后，原来的master必须还有不少于1个从节点
# 这个参数一般也表示你希望集群中每个master有几个从节点
#
# Default is 1 (replicas migrate only if their masters remain with at least
# one replica). To disable migration just set it to a very large value.
# A value of 0 can be set but is useful only for debugging and dangerous
# in production.
# 默认使1。想要禁用这个特性，就给这个值设置的非常大
# 不要设置为0。在生产环境很危险。
#
# cluster-migration-barrier 1

# By default Redis Cluster nodes stop accepting queries if they detect there
# is at least an hash slot uncovered (no available node is serving it).
# This way if the cluster is partially down (for example a range of hash slots
# are no longer covered) all the cluster becomes, eventually, unavailable.
# It automatically returns available as soon as all the slots are covered again.
# 默认情况下，redis集群中只有有一个slot丢失，整个集群将不可用
# 只要集群中有部分master宕机，整个集群即不可用
# 当slot恢复后，整个集群自动恢复可用
#
# However sometimes you want the subset of the cluster which is working,
# to continue to accept queries for the part of the key space that is still
# covered. In order to do so, just set the cluster-require-full-coverage
# option to no.
# 但是有时候你希望集群活着的部分依然可以对外服务，就将这个配置设置为true
# 
# cluster-require-full-coverage yes

# This option, when set to yes, prevents replicas from trying to failover its
# master during master failures. However the master can still perform a
# manual failover, if forced to do so.
#
# This is useful in different scenarios, especially in the case of multiple
# data center operations, where we want one side to never be promoted if not
# in the case of a total DC failure.
# 如果这个配置设置为yes，将阻止从节点failover成master。仍然可以进行手动failover
# 这个配置在某些场景下有用，比如多数据中心，我们希望某个中心的节点永远不要自动提升
# 
# cluster-replica-no-failover no

# In order to setup your cluster make sure to read the documentation
# available at http://redis.io web site.

########################## CLUSTER DOCKER/NAT support  ########################

# In certain deployments, Redis Cluster nodes address discovery fails, because
# addresses are NAT-ted or because ports are forwarded (the typical case is
# Docker and other containers).
# 在redis进行容器化部署的场景下，集群节点的地址发现失败
# 因为容器化启动的redis，他的地址可能会经过nat转换，端口也可能经过了转发
#
# In order to make Redis Cluster working in such environments, a static
# configuration where each node knows its public address is needed. The
# following two options are used for this scope, and are:
# 为了满足这种场景，可以对节点地址进行静态配置
#
# * cluster-announce-ip
# * cluster-announce-port
# * cluster-announce-bus-port
#
# Each instruct the node about its address, client port, and cluster message
# bus port. The information is then published in the header of the bus packets
# so that other nodes will be able to correctly map the address of the node
# publishing the information.
# 这三个配置分别指定ip地址，端口和集群总线端口
# 这些信息会加在集群总线信息的信息头里，这样其他节点就可以得到真实的地址
# 
# If the above options are not used, the normal Redis Cluster auto-detection
# will be used instead.
# 如果没有配置以上信息，redis集群会自动解析出这些信息(在容器化场景下通常是错误的)
# 
# Note that when remapped, the bus port may not be at the fixed offset of
# clients port + 10000, so you can specify any port and bus-port depending
# on how they get remapped. If the bus-port is not set, a fixed offset of
# 10000 will be used as usually.
# 注意，总线接口在服务器上部署时，默认是客户端端口+10000
# 在容器化中，可能不是。可以指定。如果没有指定，那就默认是客户端端口+10000
# Example:
#
# cluster-announce-ip 10.1.1.5
# cluster-announce-port 6379
# cluster-announce-bus-port 6380

################################## SLOW LOG ###################################

# The Redis Slow Log is a system to log queries that exceeded a specified
# execution time. The execution time does not include the I/O operations
# like talking with the client, sending the reply and so forth,
# but just the time needed to actually execute the command (this is the only
# stage of command execution where the thread is blocked and can not serve
# other requests in the meantime).
# 慢查询日志是为了记录超过一定执行时间的查询
# 这个执行时间不包括io时间（比如同client交互，发送响应的时间等）
# 只是实际执行命令的时间，在这个时间内redis是阻塞状态，不能响应其他请求
#
# You can configure the slow log with two parameters: one tells Redis
# what is the execution time, in microseconds, to exceed in order for the
# command to get logged, and the other parameter is the length of the
# slow log. When a new command is logged the oldest one is removed from the
# queue of logged commands.
# 有两个参数可以配置
# 一个是slowlog-log-slower-than，单位是微秒！！。表示超过这个配置的就是慢查询
# 另一个是slowlog-max-len，限制记录的慢查询的数量条数。先进先出的队列

# The following time is expressed in microseconds, so 1000000 is equivalent
# to one second. Note that a negative number disables the slow log, while
# a value of zero forces the logging of every command.
# 注意，单位是微秒。1000000微秒 = 1秒
# 负值表示禁用慢查询日志
# 0表示记录每个命令
slowlog-log-slower-than 10000

# There is no limit to this length. Just be aware that it will consume memory.
# You can reclaim memory used by the slow log with SLOWLOG RESET.
# 记录的条数没有限制，可以设置的很大。但是要注意这也是要消耗内存的。
# SLOWLOG RESET命令可以释放慢查询日志占用的内存
slowlog-max-len 128

################################ LATENCY MONITOR ##############################

# The Redis latency monitoring subsystem samples different operations
# at runtime in order to collect data related to possible sources of
# latency of a Redis instance.
#
# Via the LATENCY command this information is available to the user that can
# print graphs and obtain reports.
# Redis延迟监控子系统在运行时对不同的操作进行采样，以便收集Redis实例延迟可能来源的相关数据。
# 通过延迟命令，用户可以通过打印图形和获取报告获得这些信息。
#
# The system only logs operations that were performed in a time equal or
# greater than the amount of milliseconds specified via the
# latency-monitor-threshold configuration directive. When its value is set
# to zero, the latency monitor is turned off.
# 这个延迟监控系统只记录在时间大于等于latency-monitor-threshold指定的毫秒数时间的操作。
# 当它的值设置为0时，将关闭延迟监视器。
#
# By default latency monitoring is disabled since it is mostly not needed
# if you don't have latency issues, and collecting data has a performance
# impact, that while very small, can be measured under big load. Latency
# monitoring can easily be enabled at runtime using the command
# "CONFIG SET latency-monitor-threshold <milliseconds>" if needed.
# 默认是关闭的。因为当没有延迟问题时，这个特性也不需要。
# 并且收集数据有一点点性能损耗。
# 当需要时，可以通过"CONFIG SET latency-monitor-threshold <milliseconds>"随时开启
latency-monitor-threshold 0

############################# EVENT NOTIFICATION ##############################

# Redis can notify Pub/Sub clients about events happening in the key space.
# This feature is documented at http://redis.io/topics/notifications
# redis可以通知Pub/Sub客户端在key上发生的事件
#
# For instance if keyspace events notification is enabled, and a client
# performs a DEL operation on key "foo" stored in the Database 0, two
# messages will be published via Pub/Sub:
# 例如，如果启用了事件通知功能，客户端在key “foo”上执行了del操作。那么redis会通过发布/订阅机制发布两条信息

# PUBLISH __keyspace@0__:foo del
# PUBLISH __keyevent@0__:del foo
# 
# It is possible to select the events that Redis will notify among a set
# of classes. Every class is identified by a single character:
# redis将发布以下几类信息，每类信息用一个字母代表
#
#  K     Keyspace events, published with __keyspace@<db>__ prefix.
#  E     Keyevent events, published with __keyevent@<db>__ prefix.
#  g     Generic commands (non-type specific) like DEL, EXPIRE, RENAME, ...
#  $     String commands
#  l     List commands
#  s     Set commands
#  h     Hash commands
#  z     Sorted set commands
#  x     Expired events (events generated every time a key expires)
#  e     Evicted events (events generated when a key is evicted for maxmemory)
#  A     Alias for g$lshzxe, so that the "AKE" string means all the events.
#
#  The "notify-keyspace-events" takes as argument a string that is composed
#  of zero or multiple characters. The empty string means that notifications
#  are disabled.
#  空字符串表示禁用该特性。默认就是禁用的。
#  Example: to enable list and generic events, from the point of view of the
#           event name, use:
#
#  notify-keyspace-events Elg
#
#  Example 2: to get the stream of the expired keys subscribing to channel
#             name __keyevent@0__:expired use:
#
#  notify-keyspace-events Ex
#
#  By default all notifications are disabled because most users don't need
#  this feature and the feature has some overhead. Note that if you don't
#  specify at least one of K or E, no events will be delivered.
notify-keyspace-events ""

############################### ADVANCED CONFIG ###############################

# Hashes are encoded using a memory efficient data structure when they have a
# small number of entries, and the biggest entry does not exceed a given
# threshold. These thresholds can be configured using the following directives.
# hash类型的数据在一定条件下底层使用ziplist进行存储。ziplist是一种内存优化的数据结构。
# 这个一定条件就是下面的设置。当hash数据满足下面两个条件，就是用ziplist进行存储。
#
# ziplist中允许存储的最大条目数
hash-max-ziplist-entries 512
# 每条数据value值最大字节数
hash-max-ziplist-value 64

# Lists are also encoded in a special way to save a lot of space.
# The number of entries allowed per internal list node can be specified
# as a fixed maximum size or a maximum number of elements.
# For a fixed maximum size, use -5 through -1, meaning:
# -5: max size: 64 Kb  <-- not recommended for normal workloads
# -4: max size: 32 Kb  <-- not recommended
# -3: max size: 16 Kb  <-- probably not recommended
# -2: max size: 8 Kb   <-- good
# -1: max size: 4 Kb   <-- good
# Positive numbers mean store up to _exactly_ that number of elements
# per list node.
# The highest performing option is usually -2 (8 Kb size) or -1 (4 Kb size),
# but if your use case is unique, adjust the settings as necessary.
# redis中list类型的数据底层是使用quicklist来存储的，
# 而quicklist是基于linkedlist + ziplist实现的。
# 这个参数是用来限制每个quicklist节点上的ziplist长度
# 当取正值的时候，表示按照数据项个数来限定每个quicklist节点上的ziplist长度。比如，当这个参数配置成5的时候，表示每个quicklist节点的ziplist最多包含5个数据项。
# 当取负值的时候，表示按照占用字节数来限定每个quicklist节点上的ziplist长度。这时，它只能取-1到-5这五个值，每个值含义如上
# 比如  -2: 每个quicklist节点上的ziplist大小不能超过8 Kb
#
list-max-ziplist-size -2

# Lists may also be compressed.
# Compress depth is the number of quicklist ziplist nodes from *each* side of
# the list to *exclude* from compression.  The head and tail of the list
# are always uncompressed for fast push/pop operations.  Settings are:
# 0: disable all list compression
# 1: depth 1 means "don't start compressing until after 1 node into the list,
#    going from either the head or tail"
#    So: [head]->node->node->...->node->[tail]
#    [head], [tail] will always be uncompressed; inner nodes will compress.
# 2: [head]->[next]->node->node->...->node->[prev]->[tail]
#    2 here means: don't compress head or head->next or tail->prev or tail,
#    but compress all nodes between them.
# 3: [head]->[next]->[next]->node->node->...->node->[prev]->[prev]->[tail]
# etc.
# list是可以被压缩的，这个参数指定quicklist两端不被压缩的节点个数
# 头尾两个节点是永远不会被压缩的，以便于在表的两端进行快速存取
# 0： 不进行压缩。默认属性
# 1： 头尾各1个节点不进行压缩
# 2： 头尾各2个节点不进行压缩
# 3： 头尾各3个节点不进行压缩
# 依次类推
list-compress-depth 0

# Sets have a special encoding in just one case: when a set is composed
# of just strings that happen to be integers in radix 10 in the range
# of 64 bit signed integers.
# The following configuration setting sets the limit in the size of the
# set in order to use this special memory saving encoding.
# set结构在一个特殊场景下有一个优化的数据结构intset
# 这个特殊场景是：全部是数字的字符串
# 在这种情景下，当set的元素小于set-max-intset-entries的值时，使用intset这种数据结构
# 可以极大的节省内存
# 但是当数据量超过set-max-intset-entries的值时，就会自动进行底层数据结构的类型转换
# 从intset转换为hashtable
# 这个转换大量发生时，会出现内存使用量暴涨的情况
set-max-intset-entries 512

# Similarly to hashes and lists, sorted sets are also specially encoded in
# order to save a lot of space. This encoding is only used when the length and
# elements of a sorted set are below the following limits:
# 同样zset类型在数据量小的情况下，也有其内存优化的数据结构
zset-max-ziplist-entries 128
zset-max-ziplist-value 64

# HyperLogLog sparse representation bytes limit. The limit includes the
# 16 bytes header. When an HyperLogLog using the sparse representation crosses
# this limit, it is converted into the dense representation.
#
# A value greater than 16000 is totally useless, since at that point the
# dense representation is more memory efficient.
#
# The suggested value is ~ 3000 in order to have the benefits of
# the space efficient encoding without slowing down too much PFADD,
# which is O(N) with the sparse encoding. The value can be raised to
# ~ 10000 when CPU is not a concern, but space is, and the data set is
# composed of many HyperLogLogs with cardinality in the 0 - 15000 range.
# HyperLogLog 稀疏模式的字节限制，包括了 16 字节的头，默认值为 3000。 
# 当超出这个限制后 HyperLogLog 将由稀疏模式转为稠密模式。
# 这个值设置为超过 16000 是没必要的，因为这时使用稠密模式更省空间
# 建议值是3000左右
hll-sparse-max-bytes 3000

# Streams macro node max size / items. The stream data structure is a radix
# tree of big nodes that encode multiple items inside. Using this configuration
# it is possible to configure how big a single node can be in bytes, and the
# maximum number of items it may contain before switching to a new node when
# appending new stream entries. If any of the following settings are set to
# zero, the limit is ignored, so for instance it is possible to set just a
# max entires limit by setting max-bytes to 0 and max-entries to the desired
# value.
# 设定 Streams 单个节点的最大大小和最多能保存多少个元素
stream-node-max-bytes 4096
stream-node-max-entries 100

# Active rehashing uses 1 millisecond every 100 milliseconds of CPU time in
# order to help rehashing the main Redis hash table (the one mapping top-level
# keys to values). The hash table implementation Redis uses (see dict.c)
# performs a lazy rehashing: the more operation you run into a hash table
# that is rehashing, the more rehashing "steps" are performed, so if the
# server is idle the rehashing is never complete and some more memory is used
# by the hash table.
# 当启用这个功能后，Redis对哈希表的 rehash操作会每100毫秒CPU时间抽出1毫秒进行主动的rehash。
# redis的rehash策略是一种惰性策略，当有数据对hash表进行操作时，顺便进行rehash
# 操作越多，rehash进行的就越多，也就能越快完成rehash
# 所以，如果redis很闲，没什么数据，rehash过程可能要持续很久，甚至不能完成
# 这个过程中，新旧两个hash表都存在，也就浪费了更多内存
# 
# The default is to use this millisecond 10 times every second in order to
# actively rehash the main dictionaries, freeing memory when possible.
# 默认是每秒抽出10次1毫秒进行主动rehash
# 
# If unsure:
# use "activerehashing no" if you have hard latency requirements and it is
# not a good thing in your environment that Redis can reply from time to time
# to queries with 2 milliseconds delay.
# 如果是对响应要求非常严格的场景，不能接收时不时的增加2ms延迟
# 那就可以设置为no
#
# use "activerehashing yes" if you don't have such hard requirements but
# want to free memory asap when possible.
# 否则就保持默认的yes，可以更快的释放内存
activerehashing yes

# The client output buffer limits can be used to force disconnection of clients
# that are not reading data from the server fast enough for some reason (a
# common reason is that a Pub/Sub client can't consume messages as fast as the
# publisher can produce them).
# 客户输出缓冲区大小用于强制断开从服务端读取数据不够快的客户端
#
# The limit can be set differently for the three different classes of clients:
# 有三类设置
# normal -> 普通客户端，包括 MONITOR 客户端
# replica -> 从节点复制客户端
# pubsub -> 订阅了至少一个频道的客户端
#
# normal -> normal clients including MONITOR clients
# replica  -> replica clients
# pubsub -> clients subscribed to at least one pubsub channel or pattern
#
# The syntax of every client-output-buffer-limit directive is the following:
# 语法如下：
# client-output-buffer-limit <class> <hard limit> <soft limit> <soft seconds>
#
# A client is immediately disconnected once the hard limit is reached, or if
# the soft limit is reached and remains reached for the specified number of
# seconds (continuously).
# So for instance if the hard limit is 32 megabytes and the soft limit is
# 16 megabytes / 10 seconds, the client will get disconnected immediately
# if the size of the output buffers reach 32 megabytes, but will also get
# disconnected if the client reaches 16 megabytes and continuously overcomes
# the limit for 10 seconds.
# 达到hard limit，立即断开
# 达到 soft limit，并持续soft seconds秒都达到soft limit，然后会断开
#
# By default normal clients are not limited because they don't receive data
# without asking (in a push way), but just after a request, so only
# asynchronous clients may create a scenario where data is requested faster
# than it can read.
# 默认情况下，普通客户端不会有限制，因为除非主动请求否则他们不会收到信息， 
# 只有异步的客户端才可能发生发送请求的速度比读取响应的速度快的情况。
# Instead there is a default limit for pubsub and replica clients, since
# subscribers and replicas receive data in a push fashion.
# 默认情况下 pubsub 和 replica 客户端会有默认的限制，
# 因为这些客户端是以 Redis 服务端 push 的方式接收数据的
# Both the hard or the soft limit can be disabled by setting them to zero.
# soft limit 或者 hard limit 都可以设置为 0，这表示禁用此限制

client-output-buffer-limit normal 0 0 0
client-output-buffer-limit replica 256mb 64mb 60
client-output-buffer-limit pubsub 32mb 8mb 60

# Client query buffers accumulate new commands. They are limited to a fixed
# amount by default in order to avoid that a protocol desynchronization (for
# instance due to a bug in the client) will lead to unbound memory usage in
# the query buffer. However you can configure it here if you have very special
# needs, such us huge multi/exec requests or alike.
# 客户端查询缓冲区会累加新的命令。 
# 默认情况下，他们会限制在一个固定的数量避免协议同步失效（比如客户端的 bug）导致查询缓冲区出现未绑定的内存。
# 但是，如果有类似于巨大的 multi/exec请求的时候可以修改这个值以满足你的特殊需求。

# client-query-buffer-limit 1gb

# In the Redis protocol, bulk requests, that are, elements representing single
# strings, are normally limited ot 512 mb. However you can change this limit
# here.
# 在 Redis 协议中，批量请求通常限制在 512 mb 内，
# 可以通过修改 proto-max-bulk-len 选项改变这个限制
# proto-max-bulk-len 512mb

# Redis calls an internal function to perform many background tasks, like
# closing connections of clients in timeout, purging expired keys that are
# never requested, and so forth.
#
# Not all tasks are performed with the same frequency, but Redis checks for
# tasks to perform according to the specified "hz" value.
#
# By default "hz" is set to 10. Raising the value will use more CPU when
# Redis is idle, but at the same time will make Redis more responsive when
# there are many keys expiring at the same time, and timeouts may be
# handled with more precision.
#
# The range is between 1 and 500, however a value over 100 is usually not
# a good idea. Most users should use the default of 10 and raise this up to
# 100 only in environments where very low latency is required.
# hz参数用于指定Redis后台任务的执行频率，这些任务包括关闭超时的客户端连接、主动清除过期key等。
hz 10

# Normally it is useful to have an HZ value which is proportional to the
# number of clients connected. This is useful in order, for instance, to
# avoid too many clients are processed for each background task invocation
# in order to avoid latency spikes.
#
# Since the default HZ value by default is conservatively set to 10, Redis
# offers, and enables by default, the ability to use an adaptive HZ value
# which will temporary raise when there are many connected clients.
#
# When dynamic HZ is enabled, the actual configured HZ will be used as
# as a baseline, but multiples of the configured HZ value will be actually
# used as needed once more clients are connected. In this way an idle
# instance will use very little CPU time while a busy instance will be
# more responsive.
#5.0之前的redis版本，hz参数一旦设定之后就是固定的了。
#hz默认是10。这也是官方建议的配置。
#如果改大，表示在reids空闲时会用更多的cpu去执行这些任务。官方并不建议这样做。
#但是，如果连接数特别多，在这种情况下应该给与更多的cpu时间执行后台任务。
#所以有了这个dynamic-hz参数，默认就是打开。当连接数很多时，自动加倍hz，以便处理更多的连接。
dynamic-hz yes

# When a child rewrites the AOF file, if the following option is enabled
# the file will be fsync-ed every 32 MB of data generated. This is useful
# in order to commit the file to the disk more incrementally and avoid
# big latency spikes.
# 当子进程进行 AOF 的重写时，如果启用了 aof-rewrite-incremental-fsync， 
# 子进程会每生成 32 MB 数据就进行一次 fsync 操作。 
# 通过这种方式将数据分批提交到硬盘可以避免高延迟峰值。
aof-rewrite-incremental-fsync yes

# When redis saves RDB file, if the following option is enabled
# the file will be fsync-ed every 32 MB of data generated. This is useful
# in order to commit the file to the disk more incrementally and avoid
# big latency spikes.
# rdb文件每增加32mb 就执行fsync一次(增量式,避免一次性大写入导致的延时)
# 这个是针对rdb模式的优化，
# aof模式在4版本的时候已经有这个优化了aof-rewrite-incremental-fsync
rdb-save-incremental-fsync yes

# Redis LFU eviction (see maxmemory setting) can be tuned. However it is a good
# idea to start with the default settings and only change them after investigating
# how to improve the performances and how the keys LFU change over time, which
# is possible to inspect via the OBJECT FREQ command.
# lfu淘汰策略可以进行配置。
# 保持默认值就是一个好主意。只有经过研究验证后再进行变更。
# 
# 在LFU算法中，每个key有一个计数器counter。每次key被访问的时候，计数器增大。
# 计数器越大，可以约等于访问越频繁。
# 但是counter不是简单的线性增大，而是采用对数函数增长曲线
# 增加曲线通过lfu-log-factor对数因子来控制
# 并且不能只增加，醉着事件的推移，不被访问的key的计数器需要减小
# 这个减小的速度通过lfu-decay-time衰减事件来控制
#
# There are two tunable parameters in the Redis LFU implementation: the
# counter logarithm factor and the counter decay time. It is important to
# understand what the two parameters mean before changing them.
#
# The LFU counter is just 8 bits per key, it's maximum value is 255, so Redis
# uses a probabilistic increment with logarithmic behavior. Given the value
# of the old counter, when a key is accessed, the counter is incremented in
# this way:
# 上面说的计数器counter，是一个8bit大的数，所以最大值就是255
#
# 1. A random number R between 0 and 1 is extracted.
# 2. A probability P is calculated as 1/(old_value*lfu_log_factor+1).
# 3. The counter is incremented only if R < P.
#
# The default lfu-log-factor is 10. This is a table of how the frequency
# counter changes with a different number of accesses with different
# logarithmic factors:
# 默认的log底数是10，下面的表是不同的底数，随着访问次数的变化，其计数器值的变化
# 根据log函数我们也能猜到，底数越大增加曲线越平缓
# +--------+------------+------------+------------+------------+------------+
# | factor | 100 hits   | 1000 hits  | 100K hits  | 1M hits    | 10M hits   |
# +--------+------------+------------+------------+------------+------------+
# | 0      | 104        | 255        | 255        | 255        | 255        |
# +--------+------------+------------+------------+------------+------------+
# | 1      | 18         | 49         | 255        | 255        | 255        |
# +--------+------------+------------+------------+------------+------------+
# | 10     | 10         | 18         | 142        | 255        | 255        |
# +--------+------------+------------+------------+------------+------------+
# | 100    | 8          | 11         | 49         | 143        | 255        |
# +--------+------------+------------+------------+------------+------------+
#
# NOTE: The above table was obtained by running the following commands:
#
#   redis-benchmark -n 1000000 incr foo
#   redis-cli object freq foo
#
# NOTE 2: The counter initial value is 5 in order to give new objects a chance
# to accumulate hits.
#
# The counter decay time is the time, in minutes, that must elapse in order
# for the key counter to be divided by two (or decremented if it has a value
# less <= 10).
#
# The default value for the lfu-decay-time is 1. A Special value of 0 means to
# decay the counter every time it happens to be scanned.
#
# lfu-log-factor 10
# lfu-decay-time 1

########################### ACTIVE DEFRAGMENTATION #######################
#
# 警告：该特性还在实验阶段，但是已经在生产和测试环境下经过大量压力测试。
#
# 什么是主动的碎片整理?
# -------------------------------
#
# Active (online) defragmentation allows a Redis server to compact the
# spaces left between small allocations and deallocations of data in memory,
# thus allowing to reclaim back memory.
# 在线碎片整理可以让redis收集在小的分配之间的遗留空间，释放不需要的内存数据。
# 从而可以重新分配这些内存空间
#
# Fragmentation is a natural process that happens with every allocator (but
# less so with Jemalloc, fortunately) and certain workloads. Normally a server
# restart is needed in order to lower the fragmentation, or at least to flush
# away all the data and create it again. However thanks to this feature
# implemented by Oran Agra for Redis 4.0 this process can happen at runtime
# in an "hot" way, while the server is running.
# 出现内存碎片是很正常的，每个内存分配器都会有内存碎片，Jemelloc出现内存碎片还算少的。
# 一般来说都需要重启进程才能降低碎片率，或者至少也要重新flush一遍数据然后再重新生成数据。
# 但是幸运的是在redis4.0版本，实现了热更新，即redis在运行过程中完成碎片整理
#
# Basically when the fragmentation is over a certain level (see the
# configuration options below) Redis will start to create new copies of the
# values in contiguous memory regions by exploiting certain specific Jemalloc
# features (in order to understand if an allocation is causing fragmentation
# and to allocate it in a better place), and at the same time, will release the
# old copies of the data. This process, repeated incrementally for all the keys
# will cause the fragmentation to drop back to normal values.
# 基本上，当碎片率超过一定水平（下面有配置参数）时，redis会利用Jemelloc的特性在一段连续的内存
# 空间中创建某些数据的副本（Jemelloc的这个特性可以分析出哪些数据的分配导致了碎片的出现，然后将其迁移到更合适的地方）。
# 同时释放旧的数据。这样就完成了一次数据的迁移。
# 这个过程会持续的进行，直到所有导致碎片的数据都迁移到合适的位置
#
# Important things to understand:
# 需要理解的重要内容：
#
# 1. This feature is disabled by default, and only works if you compiled Redis
#    to use the copy of Jemalloc we ship with the source code of Redis.
#    This is the default with Linux builds.
# 1. 这个特性默认时关闭的。并且只有你在编译redis时指定了使用Jemalloc进行编译，后续才能启用这个特性。
#    使用linux进行构建时的默认内存分配器就是Jemalloc。
#    但是我在make时遇到jemalloc/jemalloc.h: 没有那个文件或目录
#    因为我的机器上没有jemalloc
#    一个解决方案时在make时指定使用libc作为内存分配器。make MALLOC=libc
#    另一个方案就是安装Jemalloc。jemalloc被证明比libc有更少的碎片问题。
#	还没有实验。
#    wget https://github.com/jemalloc/jemalloc/releases/download/5.0.1/jemalloc-5.0.1.tar.bz2
#	tar -jxvf jemalloc-5.0.1.tar.bz2
#	cd jemalloc-5.0.1
#	yum install autogen autoconf
#	 
#	./autogen.sh
#	make -j2
#	make install
#	ldconfig
#	cd ../
#	rm -rf jemalloc-5.0.1 jemalloc-5.0.1.tar.bz2
#
# 2. You never need to enable this feature if you don't have fragmentation
#    issues.
# 2. 如果你没有碎片问题，就不需要启用这个特性
#
# 3. Once you experience fragmentation, you can enable this feature when
#    needed with the command "CONFIG SET activedefrag yes".
# 3. 当你遇到碎片问题时，可以使用"CONFIG SET activedefrag yes"这个命令启用在线碎片整理功能
#
# The configuration parameters are able to fine tune the behavior of the
# defragmentation process. If you are not sure about what they mean it is
# a good idea to leave the defaults untouched.
# 下面配置参数可以用来调整碎片整理的行为。
# 但是在调整前你必须搞懂这些参数的含义，否则还是用默认值为好。

# Enabled active defragmentation
# 启用在线碎片整理特性
# activedefrag yes

# Minimum amount of fragmentation waste to start active defrag
# 碎片整理开启的最小量。也就是碎片在100mb以下，不会进行碎片整理。当碎片达到 100mb 时，开启内存碎片整理
# active-defrag-ignore-bytes 100mb

# Minimum percentage of fragmentation to start active defrag
# 当碎片率超过到10%时，开启内存碎片整理
# active-defrag-threshold-lower 10

# Maximum percentage of fragmentation at which we use maximum effort
# 碎片率超过100%时，尽最大努力进行整理
# active-defrag-threshold-upper 100

# Minimal effort for defrag in CPU percentage
# 碎片整理时使用的最小cpu百分比
# active-defrag-cycle-min 5

# Maximal effort for defrag in CPU percentage
# 碎片整理时使用的最大cpu百分比，也就是尽最大努力
# active-defrag-cycle-max 75

# Maximum number of set/hash/zset/list fields that will be processed from
# the main dictionary scan
# 碎片整理时对于set/hash/zset/list类型数据的最大扫描字段
# active-defrag-max-scan-fields 1000

# It is possible to pin different threads and processes of Redis to specific
# CPUs in your system, in order to maximize the performances of the server.
# This is useful both in order to pin different Redis threads in different
# CPUs, but also in order to make sure that multiple Redis instances running
# in the same host will be pinned to different CPUs.
# 可以将不同的redis的线程和进程绑定到特定的cpu上，以便最大化利用服务器的性能。
# 这项能力在将redis的不同线程绑定到不同cpu时很有用，更有用的场景是在一台server上
# 启动多个redis实例，可以将不同的redis绑定到指定的cpu上。
#
# Normally you can do this using the "taskset" command, however it is also
# possible to this via Redis configuration directly, both in Linux and FreeBSD.
# 可以用taskset命令，（linux的绑核命令）
# 也可以直接通过redis的配置文件实现
#
# You can pin the server/IO threads, bio threads, aof rewrite child process, and
# the bgsave child process. The syntax to specify the cpu list is the same as
# the taskset command:
# 你可以绑server/IO threads, bio threads, aof rewrite child process, 和the bgsave child process
# 语法和taskset命令一样
#
# Set redis server/io threads to cpu affinity 0,2,4,6:
# 设置server/io线程和cpu 0，2，4，6有亲和关系
# server_cpulist 0-7:2
#
# Set bio threads to cpu affinity 1,3:
# 设置bio线程和cpu 1，3有亲和关系
# bio_cpulist 1,3
#
# Set aof rewrite child process to cpu affinity 8,9,10,11:
# 设置aod重新子进程和cpu 8，9，10，11有亲和关系
# aof_rewrite_cpulist 8-11
#
# Set bgsave child process to cpu affinity 1,10,11
# 设置bgsave子进程和cpu 1，10，11有亲和关系
# bgsave_cpulist 1,10-11

# In some cases redis will emit warnings and even refuse to start if it detects
# that the system is in bad state, it is possible to suppress these warnings
# by setting the following config which takes a space delimited list of warnings
# to suppress
# 当redis发现操作系统状态有问题时会发出一些warning，有时甚至会拒绝启动
# 可以设置忽略警告。
# 在arm64架构下启动redis会报ARM64-COW-BUG警告，redis不能启动。可以开启这个忽略
# 但是最好还是换X86架构
# ignore-warnings ARM64-COW-BUG
```
