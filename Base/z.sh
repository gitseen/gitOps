#!/bin/bash
#!/usr/bin/env bash
hostnamectl set-hostname --static nginx-redis
echo 'export PS1='"'"'\[\e[1;32m\]\u@\h_\[\e[1;33m\]$(ip -4 addr show eth0 | grep 172.30 | grep -oP "(?<=inet ).*(?=/)")\[\e[m\] \[\e[1;34m\]\w\[\e[m\] \$ '"'" | tee -a ~/.bashrc >/dev/null
=================================================
github hosts: https://ping.chinaz.com/github.com

###    https://www.zhuangbi.info/beta/builders ##装逼大全
https://blog.csdn.net/bigwood99/article/details/105187553

JIccZA==
rpm -qa | grep java | xargs rpm -e --nodeps 

mount | column -t # 查看挂接的分区状态

dmesg |grep -i virtual 
lshw -class system
hostnamectl |grep Chassis 
dmesg|grep -i dmi: 
dmidecode -s system-product-name


hostname -I | sed 's/^\([0-9\.]*\).*/\1/'
hostname -I | sed 's/^\([0-9]\{1,3\}\(\.[0-9]\{1,3\}\)\{3\}\).*/\1/'

tree  -L 2|grep 'Dockerfile' -C 2
tree -d -L 3
tree -d -N  -L 3


echo "init-containers..."|tee -a file

iptables -nL -v

#Linux下如何寻找相同文件  https://www.toutiao.com/i6841132404837450252/
#linux之history使用技巧   https://www.toutiao.com/i7016326172191801868/
#Linux服务器总是被猜测密码怎么办？这个脚本帮你简单加固 https://www.toutiao.com/i7016309943036953121/
#Linux服务器磁盘坏道的修复过程 https://www.toutiao.com/i7015403643402994206/

#history
1、检查是linux服务器否开启历史记录功能
set -o | grep history

2、关闭历史记录功能
set +o history

3、开启历史记录功能
set -o history
set -o |grep history
history         on



ulimit -n  # 查看当前用户可用最大句柄
sysctl -a | grep fs.file-max  # 查看内核级的文件句柄最大限制值
cat /proc/sys/fs/file-nr

#/etc/目录下以任意一位数字开头，并以非数字结尾的的文件
ls /etc | grep "^[0-9].*[^0-9]$"


2>&1 解释  将标准错误 2 重定向到标准输出 &1 ，标准输出 &1 再被重定向输入到 runoob.log 文件中。
0 – stdin (standard input，标准输入)
1 – stdout (standard output，标准输出)
2 – stderr (standard error，标准错误输出)
#--------------------------------------------------------------------#

