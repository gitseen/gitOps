# Mysql数据库备份脚本
## one
```
#!/bin/bash
DD=`date +"%w-%H"`
cd /root/backup/
$EE snapshot save etcd-$DD

if [ `date +%H` == 00 ];then
        /usr/bin/mysqldump  -h 128.192.1.1 -uusername-P 3306 -ppassword --database config_server --skip_add_locks --skip-lock-tables > c_${DD}.sql
        /usr/bin/mysqldump  -h 128.192.1.1  -uusername -P 3306 -ppassword. --database report_data --skip_add_locks --skip-lock-tables|gzip > m_${DD}.sql.gz
fi

利用mysqldump 进行数据库信息导出
5 00,05 * * * /root/backup/back.sh
```
## two
