# Mysql数据库备份
数据库备份是保证数据库安全和可靠性的重要手段之一,它可以防止数据丢失、避免业务中断、保护数据的完整性和一致性、支持灾难恢复、支持数据迁移和测试等。因此,对于任何组织或企业来说,都应该制定合理的数据库备份策略,并定期进行备份,以确保数据的安全和可靠性。  

下面列举数据库备份的重要性： 
1. 防止数据丢失：数据库中存储了组织或企业的重要数据,如客户信息、财务数据等,如果没有备份,一旦发生硬件故障、人为错误、病毒攻击等意外情况,数据就有可能永久丢失。数据库备份可以在数据丢失时提供恢复的手段,避免数据永久丢失。  

2. 避免业务中断：当数据库发生故障时,业务往往会受到影响,甚至中断。例如,无法处理订单、无法查询客户信息等。数据库备份可以在故障发生时快速恢复数据库,避免业务中断,减少损失。  

3. 保护数据的完整性和一致性：数据库备份可以保证在故障恢复时数据的完整性和一致性。例如,在备份时可以使用事务来保证数据的一致性,备份后可以对备份结果进行校验来保证备份的完整性。  

4. 支持灾难恢复：数据库备份可以支持灾难恢复。例如,在发生自然灾害、恶意攻击等情况时,可以利用备份数据在新的环境中重新构建数据库,从而实现灾难恢复。  

5. 支持数据迁移和测试：数据库备份可以支持数据迁移和测试。例如,在将数据库迁移到新的服务器或云平台时,可以通过备份和恢复来实现数据的迁移。在进行测试时,可以使用备份数据来模拟真实环境,从而避免对生产数据造成影响  


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
```
#!/bin/bash
#刷新环境变量
. ~/.bash_profile
# 数据库认证
user=root
password=asb#1234
host=10.2.6.198
echo "host====>$host"
db_names="zzdevops,csm,metas,taskscheduling"
# 备份路径
backup_path="$HOME/mysqldatabak"
if [ ! -d $backup_path ]; then
        mkdir -p $backup_path
else
        echo "文件夹${backup_path}已经存在"
fi
cd $backup_path
datestr=$(date +%Y%m%d%H%M%S)
mkdir $datestr
base_path=$backup_path/$datestr
# 设置导出文件的缺省权限
umask 177
# Dump数据库到SQL文件
#mysqldump --user=$user --password=$password --host=$host $db_name1 > $base_path/$db_name1.sql
#mysqldump --user=$user --password=$password --host=$host $db_name2 > $base_path/$db_name2.sql
#mysqldump --user=$user --password=$password --host=$host $db_name3 > $base_path/$db_name3.sql
#mysqldump --user=$user --password=$password --host=$host $db_name4 > $base_path/$db_name4.sql

arr_db_name=(${db_names//,/ })
for db_name in ${arr_db_name[@]}; do
        mysqldump -u$user -p$password $db_name >$base_path/$db_name.sql
done

local_upload_filename="mysql-$host-backup-$datestr.tar.gz"
upload_final_filename="mysql-$host-backup.tar.gz"

tar zcf $backup_path/$local_upload_filename $backup_path/$datestr

cp -f $backup_path/$local_upload_filename $backup_path/$upload_final_filename

echo [FTP]
ftp -n <<EOF
        open 10.2.6.193
        user ftpuser ftpuser
        cd ./devops_backup
        binary
        prompt
        lcd $backup_path
        put $upload_final_filename
        close
        bye
EOF

# 删除7天之前的就备份文件
# -mmin +60 60分钟前
# -mtime +30 30天前
find $backup_path/* -mtime +7 -exec rm -rf {} \;
```
## three
```
#!/bin/bash
# 数据表名称,可以为空
table_name=$1
# 数据库名称
database_name=test_data
# 备份周期,单位为天
backup_period=30
# 备份目录
backup_dir=/date/mysql/backup
# 邮箱地址
email_address=xxxxx@mail.qq
# MySQL账号
mysql_user=root
# MySQL密码
mysql_password=root1234

# 获取当前日期
date_str=`date +%Y-%m-%d`
# 备份文件名
if [[ -z "$table_name" ]]; then
 backup_file_name="${database_name}_${date_str}.sql"
else
 backup_file_name="${database_name}_${table_name}_${date_str}.sql"
fi

# 压缩后备份文件名
if [[ -z "$table_name" ]]; then
 compressed_backup_file_name="${database_name}_${date_str}.tar.gz"
else
 compressed_backup_file_name="${database_name}_${table_name}_${date_str}.tar.gz"
fi

# 备份文件路径
backup_file_path="${backup_dir}/${backup_file_name}"

# 压缩后备份文件路径
compressed_backup_file_path="${backup_dir}/${compressed_backup_file_name}"

# 检查备份目录是否存在,如果不存在则创建
if [[ ! -d "$backup_dir" ]]; then
 mkdir -p "$backup_dir"
fi

# 备份MySQL数据表
if [[ -z "$table_name" ]]; then
 mysqldump -u"$mysql_user" -p"$mysql_password" "$database_name" > "$backup_file_path"
else
 mysqldump -u"$mysql_user" -p"$mysql_password" "$database_name" "$table_name" > "$backup_file_path"
fi

# 压缩备份文件
tar -czvf "$compressed_backup_file_path" "$backup_file_path"

# 删除备份文件
rm -f "$backup_file_path"

# 检查备份结果
if [[ -f "$compressed_backup_file_path" ]]; then
 echo "备份成功！"
 echo "备份文件路径：$compressed_backup_file_path"
 subject="MySQL备份成功"
 body="MySQL备份成功,备份文件路径：$compressed_backup_file_path"
else
 echo "备份失败！"
 subject="MySQL备份失败"
 body="MySQL备份失败！"
fi
# 发送备份结果到指定邮箱
echo "$body" | mail -s "$subject" "$email_address"
# 删除过期备份文件
find "$backup_dir" -mtime +"$backup_period" -name "*.tar.gz" -exec rm {} \;

usage: sh $0 
usage: sh $0 test_table_name
```

