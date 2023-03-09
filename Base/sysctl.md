# sysctl修改Linux内核变量
```
您可以配置Linux(内核)的多个参数或可调参数来控制其行为,无论是在引导时还是在系统运行时按需。
sysctl是一个广泛使用的命令行实用程序,用于在运行时修改或配置内核参数。您可以在/proc/sys/ 目录下找到列出的内核可调参数。
```

它由procfs（proc文件系统）提供支持,procfs是Linux和其他类Unix操作系统中的伪文件系统,为内核数据结构提供接口。它提供有关进程和其他系统信息的信息   

以下是在管理正在运行的Linux系统时候可以使用的10个有用的sysctl命令示例。请注意,您需要root权限才能运行sysctl命令,否则,在调用它时使用sudo命令。  

```
sudo sysctl -a OR  sudo sysctl --all  #列出 Linux 中的所有内核参数
kernel.ostype = Linux                 #变量按以下格式显示  格式<tunable class>.<tunable> = <value>
sudo sysctl -a -N                     #列出所有内核变量名称
sysctl -a | grep memory OR  sysctl --all | grep memory
sysctl -a --deprecated                #列出所有内核变量,包括已弃用的
sysctl -a --deprecated | grep memory
sysctl kernel.ostype                  #列出特定的内核变量值

#临时写入内核变量(增加接收队列的最大大小,该队列存储从网络接收到 NIC（网络接口卡）的环形缓冲区中选取的帧。可以使用变量修改队列大小)
<tunable class>.<tunable>=<value>
sysctl net.core.netdev_max_backlog
sysctl net.core.netdev_max_backlog=1200
sysctl net.core.netdev_max_backlog

sysctl -w net.core.netdev_max_backlog=1200 >> /etc/sysctl.conf  #永久写入内核变量 
sysctl  --system                                                #在Linux中重新加载sysctl.conf 变量
sysctl -p /etc/sysctl.d/10-test-settings.conf OR sysctl --load= /etc/sysctl.d/10-test-settings.conf #从自定义配置文件重新加载设置
sysctl --system --pattern '^net.ipv6'  OR sysctl --system -r memory   #重新加载与模式匹配的设置
man sysctl
```

---

# linux内核参数优化

## Sysctl命令及linux内核参数调整
Sysctl命令用来配置与显示在/proc/sys目录中的内核参数．如果想使参数长期保存,可以通过编辑/etc/sysctl.conf文件来实现  
```
命令格式：
sysctl [-n] [-e] -w variable=value
sysctl [-n] [-e] -p (default /etc/sysctl.conf)
sysctl [-n] [-e] -a

常用参数的意义：
-w 临时改变某个指定参数的值,如
# sysctl -w net.ipv4.ip_forward=1
-a 显示所有的系统参数
-p从指定的文件加载系统参数,默认从/etc/sysctl.conf 文件中加载,如：
# echo 1 > /proc/sys/net/ipv4/ip_forward
# sysctl -w net.ipv4.ip_forward=1
以上两种方法都可能立即开启路由功能,但如果系统重启,或执行了
# service network restart
命令,所设置的值即会丢失,如果想永久保留配置,可以修改/etc/sysctl.conf文件,将 net.ipv4.ip_forward=0改为net.ipv4.ip_forward=1
```
## linux内核参数调整有两种方式
- 修改/proc下内核参数文件内容   
  不能使用编辑器来修改内核参数文件,理由是由于内核随时可能更改这些文件中的任意一个,另外,这些内核参数文件都是虚拟文件,实际中不存在,因此不能使用编辑器进行编辑,而是使用echo命令,然后从命令行将输出重定向至/proc下所选定的文件中。如将timeout_timewait参数设置为30秒  
  echo 30 > /proc/sys/net/ipv4/tcp_fin_timeout  
  参数修改后立即生效,但是重启系统后,该参数又恢复成默认值。因此,想永久更改内核参数,需要修改/etc/sysctl.conf文件  
- 修改/etc/sysctl.conf文件  
  检查sysctl.conf文件,如果已经包含需要修改的参数,则修改该参数的值,如果没有需要修改的参数,在sysctl.conf文件中添加参数  
  如net.ipv4.tcp_fin_timeout=30保存退出后,可以重启机器使参数生效,如果想使参数马上生效,也可以执行如下命令sysctl -p  

