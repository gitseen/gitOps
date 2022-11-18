# MHA环境(master-slave互信)
| MySQL-role    | ip             | MHA-role |
| :-----| ----: | :----:         |
| MySQL-master  | 192.168.32.205 | manager、node |
| MySQL-salve   | 192.168.32.206 | node |
| MySQL-salve   | 192.168.32.207 | node |

# MHA部署
## MHA-manager部署
```bash
notice: "此配置文件的行尾不要加空格等符号"

#install
yum -y install epel-release && yum clean all && yum makecache fast
yum -y install perl-Config-Tiny perl-Log-Dispatch perl-Parallel-ForkManager perl-Time-HiRes
yum -y install perl-ExtUtils-CBuilder perl-ExtUtils-MakeMaker perl-DBD-MySQL perl-devel perl-CPAN
yum -y install mha4mysql-node-0.58-0.el7.centos.noarch.rpm
yum -y install mha4mysql-manager-0.58-0.el7.centos.noarch.rpm

#add conf
mkdir -p  /etc/mastermha/
tee /etc/mastermha/app1.cnf <<-'EOF'
[server default]
user=zzjz              #用于远程连接MySQL所有节点的用户,需要有管理员的权限
password=wJ6tAgSqJidznI98esvA
manager_workdir=/data/mastermha/app1/   #目录会自动生成,无需手动创建
manager_log=/data/mastermha/app1/manager.log
remote_workdir=/data/mastermha/app1/
ssh_user=root               #用于实现远程ssh基于KEY的连接,访问二进制日志
repl_user=zzjz             #主从复制的用户信息
repl_password=wJ6tAgSqJidznI98esvA
ping_interval=1             #健康性检查的时间间隔
#master_ip_failover_script=/usr/local/bin/master_ip_failover   #切换VIP的perl脚本
#report_script=/usr/local/bin/sendmail.sh            #当执行报警脚本
check_repl_delay=0    
 #默认值为1,表示如果slave中从库落后主库relay log超过100M，主库不会选择这个从库为新的master，因为这个从库进行恢复需要很长的时间.通过设置参数check_repl_delay=0，
 #mha触发主从切换时会忽略复制的延时，对于设置candidate_master=1的从库非常有用，这样确保这个从库一定能成为最新的master
master_binlog_dir=/var/lib/mysql      #指定二进制日志存放的目录,mha4mysql-manager-0.58必须指定,之前版本不需要指定
[server1]
hostname=192.168.32.205
candidate_master=1 #设置为优先候选master，即使不是集群中事件最新的slave,也会优先当master
[server2]
hostname=192.168.32.206
candidate_master=1
[server3]
hostname=192.168.32.207
EOF

#add sendmail
tee /etc/mastermha/sendmail.sh <<-'EOF'
 "MYSQL is down" | mail -s "MHA warning" 36******@qq.com
EOF
chmod +x ./sendmail.sh

#master_ip_failover
tee /etc/mastermha/sendmail.sh <<-'EOF'
#!/usr/bin/env perl
use strict;
use warnings FATAL => 'all';
use Getopt::Long;
my (
$command, $ssh_user, $orig_master_host, $orig_master_ip,
$orig_master_port, $new_master_host, $new_master_ip, $new_master_port
);
#执行时必须删除下面三行注释
my $vip = '10.0.0.100/24';#设置Virtual IP
my $gateway = '10.0.0.254';#网关Gateway IP
my $interface = 'eth0'; #指定VIP所在网卡
my $key = "1";
my $ssh_start_vip = "/sbin/ifconfig $interface:$key $vip;/sbin/arping -I
$interface -c 3 -s $vip $gateway >/dev/null 2>&1";
my $ssh_stop_vip = "/sbin/ifconfig $interface:$key down";
GetOptions(
'command=s' => \$command,
'ssh_user=s' => \$ssh_user,
'orig_master_host=s' => \$orig_master_host,
'orig_master_ip=s' => \$orig_master_ip,
'orig_master_port=i' => \$orig_master_port,
'new_master_host=s' => \$new_master_host,
'new_master_ip=s' => \$new_master_ip,
'new_master_port=i' => \$new_master_port,
);
exit &main();
sub main {
print "\n\nIN SCRIPT TEST====$ssh_stop_vip==$ssh_start_vip===\n\n";
if ( $command eq "stop" || $command eq "stopssh" ) {
# $orig_master_host, $orig_master_ip, $orig_master_port are passed.
# If you manage master ip address at global catalog database,
# invalidate orig_master_ip here.
my $exit_code = 1;
eval {
print "Disabling the VIP on old master: $orig_master_host \n";
&stop_vip();
$exit_code = 0;
};
if ($@) {
warn "Got Error: $@\n";
exit $exit_code;
}
exit $exit_code;
}
elsif ( $command eq "start" ) {
# all arguments are passed.
# If you manage master ip address at global catalog database,
# activate new_master_ip here.
# You can also grant write access (create user, set read_only=0, etc) here.
my $exit_code = 10;
eval {
print "Enabling the VIP - $vip on the new master - $new_master_host \n";
&start_vip();
$exit_code = 0;
};
if ($@) {
warn $@;
exit $exit_code;
}
exit $exit_code;
}
elsif ( $command eq "status" ) {
print "Checking the Status of the script.. OK \n";
`ssh $ssh_user\@$orig_master_host \" $ssh_start_vip \"`;
exit 0;
}
else {
&usage();
exit 1;
} }
# A simple system call that enable the VIP on the new master
sub start_vip() {
`ssh $ssh_user\@$new_master_host \" $ssh_start_vip \"`;
}
# A simple system call that disable the VIP on the old_master
sub stop_vip() {
`ssh $ssh_user\@$orig_master_host \" $ssh_stop_vip \"`;
}
sub usage {
print
"Usage: master_ip_failover --command=start|stop|stopssh|status --orig_master_host=host --orig_master_ip=ip --orig_master_port=port --new_master_host=host --new_master_ip=ip --new_master_port=port\n";
}
EOF
chmod +x ./master_ip_failover