# foure
```
#!/bin/bash
# MySQL备份脚本
# 备份路径
BACKUP_DIR=/data/backup
# MySQL登录信息
MYSQL_USER=root
MYSQL_PASSWORD=123456
# 获取当前时间戳
TIME=$(date "+%Y%m%d-%H%M%S")
# 获取所有数据库名
DATABASES=$(mysql -u$MYSQL_USER -p$MYSQL_PASSWORD -e "show databases;" | grep -Ev "(Database|information_schema|performance_schema)")

# 备份每个库
for DB_NAME in $DATABASES
do
  # 构造备份文件名
  BACKUP_FILENAME="$DB_NAME-$TIME.sql"
  # 备份数据库
  mysqldump -u$MYSQL_USER -p$MYSQL_PASSWORD --databases $DB_NAME > $BACKUP_DIR/$BACKUP_FILENAME
  # 压缩备份结果集
  gzip $BACKUP_DIR/$BACKUP_FILENAME
  # 添加时间戳到备份文件名
  mv $BACKUP_DIR/$BACKUP_FILENAME.gz $BACKUP_DIR/$BACKUP_FILENAME-$TIME.gz
done

# 自动删除早期备份
find $BACKUP_DIR -name "*.gz" -type f -mtime +7 -exec rm -f {} \;
说明：
    每个库单独备份成一个文件,并压缩
    删除超过7天的备份
0 0 * * * /path/to/backup.sh
```


---
# MySQL数据库巡检脚本
## 概述
在日常数据库维护过程,mysql数据库的巡检是一项重要内容,它是提前发现和解决问题的前提条件。对于保障数据库运行的稳定性至关重要。那如何快速的对mysql数据库进行巡检呢? 
## 脚本
```
#!/bin/bash
# MySQL巡检脚本
# 设置MySQL用户名和密码（请将它们设置为适当的值）
MYSQL_USER="your_username"
MYSQL_PASSWORD="your_password"

# 获取MySQL版本信息
MYSQL_VERSION=$(mysql -u ${MYSQL_USER} -p${MYSQL_PASSWORD} -e "SELECT VERSION();" | awk 'NR==2{print $1}')

# 获取MySQL运行状态信息
STATUS=$(systemctl status mysql.service)

# 获取MySQL进程列表
PROCESS_LIST=$(mysql -u ${MYSQL_USER} -p${MYSQL_PASSWORD} -e "SHOW PROCESSLIST;" | awk '{print $1,$2,$3,$4,$5,$6}')

# 检查MySQL是否在运行
if [[ "$STATUS" =~ "active (running)" ]]; then
  MYSQL_RUNNING="YES"
else
  MYSQL_RUNNING="NO"
fi

# 检查MySQL进程是否存在
if [[ -z "$PROCESS_LIST" ]]; then
  MYSQL_PROCESS="NO"
else
  MYSQL_PROCESS="YES"
fi

# 生成报告
echo "MySQL巡检报告"
echo "----------------"
echo "MySQL版本: $MYSQL_VERSION"
echo "MySQL运行状态: $MYSQL_RUNNING"
echo "MySQL进程存在: $MYSQL_PROCESS"
echo ""
echo "MySQL进程列表"
echo "----------------"
echo "$PROCESS_LIST"
```
## 脚本说明
- 只需要输入数据库的用户名和密码即可  

- 可根据需要自定义输入相关的内容  
  * 缓存池的使用  
    - 缓冲池大小：SHOW GLOBAL VARIABLES LIKE 'innodb_buffer_pool_size';
    - 缓冲池使用率：SHOW GLOBAL STATUS LIKE 'Innodb_buffer_pool_pages_free';
  * 查询缓存  
    - 查询缓存命中率：SHOW GLOBAL STATUS LIKE 'Qcache_hits';
    - 查询缓存碎片率：SHOW GLOBAL STATUS LIKE 'Qcache_free_memory';
  * 读写比例和吞吐量
    - 读写比例：SHOW GLOBAL STATUS LIKE 'Com_select';和SHOW GLOBAL STATUS LIKE 'Com_insert';
    - 吞吐量：SHOW GLOBAL STATUS LIKE 'Innodb_rows_read';和SHOW GLOBAL STATUS LIKE 'Innodb_rows_inserted';
  * 锁的相关信息  
    - 表锁争用：SHOW GLOBAL STATUS LIKE 'Table_locks_waited';
    - 行锁等待时间：SHOW GLOBAL STATUS LIKE 'Innodb_row_lock_time';
    - 行锁等待时间平均值：SHOW GLOBAL STATUS LIKE 'Innodb_row_lock_time_avg';  

