# [Linux性能调优方法总结](https://www.toutiao.com/article/7212438118979633725/) 
**磁盘子系统的调优**  
磁盘在LAMP架构中扮演着重要的角色，静态文件、模板和代码都来自磁盘，组成数据库的数据表和索引也来自磁盘，对磁盘的许多调优（尤其是对数据库）集中于避免磁盘访问，因为磁盘访问的延迟相当高，因此，花一些时间对磁盘硬件进行优化是有意义的。  
首先要做的是，确保在文件系统上禁用atime日志记录特性。atime是最近访问文件的时间，每当访问文件时，底层文件系统必须记录这个时间戳，因为系统管理员很少使用atime，禁用它可以减少磁盘访问时间。  
禁用atime特性的方法是，在/etc/fstab的第四列中添加noatime选项。  
有多种磁盘硬件组合，而且linux不一定能够探测出访问磁盘的最佳方式，可以使用hdparm命令查明和设置用来访问IDE磁盘的方法。  
hdparm -t /path/to/device执行速度测试，可以将这个测试结果作为性能基准。为了使得结果尽可能准确，在运行这个命令时系统应该是空闲的。  
```
例如在/dev/hd上执行的速度测试：
hdparm的常用选项：
-vi 向磁盘查询它支持的设置以及它正在使用的设置
-c 查询/启用（E）IDE 32位I/O支持。hdparm -c 1 /dev/hda启用这个设置
-m 查询/设置每中断多扇区模式。如果设置大于0，设置值就是每个中断可以传输的最大扇区数量
-d 1 -X 启用直接内存访问（DMA）传输并设置IDE传输模式。
必须将有帮助的设置添加到启动脚本中，比如rc.local
``` 
 
**文件子系统的调优**

```
ulimit -a用来显示当前的各种用户进程限制。
Linux对于每个用户，系统限制其最大进程数，为提高性能，可以根据设备资源情况，设置各个linux用户的最大进程数，下面我把某linux用户的最大进程数设为10000个：

ulimit -u 10000
对于需要做许多socket连接并使它们处于打开状态的Java应用程序而言，最好通过使用ulimit -n xx修改每个进程可打开的文件数，缺省值是1024.ulimit -n 4096将每个进程可以打开的文件数目加大到4096，缺省为1024。

其他建议设置为无限制（unlimited）的一些重要设置是：

数据段长度: ulimit -d unlimited
最大内存大小: ulimit -m unlimited
堆栈大小: ulimit -s unlimited
CPU时间: ulimit -t unlimited
虚拟内存: ulimit -v unlimited
以上命令只是暂时地，适用于通过ulimit命令登录shell会话期间。

永久地，通过将一个相应的ulimit语句添加到由登录shell读取的文件中，即特定于shell的用户资源文件，如：

解除Linux系统的最大进程数和最大文件打开数限制

vi /etc/security/limits.conf

# 添加如下的行
* soft noproc 11000
* hard noproc 11000
* soft nofile 4100
* hard nofile 4100
说明：

*代表针对所有用户
noproc代表最大进程数
nofile 达标最大文件打开数
让SSH接受Login程式的登入，方便在ssh客户端查看ulimit -a资源限制

vi /etc/ssh/sshd_config
# 把 UserLogin的值改为yes，并把#注释去掉

# 重启sshd服务：
/etc/init.d/sshd restart
修改所有linux用户的环境变量文件

vi /etc/profile
ulimit -u 10000
ulimit -n 4096
ulimit -d unlimited
ulimit -m unlimited
ulimit -s unlimited
ulimit -t unlimited
ulimit -v unlimited
有时候在程序里面需要打开多个文件，进行分析，系统一般默认数量是1024，对于正常使用时够了，但是对于程序来讲，就太少了，需要修改2个文件：

修改/etc/security/limits.conf

vi /etc/security/limits.conf

加上：
* soft nofile 8192
* hard nofile 20480
修改/etc/pam.d/login
session required /lib/security/pam_limits.so
另外，确保/etc/pam.d/system-auth文件有下面内容
session required /lib/security/$ISA/pam_limits.so
这一行确保系统会执行这个限制。
一般用户的 .bash_profile
ulimit -n 1024
重新登录OK
```
