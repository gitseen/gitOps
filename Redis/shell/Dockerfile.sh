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

sleep 20
docker ps -a |grep "tt"





