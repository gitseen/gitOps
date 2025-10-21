#!/bin/bash
#Dockerfile for Redis
#touch redis.conf
cat >./redis.conf <<EOF
bind 0.0.0.0
protected-mode no
port 6379
tcp-backlog 511
timeout 0
tcp-keepalive 300
daemonize no
supervised no
pidfile /data/redis_6379.pid
loglevel notice
logfile /data/redis_6379.log
databases 16
always-show-logo yes
save 900 1
save 5 1
save 300 10
save 60 10000
stop-writes-on-bgsave-error no
rdbcompression yes
rdbchecksum yes
dbfilename dump.rdb
dir /data
slave-serve-stale-data yes
slave-read-only yes
repl-diskless-sync no
repl-diskless-sync-delay 5
repl-disable-tcp-nodelay no
slave-priority 100
requirepass 78904321
lazyfree-lazy-eviction no
lazyfree-lazy-expire no
lazyfree-lazy-server-del no
slave-lazy-flush no
appendonly no
appendfilename "appendonly.aof"
appendfsync everysec
no-appendfsync-on-rewrite no
auto-aof-rewrite-percentage 100
auto-aof-rewrite-min-size 64mb
aof-load-truncated yes
aof-use-rdb-preamble no
lua-time-limit 5000
slowlog-log-slower-than 10000
slowlog-max-len 128
latency-monitor-threshold 0
notify-keyspace-events ""
hash-max-ziplist-entries 512
hash-max-ziplist-value 64
list-max-ziplist-size -2
list-compress-depth 0
set-max-intset-entries 512
zset-max-ziplist-entries 128
zset-max-ziplist-value 64
hll-sparse-max-bytes 3000
activerehashing yes
client-output-buffer-limit normal 0 0 0
client-output-buffer-limit slave 256mb 64mb 60
client-output-buffer-limit pubsub 32mb 8mb 60
hz 10
aof-rewrite-incremental-fsync yes

EOF

#touch Dockerfile
cat >./Dockerfile <<EOF
FROM redis:7.2-alpine

ENV REDIS_PASSWORD=78904321

RUN addgroup -g 1001 -S redisuser && \
    adduser  -u 1001 -S redisuser -G redis

COPY redis.conf /usr/local/redis/redis.conf

RUN mkdir -p /data && \
    chown -R redisuser:redisuser /data && \
    chown redisuser:redisuser /usr/local/redis/redis.conf

USER redis

HEALTHCHECK --interval=30s \
            --timeout=3s \
            --start-period=10s \
            --retries=3 \
            CMD redis-cli -a "\$REDIS_PASSWORD" ping || exit 1

CMD ["redis-server", "/usr/local/redis/redis.conf"]

#docker build -t redis ./

#docker run -dit -e REDIS_PASSWORD=78904321 -p 6379:6379 --name=tt redis


#nginx HEALTHCHECK
#HEALTHCHECK --interval=30s CMD wget --quiet --tries=1 --spider http://localhost/ || exit 1

EOF

docker build -t redis ./ &&  docker run -dit -e REDIS_PASSWORD=78904321 -p 6379:6379 --name=tt redis

sleep 10 #100
docker ps -a |grep "tt" |grep "Health"  

#docker inspect redis | grep -A 10 -B 5 'Health'
   
#docker inspect redis | grep -C 5  'Health'  


```bash
1. 查看容器 IP 地址
#查看容器在bridge网络中的 IP
docker inspect -f '{{.NetworkSettings.IPAddress}}'  tt

#查看所有网络的IP（推荐）
docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' tt

#查看指定网络（如 mynet）的 IP
docker inspect -f '{{.NetworkSettings.Networks.mynet.IPAddress}}' tt


2. 查看容器挂载的卷（Volumes）
#查看所有挂载点
docker inspect -f '{{json .Mounts}}' tt | jq .

#仅查看源路径和目标路径
docker inspect -f '{{range .Mounts}}{{.Source}} -> {{.Destination}}{{"\n"}}{{end}}' tt

#查看卷（Volume）的宿主机路径
docker inspect -f '{{.Mountpoint}}' myvol #输出：/var/lib/docker/volumes/myvol/_data

3. 查看容器端口映射
#查看端口映射（宿主机:容器）
docker inspect -f '{{.HostConfig.PortBindings}}' tt

#更清晰的格式（需 jq|yq）
docker inspect tt | jq '.[0].NetworkSettings.Ports' 
docker inspect tt | yq '.[0].NetworkSettings.Ports' 
docker inspect tt | jq 

1. 查看容器状态（运行、退出、健康）
#查看运行状态
docker inspect -f '{{.State.Status}}' tt  #输出running、 exited、paused

#查看退出码（如果已退出）
docker inspect -f '{{.State.ExitCode}}' tt

#查看健康状态
docker inspect -f '{{.State.Health.Status}}' tt #输出healthy、unhealthy、starting


5. 查看容器启动命令和环境变量
#查看启动命令（CMD）
docker inspect -f '{{.Config.Cmd}}' tt

#查看ENTRYPOINT
docker inspect -f '{{.Config.Entrypoint}}' tt

#查看所有环境变量
docker inspect -f '{{.Config.Env}}' tt

#查看特定环境变量（如 PATH）
docker inspect -f '{{range .Config.Env}}{{println .}}{{end}}' tt | grep PATH

6. 查看镜像的详细信息
#查看镜像的CMD
docker inspect -f '{{.Config.Cmd}}' redis

#查看镜像暴露的端口
docker inspect -f '{{.Config.ExposedPorts}}' redis

# 查看镜像大小
docker inspect -f '{{.Size}}' redis| numfmt --to=iec-i --suffix=B

7. 查看网络详情
# 查看bridge网络的子网
docker inspect -f '{{.IPAM.Config}}' bridge

# 查看自定义网络 mynet 的网关
docker inspect -f '{{(index .IPAM.Config 0).Gateway}}' bridge

---
# 查看所有容器的名称和状态
docker inspect -f '{{.Name}} {{.State.Status}}' $(docker ps -aq)  

docker inspect -f ' {{if eq .State.Status "running"}} IP: {{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}} {{else}} stopped {{end}} ' tt
```

**快速参考表**  
| 需求    | CLI |
| --------- | :-------: | 
| 容器IP | docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' container |
| 端口映射 | docker inspect -f '{{.HostConfig.PortBindings}}' container |
| 挂载卷 | docker inspect -f '{{json .Mounts}}' container |
| 健康状态 | docker inspect -f '{{.State.Health.Status}}' container |
| 镜像大小 | docker inspect -f '{{.Size}}' image |
| 卷路径 | docker inspect -f '{{.Mountpoint}}' volume_name |




