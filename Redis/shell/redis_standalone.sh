#!/bin/bash
[Unit]
Description=Redis
After=network.target

[Service]
Type=forking
PIDFile=/data/redis/redis16379/redis16379.pid
ExecStart=/usr/local/bin/redis-server /data/redis/redis16379/redis.conf  --supervised systemd
#ExecStop=/usr/local/bin/redis-cli -p 16379 shutdown
ExecReload=/bin/kill -s HUP
ExecStop=/bin/kill -s QUIT
PrivateTmp=true

[Install]
WantedBy=multi-user.target


====config====
bind 0.0.0.0
protected-mode yes
port 16379
tcp-backlog 511
timeout 0
tcp-keepalive 300
daemonize yes
supervised no
pidfile /data/redis/redis16379/redis16379.pid
loglevel notice
logfile /data/redis/logs/redis16379.log
databases 16
always-show-logo yes
save 900 1
save 300 10
save 60 10000
stop-writes-on-bgsave-error no
rdbcompression yes
rdbchecksum yes
dbfilename dump16379.rdb
dir /data/redis/data
replica-serve-stale-data yes
replica-read-only yes
repl-diskless-sync no
repl-diskless-sync-delay 5
repl-disable-tcp-nodelay no
replica-priority 100
requirepass WEAVERemobile7*()
#cluster-enabled yes
masterauth WEAVERemobile7*()
#cluster-config-file 16379.conf
#cluster-node-timeout 5000
lazyfree-lazy-eviction no
lazyfree-lazy-expire no
lazyfree-lazy-server-del no
replica-lazy-flush no
appendonly yes
appendfilename "appendonly16379.aof"
appendfsync everysec
no-appendfsync-on-rewrite no
auto-aof-rewrite-percentage 100
auto-aof-rewrite-min-size 64mb
aof-load-truncated yes
aof-use-rdb-preamble yes
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
stream-node-max-bytes 4096
stream-node-max-entries 100
activerehashing yes
client-output-buffer-limit normal 0 0 0
client-output-buffer-limit replica 256mb 64mb 60
client-output-buffer-limit pubsub 32mb 8mb 60
hz 10
dynamic-hz yes
aof-rewrite-incremental-fsync yes
rdb-save-incremental-fsync yes
#slave-priority 100
maxmemory 6gb
maxmemory-policy allkeys-lru
maxmemory-samples 5




