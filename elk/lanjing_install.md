---  
https://bk.tencent.com/s-mart/community/question/11761?type=answer
https://bk.tencent.com/s-mart/community/question/5658?type=answer
https://bk.tencent.com/s-mart/community/question/13235?type=answer


# install_lanjing
tar xf bkce_basic_suite-6.1.2.tgz -C /data

install -d -m 755 /data/src/cert
tar xf ssl_certificates.tar.gz -C /data/src/cert
chmod 644 /data/src/cert/*

cd /data/src/; for f in *gz;do tar xf $f; done

cp -a /data/src/yum /opt

cat << EOF >/data/install/install.config
127.0.0.1 iam,ssm,usermgr,gse,license,redis,consul,es7
127.0.0.1 nginx,consul,mongodb,rabbitmq,appo,zk(config)
127.0.0.1 paas,cmdb,job,mysql,appt,consul,nodeman(nodeman),iam_search_engine

EOF

cat << EOF >/etc/hosts
127.0.0.1 rabbitmq.service.consul
127.0.0.1 bkapi.bktencent.com
127.0.0.1 apigw.bktencent.com
127.0.0.1 cmdb.bktencent.com
127.0.0.1 job.bktencent.com
127.0.0.1 jobapi.bktencent.com
127.0.0.1 nodeman.bktencent.com 
127.0.0.1 nodeman-api.service.consul
127.0.0.1 paas.bktencent.com
127.0.0.1 paas.service.consul

EOF 

cat > /data/install/bin/03-userdef/usermgr.env << EOF
BK_PAAS_ADMIN_PASSWORD=BlueKing
EOF

bash /data/install/configure_ssh_without_pass


./bk_install common
./health_check/check_bk_controller.sh

 cd /data/install/
 sed -i '/start job/i\\t./pcmd.sh\ -m\ job\ \"sed -i '\'/JAVA_OPTS/c\ JAVA_OPTS="-Xms128m -Xmx128m"\'\ /etc/sysconfig/bk-job-*\" bk_install

 cd /data/install
./install_minibk -y




# 遇到问题
## mysql问题
[FAILURE] IP Exited with error code 1     install_mysql.sh [ -h --help -?  查看帮助 ]
初始化mysql@default失败，请参考日志 /data/bkce/logs/mysql/default.mysqld.log 确认报错信息。

rm -fr /data/bkce/logs/mysql
rm -fr /data/bkce/public/mysql
sh -x install_minibk -y

mysql  --login-path=default-root -uroot -pvE1u0cPorf\<5
mysql --login-path=default-root
mysql --login-path=default-root


mysql_config_editor set --login-path=default-root --user=root --socket=/var/run/mysql/default.mysql.socket -pvE1u0cPorf\<5  #手动设置mysql免密登录
mysql_config_editor set --login-path=default-root --user=root --socket=/var/run/mysql/default.mysql.socket -pjMh37Uj1F!
mysql_config_editor print --all
mysql  --login-path=default-root 

mysql --login-path=default-root \
      --connect-expired-password \
      -e "CREATE USER IF NOT EXISTS 'root'@'127.0.0.1' IDENTIFIED BY 'jMh37Uj1F\!'; \
          GRANT ALL PRIVILEGES ON *.* TO 'root'@'127.0.0.1' WITH GRANT OPTION; \
          FLUSH PRIVILEGES;"



          CREATE USER IF NOT EXISTS 'root'@'%' IDENTIFIED BY 'jMh37Uj1F!'; \
          GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION; \
          FLUSH PRIVILEGES;"


mysql_config_editor set --login-path=mysql-iam --user=root --socket=/var/run/mysql/default.mysql.socket -p
jMh37Uj1F!


## bk-iam.service-ERROR
CREATE USER 'iam'@'127.0.0.1' IDENTIFIED BY 'jMh37Uj1F!';
GRANT ALL PRIVILEGES ON bkiam.* TO 'iam'@'127.0.0.1';
FLUSH PRIVILEGES;

##  pip要连外网
WARNING: Retrying (Retry(total=4, connect=None, read=None, redirect=None, status=None)) after connection broken by 'NewConnectionError('<pip._vendor.urllib3.connection.HTTPSConnection object at 0x2ab540d1e1d0>: Failed to establish a new connection: [Errno -2] Name or service not known',)': /pypi/simple/aenum/

mkdir -p ~/.pip
cat > ~/.pip/pip.conf <<EOF
[global]
index-url = https://mirrors.aliyun.com/pypi/simple/
trusted-host = mirrors.aliyun.com
EOF

## 蓝鲸单机版bkce_basic_suite-6.1.2.tgz部署./bkcli initdata paas执行后报错 curl: (52) Empty reply from server是哪个脚本的问题 #添加域名
_bkc initdata paas----> initdata paas---->./bkcli initdata paas---->initdata执行source ./initdata.sh---->---->---->----> 
127.0.0.1 rabbitmq.service.consul
127.0.0.1 bkapi.bktencent.com
127.0.0.1 apigw.bktencent.com
127.0.0.1 cmdb.bktencent.com
127.0.0.1 job.bktencent.com
127.0.0.1 jobapi.bktencent.com
127.0.0.1 nodeman.bktencent.com 
127.0.0.1 nodeman-api.service.consul
127.0.0.1 paas.bktencent.com
127.0.0.1 paas.service.consul


# 安装完后部署监控修改配置
```bash
# 单点部署蓝鲸基础版
[basic]
127.0.0.1 consul,nginx,mongodb,mysql,zk(config),rabbitmq
127.0.0.1 paas,usermgr,iam,ssm,cmdb,job,nodeman(nodeman)
127.0.0.1 license,appo,gse,redis,es7,auth

127.0.0.1 consul,nginx,mongodb,mysql,zk(config),rabbitmq
127.0.0.1 paas,usermgr,iam,ssm,cmdb,job,nodeman(nodeman)
127.0.0.1 license,appo,gse,redis,es7,auth

monitorv3(influxdb-proxy)
monitorv3(monitor)
monitorv3(grafana)
influxdb(bkmonitorv3)
monitorv3(transfer)
beanstalk
log(grafana)
log(api)
kafka(config)
monitorv3(unify-query)
monitorv3(ingester)

value_modules=(monitorv3\(influxdb-proxy\) monitorv3\(monitor\) monitorv3\(grafana\) influxdb\(bkmonitorv3\) monitorv3\(transfer\) beanstalk log\(grafana\) log\(api\) kafka\(config\) monitorv3\(unify-query\) monitorv3\(ingester\))


for module in ${value_modules[@]}; do if grep ${module} /data/install/install.config >/dev/null; then echo -e "The \e[1;31m ${module} \e[0m module exists in install.config, please remove it before deploying."; fi; done
```


