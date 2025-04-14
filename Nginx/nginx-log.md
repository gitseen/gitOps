# [Nginx日志分割](https://www.toutiao.com/article/7202541476063150648/)  
LinkSLA智能运维管家  

nginx默认没有提供对日志文件的分割功能,所以随着时间的增长,access.log和error.log文件会越来越大,尤其是access.log,其日志记录量比较大,更容易增长文件大小,影响日志写入性能。推荐利用Logrotate来完成

# Logrotate用法
## 1、安装
logrotate是一个linux系统日志的管理工具。可以对单个日志文件或者某个目录下的文件按时间/大小进行切割,压缩操作；指定日志保存数量；还可以在切割之后运行自定义命令  

logrotate是基于crontab运行的,所以这个时间点是由crontab控制的,具体可以查询crontab的配置文件/etc/anacrontab。系统会按照计划的频率运行logrotate,通常是每天。在大多数的Linux发行版本上,计划每天运行的脚本位于/etc/cron.daily/logrotate  

主流Linux发行版上都默认安装有logrotate包,如果你的linux系统中找不到logrotate, 可以使用apt-get或yum命令来安装  
```
rpm -ql logrotate || [yum||apt] install -y logrotate
```
## 2、基本用法详解
### 2.1 入门
logrotate主配置文件/etc/logrotate.conf  
```
eg: 尝试在该目录中创建一个日志分割配置test,对/opt/logtest目录中所有以.log结尾的文件进行分割
#test配置文件的内容
/opt/logtest/*.log {
    daily
    rotate 2
    copytruncate
    missingok
}

#test配置的第一行指定要对哪个路径的哪些文件进行分割,然后携带的4个参数解释如下：
daily：按天切割。触发切割时如果时间不到一天不会执行切割。除了daily,还可以选monthly,weekly,yearly
rotate：对于同一个日志文件切割后最多保留的文件个数
copytruncate：将源日志文件切割成新文件后,清空并保留源日志文件。默认如果不启用该配-置,分割后源日志文件将被删除。设置该值,以便分割后可以继续在源日志文件写入日志,等待下次分割
missingok：切割中遇到日志错误忽略

logrotate -vf /etc/logrotate.d/test
# -v:显示执行日志
# -f:强制执行分割

```
### 2.2 分割文件压缩
对分割后的日志文件开启压缩
```
/opt/logtest/*.log {
    daily
    rotate 2
    copytruncate
    missingok
    compress           # 以gzip方式压缩
    nodelaycompress    # 所有分割后的文件都进行压缩
}
```
### 2.3 按照时间分割
按照时间分割可以定时分割出一个日志,比如每天分割一次,配合其他参数可以完成保留最近n天日志的功能。以下配置可以实现每天分割一次日志,并且保留最近30天的分割日志  
```
/opt/logtest/*.log {
    daily      # 每天分割一次
    rotate 30  # 保留最近30个分割后的日志文件
    copytruncate
    missingok
    dateext  # 切割后的文件添加日期作为后缀
    dateyesterday # 配合dateext使用,添加前一天的日期作为分割后日志的后缀
    #默认添加的日期后缀格式为yyyyMMdd,可以用dateformat自定义
     dateformat -%Y-%m-%d
}

```
### 2.4 按照文件大小分割
利用size配置指定当日志文件达到多大体积时才进行分割;当日志文件大于5M时才真正执行分割操作  
```
/opt/logtest/*.log {
    daily      # 每天分割一次
    size 5M    # 源文件小于5M时不分割
    rotate 30  # 保留最近30个分割后的日志文件
    create
    missingok
    dateext  # 切割后的文件添加日期作为后缀
    dateyesterday # 配合dateext使用,添加前一天的日期作为分割后日志的后缀
}

``` 
### 自定义每小时分割
logrotate实现每日定时执行日志分割的原理是通过cron定时任务,默认在/etc/cron.daily中包含logrotate可执行命令,所以系统每天会定时启动logrotate,然后它会根据配置中具体分割频率(daily、weekly等)以及其他条件(比如size)决定是否要真正执行分割操作  
- logrotate配置文件中指定分割频率为hourly
- 配置完以后,还需要在cron的每小时定时任务中加入logrotate,因为默认情况下只有/etc/cron.daily中包含logrotate可执行命令,我们要将它往/etc/cron.hourly中也拷贝一份,这样系统才会每小时调用一次logrotate去执行分割  
```
cp /etc/cron.daily/logrotate /etc/cron.hourly/
```
### 2.6 自定义分割执行时间
logrotate 是基于cron 运行的,所以这个时间是由 cron 控制的,具体可以查询 cron 的配置文件/etc/crontab 。旧版CentOS 的cron 的配置文件是 /etc/crontab ,新版CentOS 改为 /etc/anacrontab  
```
crontab -e
# 每天 23点59分进行日志切割
59 23 * * * /usr/sbin/logrotate -f /etc/logrotate_mytime/ngin
systemctl restart crond 
```
# nginx日志分割步骤
在/etc/logrotate.d中创建文件nginx,作为nginx日志分割的配置文件。指定每天执行一次分割,并且当文件大于5M时才进行分割。同时指定notifempty,当日志文件为空时不分割  
```
/opt/docker-ws/nginx/logs/*.log {
    daily      # 每天分割一次
    size 5M    # 源文件小于5M时不分割
    rotate 30  # 保留最近30个分割后的日志文件
    copytruncate
    notifempty # 当日志文件为空时不分割
    missingok
    dateext  # 切割后的文件添加日期作为后缀
}
```
**权限不够而分割失败**
```
关闭selinux
利用semanage修改待分割的日志文件所在目录的权限
semanage fcontext -a -t var_log_t "/opt/logtest(/.*)?"
restorecon -Rv /opt/logtest
```
[链接](https://baobao555.tech/archives/57)  

--- 

# 按日期自动生成日志文件
前言
之前文章：Nginx奇技淫巧之：用户行为埋点数据采集实现,介绍了Nginx获取post请求body参数生成日志文件的方法。当业务埋点量信息很大时,所有数据累加到一个日志文件中,会导致单个文件越来越大,后期难于清理和维护。本文将向大家介绍,按日期自动生成日志文件的方法。希望对有需要的小伙伴有所帮助和参考。  

Nginx配置;Nginx配置文件调整  

http块添加以下配置 
``` 
# 新增logdate日期变量
    map $time_iso8601 $logdate {
      #'~^(?<ymd>\d{4}-\d{2}-\d{2})' $ymd;  #2025-mm-dd.log 
      '~^(?<year>\d{4})-(?<month>\d{1,2})-(?<day>\d{1,2})' $year$month$day; #2025mmdd.log
      default    'date-not-found';
    }
server块添加日志文件变量

生成日志文件的地方添加日期信息,详见如下代码块注释

        location /trackLog {
            if ($request_method !~* POST) {
               return 403;
            }
           # 日志文件名添加日期变量
            access_log  /usr/local/nginx/logs/tracklog-$logdate.log  tracklog;
            proxy_pass http://127.0.0.1/return200/;
        }

        location /return200 {
            default_type application/json;
            return 200 '{"code":0,"msg":"success"}';
        }
赋权日志文件目录

按日期动态生成日志文件,需确保对应日志目录具有相应权限。以下为演示代码,生产环境请根据具有情况按需赋权。

chmod -R 777 /usr/local/nginx/logs/*
生效Nginx Config

# Nginx sbin目录执行配置生效命令
./nginx -s reload
测试post请求

# 部署Nginx服务器执行测试post请求,body参数可根据业务场景自行定义
curl -H "Content-type:application/json" -X POST -d '{"name":"test"}' http://localhost/tracklog
日志文件查看

切换到日志目录,查看文件名和内容

对应目录下已生成tracklog-{日期}.log文件
```


总结  
from: https://www.toutiao.com/article/7168739982771847680/  
from: https://www.toutiao.com/article/7168401363909739019/   #post埋点