```
### manager管理
   * 启动  
     ```bash
        nohup masterha_manager --conf=/etc/mastermha/app1.cnf --remove_dead_master_conf --ignore_last_failover   >/etc/mastermha/mha.log < /dev/null 2>&1 &  
        nohup masterha_manager --conf=/etc/mastermha/app1.cnf --ignore_last_failover < /dev/null > /etc/mastermha/mha.log 2>&1 &  
     ```
   * 健康检测   
     [masterha_check_repl报错问题解决](https://www.cnblogs.com/weifeng1463/p/8682636.html) master-salve添加软连接文件  
     ```bash
        #检查环境
        masterha_check_ssh --conf=/etc/mastermha/app1.cnf
        masterha_check_repl --conf=/etc/mastermha/app1.cnf #[报错问题解决]
            #ln -s /usr/local/mysql/bin/mysqlbinlog /usr/local/bin/mysqlbinlog
            #ln -s /usr/local/mysql/bin/mysql /usr/local/bin/mysql
        #查看状态
        masterha_check_status --conf=/etc/mastermha/app1.cnf
        masterha_check_ssh --conf=/etc/mastermha/app1.cnf  #检查MHA的SSH配置状况
        masterha_check_repl --conf=/etc/mastermha/app1.cnf #检查MySQL复制状况
        masterha_manager --conf=/etc/mastermha/app1.cnf    #启动MHA
        masterha_check_status --conf=/etc/mastermha/app1.cnf #检测当前MHA运行状态
        masterha_master_monitor --conf=/etc/mastermha/app1.cnf #检测master是否宕机
        masterha_master_switch --conf=/etc/mastermha/app1.cnf  #故障转移（自动或手动）
        masterha_conf_host --conf=/etc/mastermha/app1.cnf #添加或删除配置的server信息
        masterha_stop --conf=app1.cnf #停止MHA
        masterha_secondary_check --conf=/etc/mastermha/app1.cnf #两个或多个网络线路检查MySQL主服务器的可用
     ```

## MHA-node部署
```bash
yum -y install epel-release && yum clean all && yum makecache fast
yum -y install perl-Config-Tiny perl-Log-Dispatch perl-Parallel-ForkManager perl-Time-HiRes
yum -y install perl-ExtUtils-CBuilder perl-ExtUtils-MakeMaker perl-DBD-MySQL perl-devel perl-CPAN
yum -y install mha4mysql-node-0.58-0.el7.centos.noarch.rpm
```


MHA 安装包获取    https://code.google.com/p/mysql-master-ha 下载  
See https://www.cnblogs.com/liujiacai/p/14833835.html  for details.
