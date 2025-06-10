# 系统安全加固
1、基础组件及探测工具部署
```bash
yum clean all && yum makecache fast && yum repolist all
yum install -y  \
vim  nc lsof sysstat unzip net-tools bash-completion ntpdate lrzsz gcc \
gcc-c++ gcc-gfortran  tree grep expect libaio psmisc tree yum-utils  \
wget  bash-completion ntpdate  binutils libXt-devel zlib-devel \
xz-devel pcre-devel bzip2-devel readline-devel iptables iptables-services

#sysstat(sar、iostat、mpstat、pidstat、nfsiostat、cifsiostat)
#sar -P ALL 2 5 
#sar -f /var/log/sa/X #查之前CPU使用情况 
#mpstat  -P ALL 2 5 
```

2、标准时间及字符集
```bash
ln -sf /usr/share/zoneinfo/Asia/Shanghai  /etc/localtime
env |grep 'LANG'
LANG=en_US.UTF-8
export TMOUT=300  #会话时长
```


3、ssh优化
```bash
sed -i -e 's/GSSAPIAuthentication yes/GSSAPIAuthentication no/' -e  '/#UseDNS yes/a\UseDNS no'  /etc/ssh/sshd_config
systemctl restart sshd
```

4、句柄文件描述符
```bash
sed -i '/# End of file/i\* hard nofile 655350\n* soft nofile 655350\nroot hard nofile 655350\nroot soft nofile 655350' /etc/security/limits.conf
sed -i 's/4096/655350/'  /etc/security/limits.d/*0-nproc.conf
ulimit -a|grep -E "open files|max user processes"
```

5、history标准化(添加时间戳)
```bash
cat >> /etc/bashrc << 'EOF'
alias vi='vim'
HISTSIZE=100000
HISTCONTROL=ignoredups
HISTTIMEFORMAT="%F %T "
ulimit -s unlimited
EOF
source /etc/bash.bashrc
```


6、系统自启服务开关管理
```bash
#服务关闭 Bluetooth postfix cups cpuspeed vsftpd dhcpd nfs nfslock ypbind rpcbind portreserve xinted 
#开启rc.local
chmod +x /etc/rc.d/rc.local /etc/rc.local 
systemctl daemon-reload   && sudo systemctl enable rc-local && sudo systemctl start  rc-local
#systemctl list-units --type=service
#systemctl list-dependencies multi-user.target | grep rc-local
#systemctl list-unit-files|grep enabled #查开机自动服务
```

7、禁用SeLinux
```bash
sed -i "s#SELINUX=enforcing#SELINUX=disabled#g" /etc/sysconfig/selinux
sed -i 's/=permissive/=disabled/'      /etc/selinux/config
sestatus -v
SELinux status:                 disabled
```

8、内核参数优化
```bash
net.ipv4.tcp_fin_timeout = 2
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_tw_recycle = 1
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_keepalive_time = 600
net.ipv4.ip_local_port_range = 4000 65000
net.ipv4.tcp_max_syn_backlog = 16384
net.ipv4.tcp_max_tw_buckets = 36000
net.ipv4.route.gc_timeout = 100
net.ipv4.tcp_syn_retries = 1
net.ipv4.tcp_synack_retries = 0
net.core.somaxconn = 16384
net.core.netdev_max_backlog = 16384
net.ipv4.tcp_max_orphans = 16384
net.netfilter.nf_conntrack_max = 25000000
net.netfilter.nf_conntrack_tcp_timeout_established = 180
net.netfilter.nf_conntrack_tcp_timeout_time_wait = 120
net.netfilter.nf_conntrack_tcp_timeout_close_wait = 60
net.netfilter.nf_conntrack_tcp_timeout_fin_wait = 120

#kernel
    kernel.sysrq = 0
    kernel.core_uses_pid = 1
    kernel.msgmnb = 65536
    kernel.msgmax = 65536
    kernel.shmmax = 68719476736
    kernel.shmall = 4294967296
#socket
    net.ipv4.ip_local_port_range = 1024 65000
    net.ipv4.ip_forward = 1  
    net.ipv4.tcp_timestamps = 0
    net.ipv4.tcp_sack = 1
    net.ipv4.tcp_window_scaling = 1
    net.ipv4.conf.default.rp_filter = 1
    net.ipv4.conf.default.accept_source_route = 0
#socket mem
    net.ipv4.tcp_mem = 94500000 915000000 927000000
    net.ipv4.tcp_rmem = 4096 87380 4194304
    net.ipv4.tcp_wmem = 4096 16384 4194304   
    net.core.wmem_default = 8388608
    net.core.rmem_default = 8388608
    net.core.rmem_max = 16777216
    net.core.wmem_max = 16777216
#conn
    net.core.netdev_max_backlog = 262144
    net.core.somaxconn = 262144
    net.ipv4.tcp_max_orphans = 3276800
#Timewait
    net.ipv4.tcp_max_tw_buckets = 6000
    net.ipv4.tcp_tw_recycle = 1
    net.ipv4.tcp_tw_reuse = 1
#sync
    net.ipv4.tcp_syn_retries = 1
    net.ipv4.tcp_synack_retries = 1
    net.ipv4.tcp_max_syn_backlog = 262144
    net.ipv4.tcp_syncookies = 1
#fin
    net.ipv4.tcp_fin_timeout = 1
#keepalive
    net.ipv4.tcp_keepalive_time = 30

#根据业务系统服务来优化具体内核参数
```


