# shell脚本系列-检查etcd集群可用性
```
#!/bin/bash

#配置etcd集群地址、端口、账号、密码
ETCD_ENDPOINTS="http://127.0.0.1:2379"
ETCD_USERNAME=""
ETCD_PASSWORD=""

#验证集群可读可写性的key
ETCD_TEST_KEY="/test/test.txt"

#循环次数
LOOP_TIMES=1

#验证etcd集群是否健康
function check_cluster_health() {
 local health=$(ETCDCTL_API=3 etcdctl --endpoints=$ETCD_ENDPOINTS \
 --user=$ETCD_USERNAME:$ETCD_PASSWORD \
 endpoint health 2>&1)
 if [[ $health =~ "unhealthy" ]]; then
 echo "ETCD集群健康状态: 不健康"
 echo "ETCD Cluster Health: Unhealthy"
 echo $health
 exit 1
 else
 echo "ETCD集群健康状态: 健康"
 echo "ETCD Cluster Health: Healthy"
 fi
}

#验证集群可读可写性 
function check_read_write() {
 local value="hello world"
 #put
 ETCDCTL_API=3 etcdctl --endpoints=$ETCD_ENDPOINTS \
 --user=$ETCD_USERNAME:$ETCD_PASSWORD \
 put $ETCD_TEST_KEY "$value" >/dev/
 if [[ $? -eq 0 ]]; then
 echo "写入ETCD集群成功，key: $ETCD_TEST_KEY, value: $value"
 echo "Write to ETCD cluster successfully, key: $ETCD_TEST_KEY, value: $value"
 else
 echo "写入ETCD集群失败，key: $ETCD_TEST_KEY, value: $value"
 echo "Write to ETCD cluster failed, key: $ETCD_TEST_KEY, value: $value"
 exit 1
 fi

 #get
 local ret=$(ETCDCTL_API=3 etcdctl --endpoints=$ETCD_ENDPOINTS \
 --user=$ETCD_USERNAME:$ETCD_PASSWORD \
 get $ETCD_TEST_KEY)
 if [[ "$ret" == *"$value"* ]]; then
 echo "从ETCD集群读取数据成功，key: $ETCD_TEST_KEY, value: $value"
 echo "Read from ETCD cluster successfully, key: $ETCD_TEST_KEY, value: $value"
 else
 echo "从ETCD集群读取数据失败，key: $ETCD_TEST_KEY, value: $value"
 echo "Read from ETCD cluster failed, key: $ETCD_TEST_KEY, value: $value"
 exit 1
 fi

 #delete
 ETCDCTL_API=3 etcdctl --endpoints=$ETCD_ENDPOINTS \
 --user=$ETCD_USERNAME:$ETCD_PASSWORD \
 del $ETCD_TEST_KEY >/dev/

```

./etcd_check.sh


