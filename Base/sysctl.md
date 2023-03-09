# sysctl修改Linux内核变量
```
您可以配置Linux(内核)的多个参数或可调参数来控制其行为,无论是在引导时还是在系统运行时按需。
sysctl是一个广泛使用的命令行实用程序,用于在运行时修改或配置内核参数。您可以在/proc/sys/ 目录下找到列出的内核可调参数。
```

它由procfs（proc文件系统）提供支持，procfs是Linux和其他类Unix操作系统中的伪文件系统，为内核数据结构提供接口。它提供有关进程和其他系统信息的信息   

以下是在管理正在运行的Linux系统时候可以使用的10个有用的sysctl命令示例。请注意，您需要root权限才能运行sysctl命令，否则，在调用它时使用sudo命令。  

```
sudo sysctl -a OR  sudo sysctl --all  #列出 Linux 中的所有内核参数
kernel.ostype = Linux                 #变量按以下格式显示  格式<tunable class>.<tunable> = <value>
sudo sysctl -a -N                     #列出所有内核变量名称
sysctl -a | grep memory OR  sysctl --all | grep memory
sysctl -a --deprecated                #列出所有内核变量，包括已弃用的
sysctl -a --deprecated | grep memory
sysctl kernel.ostype                  #列出特定的内核变量值

#临时写入内核变量(增加接收队列的最大大小，该队列存储从网络接收到 NIC（网络接口卡）的环形缓冲区中选取的帧。可以使用变量修改队列大小)
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