9 、应用服务端口标准化(源应用服务端口+10000)
```bash
22-->10022    3306--13306
80-->10080    6379--16379
9898-->19898  ...
```


10、账号密码管理(密码使用时间周期、过期、复杂度) 
```bash
cp -a /etc/pam.d/system-auth /etc/pam.d/system-auth.bef
password    requisite     pam_pwquality.so minlen=8 dcredit=-2 ucredit=-1 lcredit=-1 ocredit=-1 try_first_pass local_users_only retry=5 authtok_type=
password    sufficient    pam_unix.so sha512 shadow nullok try_first_pass use_authtok

cp -a /etc/pam.d/sshd /etc/pam.d/sshd.bef 
auth required pam_tally2.so deny=4 unlock_time=36000 even_deny_root root_unlock_time=36000  #用户登录失败N次后锁定用户禁止登陆

awk -F: '($2 == "") { print $1 }' /etc/shadow  #查看空口令账号并删除
awk -F: '($3 == 0) { print $1 }' /etc/passwd   #删除root之外UID为0的用户

usermod -L nobody && usermod -L xx #锁定无用帐号,降低安全风险
chage -m 0 -M 90 -I 5 -W 7 <用户名> #修改系统中当前已存在用户的密码策略
chage -m 0 -M 90 -I 5 -W 7 <用户名>

echo "LASTLOG_ENAB yes" >> /etc/login.defs #记录用户登录信息
grep -E "PASS_MAX|PASS_MIN|PASS_WARN" /etc/login.defs   #PASS_MIN_LEN=8
awk -F: '($2 == "") { print $1 }' /etc/shadow  #查看空口令code

```
PASS_MIN_LEN    5
sed -i.bak 's#PASS_MIN_LEN.*$#PASS_MIN_LEN    12#g' /etc/login.defs

11、开启防火墙
```bash
#nfs
iptables -A INPUT -s 172.16.216.0/27 -p udp -m state --state NEW -m multiport --dports $(rpcinfo -p|awk 'NR>1&&$3~/udp/&&!a[$4]++{c=c?c","$4:$4}END{print c}') -j ACCEPT
iptables -A INPUT -s 172.16.216.0/27 -p tcp -m state --state NEW -m multiport --dports $(rpcinfo -p|awk 'NR>1&&$3~/tcp/&&!a[$4]++{c=c?c","$4:$4}END{print c}') -j ACCEPT
iptables-save or iptables-save > x.log
service iptables save
systemctl enable iptables.service  && systemctl restart iptables
iptables -L -n
iptables -L -n --line-number |grep  X

systemctl disable firewalld && systemctl mask firewalld
iptables -L -n
iptables -F
iptables -X
iptables -Z
iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -I INPUT -p icmp --icmp-type 8 -j ACCEPT
iptables -A INPUT -p tcp -j LOG --log-prefix "iptables denied"
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT  
iptables -I INPUT -s 172.16.216.0/27 -p tcp --dport 10022 -j ACCEPT
iptables -I INPUT -s 172.16.219.175/32 -p tcp --dport 10022 -j ACCEPT
iptables -I INPUT -s 172.16.216.0/27 -p tcp --dport 16379 -j ACCEPT
iptables -I INPUT -s 172.16.219.175/32 -p tcp --dport 16379 -j ACCEPT
iptables -I INPUT -s 172.16.216.0/27 -p tcp --dport 16380 -j ACCEPT
iptables -I INPUT -s 172.16.219.175/32 -p tcp --dport 16380 -j ACCEPT
#iptables -A INPUT -j REJECT  #endone
iptables-save #or iptables-save > x.log
service iptables save
systemctl enable iptables.service  && systemctl restart iptables

iptables-save && service iptables save && systemctl restart iptables 

iptables -nL
iptables -L -n
iptables -nvL
iptables -L -n --line-number   |grep  XX
iptables -vL -n --line-numbers |grep  XX  #参数-v包括报文的个数与大小



#根据系统业务指定相关策略
#iptables -A INPUT -m state --state NEW -m tcp -p tcp --dport 22 -j ACCEPT
表
iptables -t filter --list
iptables -t mangle --list    #空
iptables -t nat --list
iptables -t raw --list       #空
iptables -t security --list  #空

multiport一次性在单条规则中写入多个端口
iptables -A INPUT  -p tcp -m multiport --dports 22,80,443 -j ACCEPT
iptables -A OUTPUT -p tcp -m multiport --sports 22,80,443 -j ACCEPT
iptables -I INPUT -m iprange --src-range 192.168.80.109-192.168.80.121 -p tcp -d 192.168.11.4 --dport 80 -j DROP
iptables -I INPUT -s 172.16.219.175/32,172.16.216.0/27 -p tcp --dport 19090 -j ACCEPT
```



