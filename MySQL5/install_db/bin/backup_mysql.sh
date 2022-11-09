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