tar -ztvf xx  #不解压查看tar.gz包内文件
tar -zcvf 1.tgz --exclude='*.log' --exclude='*.png' /www #打包www除去.log和.png文件
tar -zcf  1.tgz ./* --exclude=c.txt #--exclude后相对路径
tar -tf   1.tgz | grep c.txt #验证c.txt是否已去除了

https://www.toutiao.com/i6752074204633367047/ #shell 批量改名


axel -n  #多线程下载
log=$(ls -lrt /root/log|awk 'END {print}'|awk '{print $NF}')
scp /root/log/${log} 10.160.3.12:/var/www/html/log/

#蓝鲸CMDB

systemctl status isc-dhcp-server | grep Active | awk '{print $3}' | awk -F '[()]' '{print $2}' #取出running


#CPUS=`lscpu | awk '/^CPU\(s\)/{print $2}'`
#CPURCH=$(lscpu | awk '/^Architecture/{print $NF}')
CPURCH=$(lscpu |grep Architecture|awk '{print $NF}')


lsof https://juejin.im/post/6844904035988799502

#Linux运维常用命令总结
https://blog.51cto.com/wangwei007/1100991
https://mp.weixin.qq.com/s?__biz=MzAwNTM5Njk3Mw==&mid=2247495880&idx=1&sn=c36700ba54390a936a38d11118377b54&chksm=9b1ff04aac68795cb86f2f009626af3acedac9d88286e6dbb1485acc00fe17f7ccb5769f8666&scene=21#wechat_redirect
find -type f -size 0 -exec rm -rf {} \;
find /  -type f -name mysql-connector-java-* |xargs -i mv {} /root/test/
find /  -type f -name  CentOS-7-x86_64-DVD-1810.iso |xargs -i mv {} /root/
find ./ -name 1.txt  -exec wc -l {} +
find ./ -name 1.txt  -exec wc -l {} \;
find  ./*.log -mtime +10  -exec rm -rf {} \;
find . -type f | xargs md5sum | sort
find  /opt/imagesbak -mtime +10 -exec rm -rf {} \;
find ./ -name "*.sh" | awk -F "." '{print $2}' | xargs -i -t mv ./{}.sh  ./{}.txt #批量修改文件名后缀
find ${datadir} -name "*.tar.gz" -mtime +15 -print
find ${datadir} -name "*.tar.gz" -mtime +15 -delete

#记一次 Linux服务器被入侵后的排查思路https://www.jianshu.com/p/afc845cf9cc9  #https://www.cnblogs.com/sparkdev/p/7694202.html
#https://bypass007.github.io/Emergency-Response-Notes/Summary/%E7%AC%AC2%E7%AF%87%EF%BC%9ALinux%E5%85%A5%E4%BE%B5%E6%8E%92%E6%9F%A5.html
#https://www.cnblogs.com/operationhome/p/10907591.html  docker日志

#企业级服务器密码策略管理:https://mp.weixin.qq.com/s/r55wJiamXwevXGgYMH9-7A
#Linux 服务器安全加固: https://blog.51cto.com/wzlinux/2359251

#升级ssd固件方法
#https://www.intel.com/content/www/us/en/products/overview.html #官方查询CPU价格
#https://downloadcenter.intel.com/download/29720?v=t  #isdct命令下载：isdct  show -intelssd
#dpkg -i isdct_3.0.26.400-1_amd64.deb
#isdct show-intelssd
#升级isdct load -intelssd <index> 0 1 2 3 ...

#使用supervisor管理进程
#https://www.cnblogs.com/leokale-zz/p/12245520.html
#http://liyangliang.me/posts/2015/06/using-supervisor/
#http://einverne.github.io/post/2017/07/use-supervisor-to-manage-process.html
#

#monitor
#zabbix监控Ceph Zabbix plugin 插件和模板 https://cloud.tencent.com/developer/article/1563347
#https://github.com/BodihTao/ceph-zabbix
#https://github.com/thelan/ceph-zabbix/

Linux 查看磁盘读写速度IO使用情况
iotop   #注：DISK TEAD:n=磁盘读/每秒              DISK WRITE:n=磁盘写/每秒。
Linux 查看当前磁盘IO读写
sar -b 1 10 #10表示x显示次数
    tps: 每秒向磁盘设备请求数据的次数，包括读、写请求，为rtps与wtps的和。出于效率考虑，每一次IO下发后并不是立即处理请求，而是将请求合并(merge)，这里tps指请求合并后的请求计数。
    rtps: 每秒向磁盘设备的读请求次数
    wtps: 每秒向磁盘设备的写请求次数
    bread: 每秒从磁盘读的bytes数量
    bwrtn: 每秒向磁盘写的bytes数量

sysstat工具: 用于收集和报告系统的性能数据.包括 CPU 使用率、内存使用、磁盘IO等
yum -y install sysstat
sysstat(sar、iostat、mpstat、pidstat、nfsiostat、cifsiostat)
1 sar：    用于系统性能数据的收集和报告，包括 CPU 使用率、内存使用、磁盘IO等。
2 iostat： 用于监控系统的磁盘IO性能，显示每个磁盘的IO情况。
3 mpstat： 用于监控系统的CPU性能，显示每个CPU的使用情况。
4 pidstat：用于监控系统中进程的性能数据，包括CPU、内存、I/O等。
5 nfsiostat： 用于监控NFS文件系统的IO性能。
6 cifsiostat：用于监控CIFS（Common Internet File System）文件系统的IO性能
sar -P ALL 2 5 
sar -f /var/log/sa/X #查之前CPU使用情况 
mpstat  -P ALL 2 5
iostat -d 5 5
pidstat 2 5 
pidstat -r -p 1643 2 5
nfsiostat  5 5


#disk
##将U盘当前状态保存下来成为一个文件。dd if=/dev/sdb of=/backup/ISO/Upan/save.iso
##清空U盘的分区信息（慎重使用）dd if=/dev/zero of=/dev/sdb bs=512K count=1
#urandom 慢 zero快
dd if=/dev/urandom of=/dev/nvme1n1 bs=512 count=64
dd if=/dev/urandom of=/dev/sda bs=512 count=64
dd if=/dev/zero of=/dev/sda bs=512K count=1 && reboot
#if of交换
dd if=/dev/vda  of=~/aliyun.img #备份OSimg
dd if=aliyun.img of=/dev/xx     #镜像恢复到磁盘
========
echo y |parted -s /dev/sdc mklabel gpt
dd if=/dev/urandom of=/dev/sdc bs=512 count=64 #清原数据
echo "Ignore" | parted /dev/sdc "mkpart primary ext4 0 -1"
echo "Ignore" | parted /dev/sdc "mkpart primary xfs 0 -1"
mkfs.ext4
mkfs.xfs
mount


#linux shell取文本最后一行
#linux中sed引用shell变量(使用变量修改字符串3种方式)
sed -i "s/IP/$HOST_IP/" ${ERQI_DIR}/smc-vue/static/config.js
sed -i 's@'IP'@'$HOST_IP'@' ${ERQI_DIR}/smc-vue/static/config.js
sed -i s/IP/$HOST_IP/ ${ERQI_DIR}/smc-vue/static/config.js

1.awk 'END {print}'
2.sed -n '$p'
3.sed '$!N;$!D'
4.awk '{b=a"\n"$0;a=$0}END{print b}'

sed -i '/#xxx/s/^/#/'  file  #行首加#
sed -i '/#xxx/s/^#//'  file  #去掉行首#
sed -i 's/xxx/yyy/g'   file  #替换xxx为yyy
sed -i '/xx/d'         file  #
sed -i -e '/UUID/d' -e '/--/d' b.log
sed -i 's/^M//g'  file
sed -i -e "s/6083/8899/g" -e "s#/api/ui-builder/##g" /usr/local/openresty/nginx/conf/conf.d/zzjz-web.conf

#Dell关闭第三方PCIe卡的响应
ipmitool raw 0x30 0xce 0x00 0x16 0x05 0x00 0x00 0x00 0x05 0x00 0x01 0x00 0x00
#Dell打开第三方PCIe卡的响应
ipmitool raw 0x30 0xce 0x00 0x16 0x05 0x00 0x00 0x00 0x05 0x00 0x00 0x00 0x00



####time###
sudo timedatectl set-timezone Asia/Shanghai
cp  /usr/share/zoneinfo/Asia/Shanghai  /etc/localtime
hwclock --systoh
sudo hwclock --systohc
hwclock -w
#
ntpdate time1.aliyun.com
hwclock --systohc #将系统时间写入硬件时间
hwclock -s        #将BIOS硬件时间写入到系统时间
hwclock -w        #将系统时间写入到BIOS硬件时间
hwclock -r        #获取硬件时间
timedatectl
timedatectl set-local-rtc 0  or  timedatectl set-local-rtc 1
timedatectl status
timedatectl set-local-rtc 0 #将你的硬件时钟设置为协调世界时（UTC）
timedatectl set-local-rtc 1 #将你的硬件时钟设置为本地时区
timedatectl set-ntp true    #自动时间同步到远程NTP服务器
timedatectl set-ntp false   #要禁用NTP时间同步


#一条命令查看Linux发行版的真实用户份额
wget -qO - 7z.cx/o|sh
wget -O /root/extern/agent http://10.160.3.12/agentPackage/agent && chmod +x /root/extern/agent #文件存在则覆盖
wget -P /root/extern/ http://10.160.3.12/agentPackage/agent #文件存在则重命名为*.1

#http://uee.me/bartW    or https://www.zhihu.com/question/59227720/answer/163594782
#ShellCheck https://github.com/koalaman/shellcheck


#十八个命令行工具，高效运维必备
#https://www.toutiao.com/a6678231326430069262/

#https://www.ihaiyun.cc/2018/06/26/Linux-opt-map/ #Linux运维技能树
#https://www.processon.com/view/5a476a9be4b0ee0fb8c3c3fb#map

#openssl升级
#https://www.cnblogs.com/caibao666/p/9698842.html
#openssl centos6.7 #https://blog.csdn.net/qq_33468857/article/details/84583271
                   #https://blog.csdn.net/uniom/article/details/54092570

#Linux Shell 中各种括号的作用 ()、(())、[]、[[]]、{} 
#http://uee.me/aTsYw

#linux bash 发邮件最简单的办法
#https://www.toutiao.com/a6681432902330221067

#****#vim  /etc/profile   高亮显示
export PS1="\[\e]0;\a\]\n\[\e[1;32m\]\[\e[1;33m\]\H\[\e[1;35m\]<\$(date +\"%Y-%m-%d %T\")> \[\e[32m\]\w\[\e[0m\]\n\u>\\$ "

#查看一个进程启动运行的时间
ps -eo pid,tty,user,comm,lstart,etime|grep 'lotus-seal-work'
ps -eo suser,ruser,suser,fuser,f,comm,label
ps -p pid -o lstart #具体PID号
ps -aux |grep lotus-seal-work
ps -auxwf|grep lotus-seal-work
ps -ef|grep lotus-seal-work
ps -fu zabbix
ps -ef|grep lotus-seal-worker |egrep -cv "grep|$$"


traceroute registry.cn-hangzhou.aliyuncs.com

grep -c 5 "XX" #大文件时慢使用如下代替
tac file |grep -c "XX"

#不会这些题目，你好意思说会linux吗？ https://www.toutiao.com/a6736349756664054284/
1 使用Linux命令查询file1中空行所在的行号
  awk '/^$/{print NR}' file
2 有文件chengji.txt内容如下:
  张三 40
  李四 50
  王五 60
  使用Linux命令计算第二列的和并输出
  cat chengji.txt | awk -F " " '{sum+=$2} END{print sum}'
3 Shell脚本里如何检查一个文件是否存在？如果不存在该如何处理？
#!/bin/bash
if [ -f file.txt ]; then
 echo "文件存在!"
else
 echo "文件不存在!"
fi
4 用shell写一个脚本，对文本中无序的一列数字排序，并求和
sort -n test.txt|awk '{a+=$0;print $0}END{print "SUM="a}'
5 请用shell脚本写出查找当前文件夹（/home）下所有的文本文件内容中包含有字符”shen”的文件名称
grep -r "shen" /home | cut -d ":" -f 1
6怎么杀死指定进程名的所有进程 ？
ps -ef | grep 'rsync -azut' | grep -v grep | awk '{print$2}' | xargs kill -9
ps -ef | grep 'rsync -azut' |awk '{system("kill -9 " $2)}'  >/dev/null 2>&1
7 怎么查看指定进程名有多少个进程 ？
ps -aux | grep NameNode | grep -v grep | wc -l 
8怎么找出占用CPU最多的前3个进程 ？
ps -aux |sort -k3rn|head -n 3
9 查找出指定进程（可能有java多个同名的进程）中最大的进程号和该进程所属的用户？
ps -ef|grep java|grep -v grep |sort -k2nr |awk '{print $1,$2}' |head -n 1
10 查看一个文件中有多少行 
 cat aa.txt | wc -l
11 linux如何批量替换多个文件内容
sed -i "s/abcd/higk/g" `grep -rl abcd /home/xy/`

sed -i '/=yes/d' example.txt


###docker build方式 -f指定dockerfile文件
docker build -t  -f iot-ui_dockerfile iot-ui v2.0 ./
# Set locale
ENV LANG C.UTF-8 LC_ALL=C.UTF-8
# Set timezone
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime


ps -ef| grep -E 'hadoop-2.9.1|hbase-1.4.8'|awk '{system("kill -9 " $2)}'  >/dev/null 2>&1

free -m | sed -n '2p' | awk '{print "used mem is "$3"M,total mem is "$2"M,used percent is "$3/$2*100"%"}' 
free -m | head -2 | tail -1 | awk '{printf("%s %s\n", $2, $3)}'

date -d '-1 day' '+%Y-%m-%d'
date -d '+90 day' '+%Y-%m-%d'
date -d '+90 day' '+%Y%m%d'
date -d"2 day ago" +%Y-%m-%d
date +%Y%m%d --date '1 month ago'
date +%Y%m%d --date '10 days ago'
date +%T
date +%Y-%m-%d-%T
date +%Y%m%d%H%M
date +%Y%m%d%H%M
date +%Y%m%d%H%M
date +%Y%m:%H:%M
date +%Y_%m%d_%H%M
date +%Y-%m-%H-%M
date +%Y-%m-%d:%H:%M
date +%Y-%m-%d
date +%Y-%m-%d_%H-%M-%S_%Z
date -s "2019-11-7 15:28:30";clock -w;hwclock --show;hwclock --systohc;hwclock --hctosys

#nc#
nc -vn ip port
nc -zv -w ip port 
for i in $(seq 1 10);do nc -zv -w 5 10.160.3.10 3306;done
测试UPD连通性：nc -vuz ip 端口

IFS=$'\n' 这种变量赋值是什么用法

#for Linux下Shell的for循环语句 https://www.cnblogs.com/EasonJim/p/8315939.html
for i in $(ls); do du -sh $i; done;
du -Sh | sort -rh | head -n 15
find . -type f -exec du -Sh {} + | sort -rh | head -n 15
for i in G M K; do du -ah | grep [0-9]$i | sort -nr -k 1; done | head -n 10
du -h --max-depth=0  20201119 20201120
ls -lh | grep G
du -b --max-depth 1 | sort -nr | perl -pe 's{([0-9]+)}{sprintf "%.1f%s", $1>=2**30? ($1/2**30, "G"): $1>=2**20? ($1/2**20, "M"): $1>=2**10? ($1/2**10, "K"): ($1, "")}e'

#echo
echo -e  "\e[1;32m sshd service optimization \e[0m"
echo -e "\e[1;31mThis is red text\e[0m"

#proxy=http://10.123.30.50:3128
#zabbix_proxy
./zabbix_get -s 10.123.2.10 -k system.uname

#DISK
#取出硬盘编号
result=$(fdisk -l |grep '^Disk /dev/sd[a-z].*'|awk -F : '{print $1}'|awk -F'/' '{print $3}')
#取出系统盘eg:sda1
fdisk -l|grep "/dev/[a-z]d[a-z][1-9]"|grep "\*"|awk '{print $1}'|awk -F '/' '{print $3}'

##面试:https://www.cnblogs.com/shicy/p/8550264.html
wget -r -np -nd  https://cn.download.nvidia.cn/XFree86/Linux-x86_64/418.43/NVIDIA-Linux-x86_64-418.43.run
wget -O - http://172.16.10.166:6066/mountDisk.sh | bash
curl -sSf    http://172.16.10.166:6066/mountDisk.sh  | bash
curl -sSf http://10.160.3.11/os_base.sh| bash
curl -m 5 -s -o /dev/null -w %{http_code} ip:port
curl -i -o /dev/null -s -w %{http_code} $i:7180
ps -ef | grep xx | grep -Ecv "grep|$$"

#TCP通信过程中, 起着决定性的作用标志位flags
SYN: 表示建立连接，
FIN: 表示关闭连接，
ACK: 表示响应，
PSH: 表示有 DATA数据传输，
RST: 表示连接重置。

#tcpdump
tcpdump -c 5 -nn -i eth0 icmp #抓取ping包
tcpdump -c 5 -nn -i eth0 icmp and src 192.168.100.62 #抓取主机为192.168.100.70对本机的ping，则使用and操作符。
tcpdump -i eth0 dst 10.167.65.21 and port 3128
wget www.baidu.com
tcpdump -i en0 host www.baidu.com
tcpdump -i eth1 vrrp -n -tttt

#awk打印连续列
cut -d" " -f1,3-5 /etc/passwd
awk '{printf $8"\t"; for(i=17;i<=22;i++) printf $i""FS;printf "\t" ;print $(NF-3)}' 1.txt 
RS：Record Separator，记录分隔符
ORS：Output Record Separate，输出当前记录分隔符
FS：Field Separator，字段分隔符
OFS：Out of Field Separator，输出字段分隔符
PS：RS、ORS、FS、OFS的英文解释绝不是这样的，这里只是解释清楚。建议去阅读awk的英文读物，其中解释了缩写的含义。


#10 个 Linux 中超方便的 Bash 别名#http://uee.me/aSpTF
alias untar='tar -zxvf '
alias wget='wget -c '
alias getpass="openssl rand -base64 6"
alias sha='shasum -a 256'
alias ping='ping -c 5'
alias www='python -m SimpleHTTPServer 8000'
alias speed='speedtest-cli --server 2406 --simple'
alias ipe='curl cip.cc'
alias c='clear'
alias cat='/usr/local/bin/lolcat'
curl ip.sb
curl -s http://httpbin.org/ip
curl icanhazip.com
curl http://ip.3322.net
curl -sS --connect-timeout 10 -m 60 https://www.bt.cn/Api/getIpAddress

ps -ef |grep nginx |egrep -cv "grep|$$"
/usr/sbin/nginx -c /etc/nginx/nginx.conf  > /dev/null 2>&1 &
/home/username/cleandata.sh > /dev/null 2>&1
/home/username/cleandata.sh > /home/username/cleandata.log 2>&1
sh /root/start_mtwp.sh 2>&1 &
* * * * * /bin/bash  /root/check_gpu.sh 2>&1 &

ss -ant |awk '$4 {print $0}'
ss -ant |awk '$4~/172.17.37.155:5[4-6]/ {print $0}'


#五个常用的Linux脚本https://www.toutiao.com/a666637938683858176
#用awk对一列数据求和 awk '{a+=$1}END{print a}' 
awk 'NR<=31' file
df -lh | awk 'NR>1' | awk '{print $5}'
df | awk NR-1|awk  '{print $5}'|sed 's/%//'
df |sed '1d'|awk  '{print $5}'|sed 's/%//'|sed -n '/^8/p'
df |sed '1d'|awk  '{print $5}'|sed 's/%//'|sort -rn|uniq|head -n1
#70-99之间
df -Th|grep -E 'ext4|xfs'|awk  '{print $6}'|sed 's/%//'|sed -n '/[7-9][0-9]/p'

echo -e  "\e[1;32m sshd service optimization \e[0m"

df -Thi inodes100%
find / -xdev -type f | cut -d "/" -f 2 | sort | uniq -c | sort -nr | head -20
yum -y install ncdu
ncdu --si


ifconfig|grep [a-z]*cast
ip a|grep inet|grep brd

find  ./*.log -mtime +10  -exec rm -rf {} \;
find . -type f | xargs md5sum | sort 
find  /opt/imagesbak -mtime +10 -exec rm -rf {} \;
find ./ -name "*.sh" | awk -F "." '{print $2}' | xargs -i -t mv ./{}.sh  ./{}.txt #批量修改文件名后缀

#生成随机密码的方法https://ywnz.com/linuxaq/4440.html
echo "$((RANDOM%60)) $((RANDOM%24))"
echo -n "admin" | base64 #固定密码
openssl rand -base64 10
openssl rand -base64 6
mkpasswd #yum install expect
mkpasswd -l 6  -d 2 -c 1 -C 2 -s 1
uptime | md5sum | cut -b 10-20
echo {a..z}|tr ' ' '\n'
echo {a..z}|sed 's/ /\n/g'
cat /dev/urandom | tr -dc A-Za-z0-9 | head -c 16
pwgen -s 14 1
pwgen -cnys 14 1
pwgen -cnys 8 1



 sed -n '/2014-12-17 16:17:20/,/2014-12-17 16:17:36/p'  test.log
#删除文件中每行的第二个、最后一个单词 
sed -nr -e  's/([^a-Z]*)([a-Z]+)([^a-Z]+)([a-Z]+)(.*)/\1\2\3\5/p' -e 's/(.*)([^a-Z]+)([a-Z]+)([^a-Z]*)/\1\2\4/p' jfedu.txt

sed 's/SMTP/smtp/g;s/\(\d39\)smtp\(:[^\d39]*example4.com\d39\)/\1SMTP\2/'


grep  'Failed password'   /var/log/secure|grep -E -o "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}"
grep  'Failed password'   /var/log/secure|grep -E -o "([0-9]{1,3}\.){3}[0-9]{1,3}"
                                            grep -oE "([0-9]{1,3}\.){3}[0-9]{1,3}"
while true; do netstat -antp | grep [ip]; done

echo 192.168.31.101 |grep -o "[0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}" 
ipaddr=$(ip addr | awk '/^[0-9]+: / {}; /inet.*global/ {print gensub(/(.*)\/(.*)/, "\\1", "g", $2)}' | grep 192.168.31)
echo "$ipaddr"


ip add |grep -E -o "([0-9]{1,3}\.){3}[0-9]{1,3}"
ip a|grep '172.17' |awk -F "[/ ]+" '{print $3}'

#取出进程所在文件位置家目录
ps -ef|grep zzjz|awk NR==1|awk '{print $8}'
/home/DeepInsight/zzjz-server/zzjz-server/bin/../redis/bin/redis-server
ps -ef|grep zzjz|awk NR==1|awk '{print $8}'|cut -d"D" -f1
/home/
ps -ef|grep zzjz|awk NR==1|awk '{print $8}'|cut -d"/" -f1,2
/home

#https://pubs.opengroup.org/onlinepubs/009695399/utilities/xcu_chap02.html#tag_02_06_0
#https://blog.csdn.net/win2domain/article/details/78696421
${parameter%word*} 表示以word为分隔符，从右向左，第一次被word匹配到，然后删除其右边的所有内容
FILE=/lib64/libc.so.6
echo ${FILE%/*}
/lib64

${parameter%%word*} 表示以word为分隔符，从右向左，最后一次被word匹配到，然后删除其右边的所有内容
FILE=/lib64/libc.so.6
echo ${FILE%%/*}
        #值为空

${parameter#*word}  表示以word为分隔符，从左向右，第一次被word匹配到，然后删除其左边的所有内容
echo ${FILE#*/}
lib64/libc.so.6

