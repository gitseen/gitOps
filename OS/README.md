# Linux 性能优化的全景指南
See  https://www.toutiao.com/article/7166413177209487902/  for details.

# OS-systemctl
  See https://www.toutiao.com/article/7160882121542877737/  for details.
# 记录Linux系统状态信息
  See https://www.toutiao.com/article/7168759268479418895/  for details.
  ```bash
 #!/bin/bash
[ -d /opt/logs ] || mkdir -p /opt/logs
while :
do
    load=`uptime |awk -F 'average:' '{print $2}'|cut -d',' -f1|sed 's/ //g' |cut -d. -f1`
    if [ $load -gt 10 ]
    then
        top -bn1 |head -n 100 > /opt/logs/top.`date +%s`
        vmstat 1 10 > /opt/logs/vmstat.`date +%s`
        ss -an > /opt/logs/ss.`date +%s`
    fi
    sleep 20
    find  /opt/logs \( -name "top*" -o -name "vmstat*" -o -name "ss*" \) -mtime +30 |xargs rm  -f
done
  ```
