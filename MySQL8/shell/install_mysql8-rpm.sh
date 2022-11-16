#!/bin/bash
1、使用yum方式部署(添加mysql8源)

           wget mysql80-community-release-el7-3.noarch.rpm && rpm -Uvh mysql80-community-release-el7-3.noarch.rpm
           sed -i 's/enabled=1/enabled=0/' /etc/yum.repos.d/mysql-community.repo
           yum clean all && yum makecache fast
           yum repolist enabled | grep "mysql.*-community.*"
           yum install mysql-community-server #安装最新版本
           或安装指定的版本如：yum --enablerepo=mysql80-community install mysql*8.0.xx*
           systemctl start mysqld
           SA=$(grep 'temporary password' /var/log/mysqld.log) #找到初始密码并登录后修改密码
           #如：mysql -uroot -p$SA
           ALTER USER 'root'@'localhost' IDENTIFIED BY 'a%sB@12,VO7:0' PASSWORD EXPIRE NEVER;
           CREATE USER 'root'@'%' IDENTIFIED BY 'a%sB@12,VO7:0' PASSWORD EXPIRE NEVER;
           GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;
          ALTER USER 'root'@'%' IDENTIFIED WITH mysql_native_password BY 'a%sB@12,VO7:0' PASSWORD EXPIRE NEVER;

2、验证mysql服务是否正常
            nc -vn IP 3306 或 telnet IP 3306
            mysql -hIP -uroot -pxxxxx如图
