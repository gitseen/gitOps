# Loki原生部署(loki+promtail+grafana)
```bash
#git clone https://github.com/grafana/loki.git
wget https://github.com/grafana/loki/releases/download/v2.9.3/loki-linux-amd64.zip
wget https://github.com/grafana/loki/releases/download/v2.9.3/promtail-linux-amd64.zip
wget https://dl.grafana.com/enterprise/release/grafana-enterprise-9.3.6.linux-amd64.tar.gz
```
##  loki部署
useradd --system --home /data/loki --shell /sbin/nologin loki
mkdir -p /usr/local/loki
unzip -d /usr/local/loki loki-linux-amd64.zip
mkdir -p /data/loki/{chunks,index}
chown -R loki:loki /data/loki
chmod 750 /data/loki
usermod -a -G root loki
usermod -aG systemd-journal loki

#添加loki.yaml配置模板
cat >/usr/local/loki/loki.yaml <<'EOF'
auth_enabled: false
server:
  http_listen_port: 13100
  grpc_listen_port: 19096

ingester:
  lifecycler:
    address: 172.16.219.234 
    ring:
      kvstore:
        store: inmemory
      replication_factor: 1
    final_sleep: 0s
  chunk_idle_period: 5m
  chunk_retain_period: 30s

common:
  path_prefix: /data/loki
  storage:
    filesystem:
      chunks_directory: /data/loki/chunks
      rules_directory: /data/loki/rules
  replication_factor: 1
  ring:
    instance_addr: 172.16.219.234
    kvstore:
      store: inmemory

query_range:
  results_cache:
    cache:
      embedded_cache:
        enabled: true
        max_size_mb: 100

schema_config:
  configs:
    - from: 2025-11-26
      store: boltdb-shipper
      object_store: filesystem
      schema: v11
      index:
        prefix: index_
        period: 24h

storage_config:
  boltdb:
    directory: /data/loki/index
  filesystem:
    directory: /data/loki/chunks

compactor:
  working_directory: /data/loki/compactor
  compaction_interval: 10m                 # ?.缉?撮.
  retention_enabled: true                  # ?.??.??
  retention_delete_delay: 2h               # 杩..?.?涔..?
  retention_delete_worker_count: 150       # 杩..?..?.??扮.
  shared_store: filesystem

ruler:
  alertmanager_url: http://localhost:19093

limits_config:
  enforce_metric_name: false
  reject_old_samples: true
  reject_old_samples_max_age: 720h

chunk_store_config:
  max_look_back_period: 720h

table_manager:
  retention_deletes_enabled: true
  retention_period: 720h
EOF

#启动服务
cat > /usr/lib/systemd/system/loki.service <<'EOF'
[Unit]
Description=Loki log aggregation server (monolithic mode)
Documentation=https://grafana.com/docs/loki/latest/
After=network.target

[Service]
Type=simple
User=loki
Group=loki
ExecStart=/usr/local/loki/loki-linux-amd64 -config.file=/usr/local/loki/loki.yaml
ExecReload=/bin/kill -HUP $MAINPID
Restart=always
RestartSec=10
TimeoutStopSec=30
LimitNOFILE=65536

# 可选：限制资源（根据日志量调整）
# MemoryLimit=4G
# CPUQuota=80%

# 日志输出到 journald
StandardOutput=journal
StandardError=journal
SyslogIdentifier=loki

# 安全加固（可选，若不需要可注释）
# NoNewPrivileges=true
# PrivateTmp=true
# ProtectSystem=strict
# ProtectHome=true
# ReadWritePaths=/data/loki

[Install]
WantedBy=multi-user.target
EOF

chmod +x /usr/lib/systemd/system/loki.service
sudo systemctl daemon-reload  && sudo systemctl enable --now loki  && sudo systemctl status loki
#sudo journalctl -u loki -f   #查看实时日志（调试启动问题）
 
#检查 HTTP 端口（默认 3100）
curl http://localhost:13100/ready #应返回"ready"


##  promtail部署(agent)
sudo useradd --system --home /usr/local/promtail --shell /sbin/nologin promtail
mkdir -p /usr/local/promtail
unzip -d /usr/local/promtail promtail-linux-amd64.zip
sudo usermod -aG systemd-journal promtail

cat > /usr/local/promtail/promtail.yaml <<'EOF'
server:
  http_listen_port: 19080
  grpc_listen_port: 0

positions:
  filename: /tmp/positions.yaml

clients:
  - url: http://172.16.219.234:13100/loki/api/v1/push

scrape_configs:
- job_name: lokiserver-172.16.219.234
  static_configs:
  - targets:
      - 172.16.219.234
    labels:
      job: grafana
      hosts: 172.16.219.234
      __path__: /usr/local/grafana/data/log/grafana.log
      stream: stdout

  pipeline_stages:
    - match:
        selector: '{job="grafana"}'
        stages:
        - multiline:
            firstline: '^LOG'  
        - regex:
            expression: '.*(?P<level>INFO|WARN|ERROR).*'
        - timestamp:
            format: RFC3339Nano
            source: timestamp
        - labels:
            timestamp:
            level: 

EOF