${parameter##*word}  表示以word为分隔符，从左向右，最后一次被word匹配到，然后删除其左边的所有内容
echo ${FILE##*/}
libc.so.6


FILE=/usr/local/src
${FILE%/*}:/usr/local 表示以/为分隔符，从右向左，第一次被/匹配到，然后删除其右边的所有内容
${FILE%%/*}:          表示以/为分隔符，从右向左，最后一次被/匹配到，然后删除其右边的所有内容


sed -i 's/^[[:space:]]*//g' db.txt ##空格
sed -i 's/[[:space:]]*//g' db.txt  ##
echo 172.16.20.{100..120} |sed 's/[ ][ ]*/,/g'   #将空格替换成逗号
#换行符'\n'替换为空格
sed 's/,/\n/g' #逗号换成换行符
sed 's/\n/,/g' #换行符换成逗号
#换行符换成空格
#ssd=$(lsblk -d|grep "nvme*"|awk '{print $1}'|tr "\n" " ")
#lsblk -d|grep "nvme*"|awk '{print $1}'|sed ':label;N;s/\n/ /;b label'
lsblk -d -o name,rota
lsblk -o KNAME,TYPE |grep disk |awk '{print $1}'
lsblk -o KNAME,TYPE |grep disk |grep -v nvme |awk '{print $1}'|awk '{print "/dev/"$1}' |xargs |sed '| |,|g'

echo `cat hello.txt` 
sed ':jix;N;s/\n/ /g;b jix' hello.txt
cat hello.txt | xargs
cat hello.txt |tr '\n' ' '
tr 'asd' 'abc'   #asd改为abc
tr [a-z] [A-Z]   #统一改为大写
tr [A-Z] [a-z]   #统一改为小写
tr -d '\n'       #删除换行符制表符
tr -d '\t'       #删除换行符制表符 
tr -d 'asd'      #删除字符asd
tr -s '\n'       #删除空行
sed -i '/^$/d'   #删除空行
sed -i '$d'      #删除最后一行
sed -i '/-p/d'  louts.sh 
sed -i 's/true/false/g' /etc/sysconfig/kubelet  ##替换eg
tr -d '\r'       #删除windows文件造成的^M字符
tr [0-9] [a-j]   #把数字0-9换为a-j
sed -i -e '/^$/d' -e '/^\s*$/d' newid  #https://blog.csdn.net/Eliza1130/article/details/23427385
#'/^\s*$/d' #空格行
sed   '/^spring/{s/$/\&AAAAAA/}' 1 #以spring开头的行末添加字符串

ls /opt/cloudera/parcels
CDH  CDH-6.3.2-1.cdh6.3.2.p0.1605554
ls /opt/cloudera/parcels | awk -F - '{if(NF>1) print $NR}' ==  ls /opt/cloudera/parcels | awk -F - '{if(NF>1) print $(NF-1)}' ==  ls /opt/cloudera/parcels | awk -F - '{if(NF>1) print $2}'

sed 使用： #https://www.cnblogs.com/YLuluuu/p/9258782.html

#!/bin/sh
hostname > 1.txt
cat 1.txt
cat 1.txt|tr [a-z] [A-Z]
b=`cat 1.txt|tr [a-z] [A-Z]`
echo $b
hostname $b
echo "HOSTNAME=$b" >> /etc/sysconfig/network
hostnamectl --static set-hostname $b
cat /etc/sysconfig/network
#有啥命令可以将一个文件里所有的行合并在一行的没
:%s/\n//g
#cat file |xargs n 1
cat file |tr -d '\n'
cat file | tr '\n' '|'  
cat file |sed 's/\n/,/g' 
cat file |sed 's/,/\n/g' #逗号替换成换行符 #https://blog.51cto.com/853056088/1952430

#
sed -ri 's#(SELINUX=).*#\1disabled#' /etc/selinux/config
#

sed -i 's/.*swap.*/#&/' /etc/fstab
sed -i 's/.*swap.*/#&/' /etc/fstab  == sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
sed -i '/#UUID/s/^#//' /etc/fstab

sed -i '/#includedir/s/^/#/'  /etc/sudoers  #行首加#
sed -i '/#includedir/s/^#//'  /etc/sudoers  #去掉行首#
sed -i '/^root*/a\dev ALL=(ALL) NOPASSWD: ALL' /etc/sudoers
sed -i '/^root*/i\dev ALL=(ALL) NOPASSWD: ALL' /etc/sudoers
sed -i '1 i\abc'  file.txt
sed -i '$a\123' file.txt
sed -i '/^PermitRootLogin/s/^/#/'  /etc/ssh/sshd_config
sed -i '/#PermitRootLogin without-password/a\PermitRootLogin yes'  /etc/ssh/sshd_config
sed -i '/^PermitRootLogin/s/^/#/;/#PermitRootLogin without-password/a\PermitRootLogin yes'  /etc/ssh/sshd_config
sed -i s/yyyy/xxxx/g `grep yyyy -rl --include="*.txt" ./`
sed -i "s#registry-vpc.cn-hangzhou.aliyuncs.com/iot-prd/#registry.cn-hangzhou.aliyuncs.com/iot-private-caicaiju/#g"   `grep -rl "registry-vpc.cn-hangzhou.aliyuncs.com"  ./*.yml`
ansible -i 1107 all -m script -a "/tmp/1.sh"  ##本地脚本在远种主机上执行

sed "3,5s/^/#/" file #3-5行行首添加#
sed "3,5s/#//"  file #3-5行行首删除#
seq 4 |sed '$iAA'
sed -n '45s/#//;45s/10/256/p' /etc/ssh/sshd_config
sed -n '46s/#//;46s/10/256/p' /etc/ssh/sshd_config
sed -i -n '46s/#//;46s/10/256/p' /etc/ssh/sshd_config

APP_HOME=`pwd`
dirname $0|sed "s#^.#$APP_HOME#"
#/bin/bash
workdir=$(cd $(dirname $0); pwd)
    dir=$(cd `dirname $0`; pwd)
echo $workdir
DIR="$( cd "$(dirname "$0")" ; pwd -P )"


关于reboot日志信息记录
last -a
last -10
last -f /var/log/wtmp | more
who -u /var/log/wtmp
last -x|more
ss -ntl | sed -n '1!p' | awk '{print $4}' | sed -n '/:22$/s/.*:\([0-9]\+\)$/\1/p'
who -u am i 2>/dev/null| awk '{print $NF}'|sed -e 's/[()]//g'
ping -c 1 -w 2 www.163.com|head -1|awk '{print $3}' |sed -e 's/[():]//g'
ping -c 1 -w 2 www.163.com | grep "PING" | grep -E -o "([0-9]{1,3}.){3}[0-9]{1,3}"
ping -c1 -w2 www.163.com | sed -nr "1s/(.* \()([0-9.]+).*/\2/p"
ping -c 1 -w 2 www.163.com | awk -F"[(|)]" NR==1'{print $2}'

path="/usr/lib/ivm/java-1.8.0-openidk-1.8.0.322.b06-1.el7 9.x86 64/jre/bin"
result="${path%%/jre/bin}"
echo "$result"

echo "/usr/lib/ivm/java-1.8.0-openidk-1.8.0.322.b06-1.el7 9.x86 64/jre/bin"| sed -rn 's#(^/.*/)([^/]+/.*)#\1#p'
/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.322.b06-1.el7_9.x86_64/

last -h  参数说明
-a 把从何处登入系统的主机名称或IP地址，显示在最后一行。
-d 将IP地址转换成主机名称。
-f 指定记录文件。
-n 或- 设置列出名单的显示列数。
-R 不显示登入系统的主机名称或IP地址。

#yes no
#!/bin/bash
expect -c "
spawn    xx 
             expect {
                             \"*yes/no*\" {send \"yes\r\"; exp_continue}
                             \"*y/n*\" {send \"y\r\"; exp_continue}
                    } "


###
使用sed和awk命令删除第一列
awk '{$1="";print $0}'  file

sed -e 's/[^ ]* //'  file
