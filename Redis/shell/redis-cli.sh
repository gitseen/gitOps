#!/bin/bash
#计算Redis命中率
#基于hits和misses计算
#命中率 = keyspace_hits / (keyspace_hits + keyspace_misses)


#获取hits和misses
#redis-cli -a 'passwd' -p port info
#redis-cli -a 'passwd' -p port info stats
#redis-cli -a 'passwd' -p port info replication
#redis-cli -a 'passwd' -p port info sentinel
#redis-cli -a 'passwd' -p port info memory
#redis-cli -a 'passwd' -p port info cpu
#redis-cli -a 'passwd' -p port info clients
#redis-cli -a 'passwd' -p port slowlog get 10 
#redis-cli -a 'passwd' -p port --cluster  ...

#使用Shell脚本自动计算Redis命中率
hits=$(redis-cli info stats | grep keyspace_hits | cut -d':' -f2)
misses=$(redis-cli info stats | grep keyspace_misses | cut -d':' -f2)
total=$((hits + misses))

# 避免除零错误
if [ $total -eq 0 ]; then
    echo "命中率: 0%"
else
    rate=$(echo "scale=4; $hits*100/$total" | bc)
    echo "命中率: $rate%"
fi