sudo chown promtail:promtail /usr/local/promtail/promtail.yaml
sudo chmod 644 /usr/local/promtail/promtail.yaml


cat > /usr/lib/systemd/system/promtail.service <<'EOF'
[Unit]
Description=Promtail log shipper for Loki
Documentation=https://grafana.com/docs/loki/latest/send-data/promtail/
After=network.target
Wants=network.target

[Service]
Type=simple
User=promtail
Group=promtail
ExecStart=/usr/local/promtail/promtail-linux-amd6 -config.file=/usr/local/promtail/promtail.yaml
ExecReload=/bin/kill -HUP $MAINPID
Restart=always
RestartSec=10
TimeoutStopSec=30
LimitNOFILE=65536

# 可选：限制资源（根据日志量调整）
# MemoryLimit=512M
# CPUQuota=50%

# 日志输出到 journald（便于调试）
StandardOutput=journal
StandardError=journal
SyslogIdentifier=promtail

# 安全加固（可选）
# NoNewPrivileges=true
# PrivateTmp=true
# ProtectSystem=strict
# ProtectHome=true

[Install]
WantedBy=multi-user.target
EOF

chmod +x /usr/lib/systemd/system/promtail.service
sudo systemctl daemon-reload && sudo systemctl enable --now promtail
sudo systemctl status promtail

# 实时查看日志（调试用）
#sudo journalctl -u promtail -f


##  granfana部署(agent)
useradd --system --home /usr/local/grafana --shell /sbin/nologin grafana
tar xf grafana-enterprise-9.3.6.linux-amd64.tar.gz && mv grafana-9.3.6 grafana && mv grafana  /usr/local
mkdir -p /usr/local/grafana/data/{log,plugins}
chown -R grafana.grafana /usr/local/grafana/
usermod -a -G root grafana


cat > /usr/lib/systemd/system/grafana.service <<'EOF'
[Unit]
Description=Grafana Enterprise instance
Documentation=https://grafana.com/docs/grafana/latest/?utm_source=grafana_server
Wants=network-online.target
After=network-online.target
After=postgresql.service mariadb.service mysql.service

[Service]
Type=notify
User=grafana
Group=grafana
WorkingDirectory=/usr/local/grafana
ExecStart=/usr/local/grafana/bin/grafana-server \
            --config=/usr/local/grafana/conf/defaults.ini \
            --pidfile=/usr/local/grafana/grafana.pid \
            --packaging=systemd \
            cfg:default.paths.logs=/usr/local/grafana/data/log \
            cfg:default.paths.data=/usr/local/grafana/data \
            cfg:default.paths.plugins=/usr/local/grafana/data/plugins \
            cfg:default.paths.provisioning=/usr/local/grafana/conf/provisioning
Restart=always
RestartSec=10
TimeoutStopSec=30
LimitNOFILE=65536

# 安全加固（可选）
# NoNewPrivileges=true
# ProtectSystem=full
# ProtectHome=true
# PrivateTmp=true

# 日志输出到 journald
StandardOutput=journal
StandardError=journal
SyslogIdentifier=grafana

[Install]
WantedBy=multi-user.target

EOF

chmod +x /usr/lib/systemd/system/grafana.service

sudo systemctl daemon-reload &&  sudo systemctl enable --now grafana &&  systemctl status grafana.service


## 服务报错问题AQ 
```bash 
usermod -a -G root loki
usermod -a -G root promtail
usermod -a -G root grafana

setfacl -m u:loki:rwx /var/log/
setfacl -m u:promtail:rwx /var/log/*
setfacl -m u:grafana:rwx /var/log/

Q sudo -u promtail cat /var/log/yum.log 
chmod o+r /var/log/*
chmod o+w /usr/local/promtail/

#日志
journalctl -u promtail -f --since "5 minutes ago"
journalctl -u promtail -f --since "1 minute ago"

#模块加载成功与否
journalctl -u rsyslog --since today | grep -i "module\|imfile\|imtcp"  
grep -i "module" /var/log/messages
grep -i "module" /var/log/syslog  #ubuntu
lsof -p $(pgrep rsyslog) | grep '\.so'   #imfile.so就会显示自定义的加载模块
rsyslogd -v  #查看编译时支持的模块（静态信息）
```

## 参考部署文档
[loki-官方](https://github.com/grafana/loki)  
[loki-csdn](https://www.cnblogs.com/xiangpeng/p/18127120)  
[高级-配置](https://cloud.tencent.com/developer/article/2375495)  
[文档](https://blog.csdn.net/AndCo/article/details/128949093)
[grafan线上下模板](https://grafana.com/grafana/dashboards/13639-logs-app/) #线下json模板  
[自学编程之道-Loki-轻量级日志聚合系统](https://www.toutiao.com/article/7204064333653869111) 
[轻量级日志采集系统loki](https://www.toutiao.com/article/7233780316522152483) 
[轻量级日志系统新贵Loki到底该如何玩转](https://m.toutiao.com/is/yYXEBbC/)
[Promtail+Loki+Grafana搭建轻量级日志管理平台](https://www.cnblogs.com/cao-lei/p/16848665.html)