# xoxo安全防火墙配置策略
| 服务器Ip   | 源地址 |   目的端口   |  访问源状态  |  服务说明  | 备注  |
| --------- | :-------: | :--------: | :-------- | :-------- | :-------- |
| 172.16.216.183-ecology1 |  | [10022、9081,8444,18989] |  |  |  |
| 172.16.216.184-ecology2 |  | [10022、9081,8444,18989] |  |  | |
| 172.16.216.162-em-1  |  | [10022、19090,18999,17070,15222] |  |  |  |
| 172.16.216.166-em-2  |  | [10022、19090,18999,17070,15222] |  |  |  |
| 172.16.216.171-MySQL1 |  | [10022、13306] |  |  | |
| 172.16.216.172-MySQL2 |  | [10022、13306] |  | |  |
| 172.16.216.168-redis |  | [10022、16379] | |  | |
| 172.16.216.169-none | | [10022、16380] |  |  |  |
| 172.16.216.170-none |  | [10022、16380] |  |  |  |
| 172.16.216.167-nfs |  | [10022、nfs] |  |  |  |
| 172.16.216.173-wps |  | [10022、16380] |  |  |  |

![安全防火墙配置策略](pic/iptables.png)

iptables -A INPUT -s 172.16.216.173/32 -p tcp --dport 102222 -j REJECT
```bash
#ecology1
#iptables -I INPUT  -p tcp -m multiport --dports 9081,8444 -j ACCEPT
#iptables -A INPUT -s 218.6.242.120/32,172.16.23.77/32,172.16.219.175/32,172.16.216.0/27  -p tcp -m multiport  --dports 18989,1111 -j ACCEPT 
#iptables -A INPUT -s 172.16.216.0/27 -p tcp -m multiport  --dports 9081,8444 -j ACCEPT
#iptables -A INPUT -s 218.6.242.120/32,172.16.23.77/32,172.16.219.175/32,172.16.216.0/27  -p tcp  --dport 18989 -j ACCEPT #单个
iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -A INPUT -p icmp --icmp-type 8 -j ACCEPT

iptables -I INPUT -s 172.16.216.0/24,172.16.219.175/32 -p tcp --dport 10022 -j ACCEPT
iptables -A INPUT -s 172.16.216.0/24 -p tcp -m multiport  --dports 9081,8444 -j ACCEPT
iptables -A INPUT -s 218.6.242.120/32,172.16.23.0/24,172.16.219.175/32,172.16.216.0/24  -p tcp  --dport 18989 -j ACCEPT
iptables -A INPUT -s 0.0.0.0/0  -p tcp -m multiport  --dports 10022,9081,8444,18989 -j DROP
iptables-save && service iptables save && systemctl restart iptables 

#iptables -A INPUT -s 218.6.242.120/32,172.16.23.0/24,172.16.219.175/32,172.16.216.0/24  -p tcp -m multiport --dport 18989 -j ACCEPT

F5--test
iptables -F
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT DROP
iptables -A INPUT -i eth0 -p tcp -m multiport --dports 10022,18989 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -o eth0 -p tcp -m multiport --sports 10022,18989 -m state --state ESTABLISHED -j ACCEPT
iptables-save && service iptables save && systemctl restart iptables 


#em
iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -A INPUT -p icmp --icmp-type 8 -j ACCEPT
iptables -I INPUT -s 172.16.219.175/32,172.16.216.0/24 -p tcp -m multiport --dports 10022,19090 -j ACCEPT
iptables -A INPUT -s 218.6.242.120/32,172.16.23.0/24,172.16.219.175/32,172.16.216.0/24  -p tcp -m multiport  --dports 18999,15222,17070 -j ACCEPT 
iptables -A INPUT -s 0.0.0.0/0  -p tcp -m multiport  --dports 10022,19090,18999,15222,17070 -j DROP 
iptables-save && service iptables save && systemctl restart iptables 



#mysql
#获取mysqld进程ID
netstat -anpl|grep  $(ps -A |grep "mysqld"| awk '{print $1}')
netstat -anpl|grep  $(pidof "mysqld")
netstat -anpl|grep  $(pgrep "mysqld")

172.16.216.183:35182    ESTABLISHED  #ecology
172.16.216.184:56954    ESTABLISHED  #ecology
172.16.216.172:45932    ESTABLISHED  #mysql-slave
172.16.216.167:57122    ESTABLISHED 23813/mysqld   

iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -A INPUT -p icmp --icmp-type 8 -j ACCEPT
iptables -A INPUT -s 172.16.219.175/32,172.16.216.0/24  -p tcp -m multiport  --dports 10022,13306 -j ACCEPT
iptables -A INPUT -s 0.0.0.0/0  -p tcp -m multiport  --dports 10022,13306 -j DROP 
iptables-save && service iptables save && systemctl restart iptables 

#redis
netstat -anpl|grep  $(pgrep "redis")
172.16.216.166:46116    ESTABLISHED 15878/redis-server   #em
172.16.216.162:49488    ESTABLISHED 15878/redis-server   #em
172.16.216.183:53494    ESTABLISHED 15878/redis-server   #ecology
172.16.216.184:55188    ESTABLISHED 15878/redis-server   #ecology
172.16.216.167:47820    ESTABLISHED 15878/redis-server   
172.16.219.175:53645    ESTABLISHED 15878/redis-server 

iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -A INPUT -p icmp --icmp-type 8 -j ACCEPT
iptables -A INPUT -s 172.16.219.175/32,172.16.216.0/27  -p tcp -m multiport  --dports 10022,16379 -j ACCEPT
iptables -A INPUT -s 0.0.0.0/0  -p tcp -m multiport  --dports 10022,16379 -j DROP 
iptables-save && service iptables save && systemctl restart iptables 

#nfs
iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -A INPUT -p icmp --icmp-type 8 -j ACCEPT
iptables -A INPUT -p tcp -j LOG --log-prefix "iptables denied"
iptables -A INPUT -s 172.16.219.175/32,172.16.216.0/24  -p tcp -m multiport  --dports 10022,1157,4118 -j ACCEPT
iptables -A INPUT -s 172.16.216.0/24 -p udp -m state --state NEW -m multiport --dports $(rpcinfo -p|awk 'NR>1&&$3~/udp/&&!a[$4]++{c=c?c","$4:$4}END{print c}') -j ACCEPT
iptables -A INPUT -s 172.16.216.0/24 -p tcp -m state --state NEW -m multiport --dports $(rpcinfo -p|awk 'NR>1&&$3~/tcp/&&!a[$4]++{c=c?c","$4:$4}END{print c}') -j ACCEPT
iptables -A INPUT -s 0.0.0.0/0  -p tcp -m multiport  --dports 10022,1157,4118 -j DROP 
iptables -A INPUT  -p tcp -m state --state NEW -m multiport --dports $(rpcinfo -p|awk 'NR>1&&$3~/tcp/&&!a[$4]++{c=c?c","$4:$4}END{print c}') -j DROP
iptables-save && service iptables save && systemctl restart iptables 

#wps 

```


https://www.keepassx.org/downloads/index.html
https://keepass.info/download.html
https://blog.csdn.net/axutongxue/article/details/118696485


iptables -A INPUT -s 172.16.219.168/32,172.16.219.185/32,172.16.216.0/24  -p tcp -m multiport  --dports 10022,1157,4118 -j ACCEPT
iptables -A INPUT -s 172.16.219.168/32  -p tcp -m multiport  --dports 10022,1157,4118 -j ACCEPT



iptables -I INPUT -s 172.16.219.185/32  -p tcp -m multiport  --dports 10022,16379 -j ACCEPT
iptables-save && service iptables save && systemctl restart iptables 