## sysctl.conf文件中参数设置及说明
```
/proc/sys/net/core/wmem_max #最大socket写buffer,可参考的优化值:873200
/proc/sys/net/core/rmem_max #最大socket读buffer,可参考的优化值:873200
/proc/sys/net/ipv4/tcp_wmem #TCP写buffer,可参考的优化值: 8192 436600 873200
/proc/sys/net/ipv4/tcp_rmem #TCP读buffer,可参考的优化值: 32768 436600 873200
/proc/sys/net/ipv4/tcp_mem  #同样有3个值,意思是
  net.ipv4.tcp_mem[0]:低于此值,TCP没有内存压力.
  net.ipv4.tcp_mem[1]:在此值下,进入内存压力阶段.
  net.ipv4.tcp_mem[2]:高于此值,TCP拒绝分配socket. #上述内存单位是页,而不是字节.可参考的优化值是:786432 1048576 1572864
/proc/sys/net/core/netdev_max_backlog #进入包的最大设备队列.默认是300,对重负载服务器而言,该值太低,可调整到1000
/proc/sys/net/core/somaxconn  #listen()的默认参数,挂起请求的最大数量.默认是128.对繁忙的服务器,增加该值有助于网络性能.可调整到256.
/proc/sys/net/core/optmem_max #socket buffer的最大初始化值,默认10K
/proc/sys/net/ipv4/tcp_max_syn_backlog #进入SYN包的最大请求队列.默认1024.对重负载服务器,可调整到2048
/proc/sys/net/ipv4/tcp_retries2  #TCP失败重传次数,默认值15,意味着重传15次才彻底放弃.可减少到5,尽早释放内核资源.

/proc/sys/net/ipv4/tcp_keepalive_time  #tcp_keepalive_time = 7200 seconds (2 hours)
/proc/sys/net/ipv4/tcp_keepalive_intvl #tcp_keepalive_intvl = 75 seconds
/proc/sys/net/ipv4/tcp_keepalive_probes  #tcp_keepalive_probes = 9   #这3个参数与TCP KeepAlive有关.默认值是:
意思是如果某个TCP连接在idle2个小时后,内核才发起probe.如果probe9次(每次75秒)不成功,内核才彻底放弃,认为该连接已失效.对服务器而言,显然上述值太大. 可调整到:
/proc/sys/net/ipv4/tcp_keepalive_time 1800
/proc/sys/net/ipv4/tcp_keepalive_intvl 30
/proc/sys/net/ipv4/tcp_keepalive_probes 3

/proc/sys/net/ipv4/ip_local_port_range  #指定端口范围的一个配置,默认是32768 61000,已够大.
net.ipv4.tcp_syncookies = 1 #表示开启SYNCookies。当出现SYN等待队列溢出时,启用cookies来处理,可防范少量SYN攻击,默认为0,表示关闭；
net.ipv4.tcp_tw_reuse = 1   #表示开启重用。允许将TIME-WAIT sockets重新用于新的TCP连接,默认为0,表示关闭；
net.ipv4.tcp_tw_recycle = 1 #表示开启TCP连接中TIME-WAIT sockets的快速回收,默认为0,表示关闭。
net.ipv4.tcp_fin_timeout = 30 #表示如果套接字由本端要求关闭,这个参数决定了它保持在FIN-WAIT-2状态的时间。
net.ipv4.tcp_keepalive_time = 1200 #表示当keepalive起用的时候,TCP发送keepalive消息的频度。缺省是2小时,改为20分钟。
net.ipv4.ip_local_port_range = 1024 65000 #表示用于向外连接的端口范围。缺省情况下很小：32768到61000,改为1024到65000。
net.ipv4.tcp_max_syn_backlog = 8192 #表示SYN队列的长度,默认为1024,加大队列长度为8192,可以容纳更多等待连接的网络连接数。
net.ipv4.tcp_max_tw_buckets = 5000 #表示系统同时保持TIME_WAIT套接字的最大数量,如果超过这个数字,TIME_WAIT套接字将立刻被清除并打印警告信息。默认为 180000,改为 5000。对于Apache、Nginx等服务器,上几行的参数可以很好地减少TIME_WAIT套接字数量,但是对于Squid,效果却不大。此项参数可以控制TIME_WAIT套接字的最大数量,避免Squid服务器被大量的TIME_WAIT套接字拖死。

#案例1：实现网关的MASQUERADE
#具体功能：内网网卡是eth1,外网eth0,使得内网指定本服务做网关可以访问外网
EXTERNAL="eth0"
iptables -t nat -A POSTROUTING -o $EXTERNAL -j MASQUERADE

#案例2：实现网关的简单端口映射
#具体功能：实现外网通过访问网关的外部ip:80,可以直接达到访问私有网络内的一台主机192.168.1.10:80效果
LOCAL_EX_IP=11.22.33.44 #设定网关的外网卡ip,对于多ip情况,参考《如何让你的Linux网关更强大》系列文章
LOCAL_IN_IP=192.168.1.1 #设定网关的内网卡ip
INTERNAL="eth1" #设定内网卡
# 这一步开启ip转发支持,这是NAT实现的前提
echo 1 > /proc/sys/net/ipv4/ip_forward
# 加载需要的ip模块,下面两个是ftp相关的模块,如果有其他特殊需求,也需要加进来
modprobe ip_nat_ftp
# 这一步实现目标地址指向网关外部ip:80的访问都吧目标地址改成192.168.1.10:80
iptables -t nat -A PREROUTING -d $LOCAL_EX_IP -p tcp --dport 80 -j DNAT --to 192.168.1.10
# 这一步实现把目标地址指向192.168.1.10:80的数据包的源地址改成网关自己的本地ip,这里是192.168.1.1
iptables -t nat -A POSTROUTING -d 192.168.1.10 -p tcp --dport 80 -j SNAT --to $LOCAL_IN_IP
# 在FORWARD链上添加到192.168.1.10:80的允许,否则不能实现转发
iptables -A FORWARD -o $INTERNAL -d 192.168.1.10 -p tcp --dport 80 -j ACCEPT
# 通过上面重要的三句话之后,实现的效果是,通过网关的外网ip:80访问,全部转发到内网的192.168.1.10:80端口,实现典型的端口映射
# 特别注意,所有被转发过的数据都是源地址是网关内网ip的数据包,所以192.168.1.10上看到的所有访问都好像是网关发过来的一样,而看不到外部ip
# 一个重要的思想：数据包根据“从哪里来,回哪里去”的策略来走,所以不必担心回头数据的问题
# 现在还有一个问题,网关自己访问自己的外网ip:80,是不会被NAT到192.168.1.10的,这不是一个严重的问题,但让人很不爽,解决的方法如下：
iptables -t nat -A OUTPUT -d $LOCAL_EX_IP -p tcp --dport 80 -j DNAT --to 192.168.1.10
获取系统中的NAT信息和诊断错误
了解/proc目录的意义
在Linux系统中,/proc是一个特殊的目录,proc文件系统是一个伪文件系统,它只存在内存当中,而不占用外存空间。它包含当前系统的一些参数（variables）和状态（status）情况。它以文件系统的方式为访问系统内核数据的操作提供接口
通过/proc可以了解到系统当前的一些重要信息,包括磁盘使用情况,内存使用状况,硬件信息,网络使用情况等等,很多系统监控工具（如HotSaNIC）都通过/proc目录获取系统数据。
另一方面通过直接操作/proc中的参数可以实现系统内核参数的调节,比如是否允许ip转发,syn-cookie是否打开,tcp超时时间等。
获得参数的方式：
第一种：cat /proc/xxx/xxx,如 cat
/proc/sys/net/ipv4/conf/all/rp_filter

第二种：sysctl xxx.xxx.xxx,如 sysctl
net.ipv4.conf.all.rp_filter

改变参数的方式：
第一种：echo value > /proc/xxx/xxx,如 echo 1 >
/proc/sys/net/ipv4/conf/all/rp_filter

第二种：sysctl [-w] variable=value,如 sysctl [-w]
net.ipv4.conf.all.rp_filter=1

以上设定系统参数的方式只对当前系统有效,重起系统就没了,想要保存下来,需要写入/etc/sysctl.conf文件中

通过执行 man 5 proc可以获得一些关于proc目录的介绍
查看系统中的NAT情况
和NAT相关的系统变量
/proc/slabinfo：内核缓存使用情况统计信息（Kernel slab allocator statistics）
/proc/sys/net/ipv4/ip_conntrack_max：系统支持的最大ipv4连接数,默认65536（事实上这也是理论最大值）
/proc/sys/net/ipv4/netfilter/ip_conntrack_tcp_timeout_established 已建立的tcp连接的超时时间,默认432000,也就是5天
和NAT相关的状态值
/proc/net/ip_conntrack：当前的前被跟踪的连接状况,nat翻译表就在这里体现（对于一个网关为主要功能的Linux主机,里面大部分信息是NAT翻译表）
/proc/sys/net/ipv4/ip_local_port_range：本地开放端口范围,这个范围同样会间接限制NAT表规模

# 1. 查看当前系统支持的最大连接数
cat /proc/sys/net/ipv4/ip_conntrack_max
# 值：默认65536,同时这个值和你的内存大小有关,如果内存128M,这个值最大8192,1G以上内存这个值都是默认65536
# 影响：这个值决定了你作为NAT网关的工作能力上限,所有局域网内通过这台网关对外的连接都将占用一个连接,如果这个值太低,将会影响吞吐量

# 2. 查看tcp连接超时时间
cat /proc/sys/net/ipv4/netfilter/ip_conntrack_tcp_timeout_established
# 值：默认432000（秒）,也就是5天
# 影响：这个值过大将导致一些可能已经不用的连接常驻于内存中,占用大量链接资源,从而可能导致NAT ip_conntrack: table full的问题
# 建议：对于NAT负载相对本机的 NAT表大小很紧张的时候,可能需要考虑缩小这个值,以尽早清除连接,保证有可用的连接资源；如果不紧张,不必修改

# 3. 查看NAT表使用情况（判断NAT表资源是否紧张）
# 执行下面的命令可以查看你的网关中NAT表情况
cat /proc/net/ip_conntrack

# 4. 查看本地开放端口的范围
cat /proc/sys/net/ipv4/ip_local_port_range
# 返回两个值,最小值和最大值
# 下面的命令帮你明确一下NAT表的规模
wc -l /proc/net/ip_conntrack
#或者
grep ip_conntrack /proc/slabinfo | grep -v expect | awk '{print $1 ',' $2;}'
# 下面的命令帮你明确可用的NAT表项,如果这个值比较大,那就说明NAT表资源不紧张
grep ip_conntrack /proc/slabinfo | grep -v expect | awk '{print $1 ',' $3;}'
# 下面的命令帮你统计NAT表中占用端口最多的几个ip,很有可能这些家伙再做一些bt的事情,嗯bt的事情:-)
cat /proc/net/ip_conntrack | cut -d ' ' -f 10 | cut -d '=' -f 2 | sort | uniq -c | sort -nr | head -n 10
# 上面这个命令有点瑕疵cut -d' ' -f10会因为命令输出有些行缺项而造成统计偏差,下面给出一个正确的写法：
cat /proc/net/ip_conntrack | perl -pe s/^\(.*?\)src/src/g | cut -d ' ' -f1 | cut -d '=' -f2 | sort | uniq -c | sort -nr | head -n 10
```

# [linux内核参数优化](https://blog.51cto.com/liuzhengwei521/2311250)  
![sysctl](https://s2.51cto.com/images/blog/201901/18/5b3b0289ea4af2db3726919bb984dc2a.png?x-oss-process=image/watermark,size_16,text_QDUxQ1RP5Y2a5a6i,color_FFFFFF,t_30,g_se,x_10,y_10,shadow_20,type_ZmFuZ3poZW5naGVpdGk=/format,webp/resize,m_fixed,w_1184)  

[Linux内核优化参数](https://www.cnblogs.com/struggle-1216/p/12901341.html)  
[linux系统参数调优分类](https://blog.csdn.net/wuxiaobingandbob/article/details/98942294)  


