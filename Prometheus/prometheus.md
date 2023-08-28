# 一、Prometheus简介
## 1.1内容
```
1、监控简介、黑盒监控与白盒监控、常见的监控系统对比
2、prometheus 架构简介及部署方式(apt/yum、docker-compsoe、operator、二进制)
3、基于二进制部署prometheus Server及node-exporter
4、grafana简介、安装grafana、数据源管理及通过模板查看prometheus中的监控数据
5、PromQL语句简介、通过daemonset部署cadvisor及node-exporter
6、kubernetes环境中部署prometheus、服务发现基础及relabel基础
7、kubernetes服务发现配置示例
8、kubernetes部署prometheus以及二进制部署的prometheus实现服务发现
9、prometheus基于consul、file、dns实现服务发现
10、prometheus监控案例-kube-state-metrics和tomcat监控
```

```
1、prometheus监控案例-Tomcat、Redis、Mysql和Haproxy
2、prometheus监控案例-nginx监控、ingress-nginx-controller和blackbox_exporter简介及部署、基于blackbox_exporter实现对URL状态、IP可用性、端口状态、TLS证书的过期时间监控
3、prometheus告警流程简介及结合alertmanager实现邮件告警通知
4、prometheus结合钉钉实现告警通知
5、prometheus结合企业微信实现告警通知、告警模板的使用、告警分类发送及抑制和静默
6、pushgateway简介及实现、prometheus联邦简介
7、prometheus存储简介、prometheus结合victoriametrics实现单机远程存储
8、victoriametrics集群版本实现prometheus及grafana读写分离
```
## 1.2监控系统逻辑布局
![k8s-cluster](pic/pro-buju.png)

# Prometheus架构图
![prometheus-alt](pic/pro-alt.png)
```
prometheus server：主服务，接受外部http请求，收集、存储与查询数据等
prometheus targets: 静态收集的⽬标服务数据
service discovery：动态发现服务
prometheus alerting：报警通知
push gateway：数据收集代理服务器(类似于zabbix proxy)
data visualization and export： 数据可视化与数据导出(访问客户端)
```
# 二、部署Prometheus监控系统
```
可以通过不同的⽅式安装部署prometheus监控环境，虽然以下的多种安装⽅式演示了不同的部署⽅式，
但是实际⽣产环境只需要根据实际需求选择其中⼀种⽅式部署即可，不过⽆论是使⽤哪⼀种⽅式安装部署的prometheusserver，
以后的使⽤都是⼀样的，后续的课程⼤部分以⼆进制安装环境为例，其它会做简单的对应介绍。
```

```
apt install prometheus #使⽤apt或者yum安装
https://prometheus.io/download/ #官⽅⼆进制下载及安装，prometheus server的监听端⼝为9090
https://prometheus.io/docs/prometheus/latest/installation/ #docker镜像直接启动
https://github.com/coreos/kube-prometheus #operator部署
```
## 2.1 docker-compose部署Prometheus Server、nodeexporter与grafana
```
部署环境：172.31.7.201 #如果之前已经通过其它⽅式部署了prometheus server，需要先停⽌再部署，避免端⼝冲突
```
## 2.1.1:先安装docker、docker-compose
```
#1、使用脚本方式安装docker、docker-compose

tar xf docker-20.10.17-binary-install.tar.gz
bash docker-install.sh
docker info

#2、使用docker-compose.yaml文件方式执行部署
#https://github.com/mohamadhoseinmoradi/Docker-Compose-Prometheus-and-Grafana.git
git clone https://github.com/Einsteinish/Docker-Compose-Prometheus-and-Grafana.git
cd Docker-Compose-Prometheus-and-Grafana/
#修改docker-compose.yml文件
version: '2.1'

networks:
  monitor-net:
    driver: bridge

volumes:
    prometheus_data: {}
    grafana_data: {}

services:

  prometheus:
    image: prom/prometheus:v2.17.1
    container_name: prometheus
    volumes:
      - ./prometheus:/etc/prometheus
      - prometheus_data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--web.console.libraries=/etc/prometheus/console_libraries'
      - '--web.console.templates=/etc/prometheus/consoles'
      - '--storage.tsdb.retention.time=200h'
      - '--web.enable-lifecycle'
    restart: unless-stopped
    expose:
      - 9090
    networks:
      - monitor-net
    labels:
      org.label-schema.group: "monitoring"

  alertmanager:
    image: prom/alertmanager:v0.20.0
    container_name: alertmanager
    volumes:
      - ./alertmanager:/etc/alertmanager
    command:
      - '--config.file=/etc/alertmanager/config.yml'
      - '--storage.path=/alertmanager'
    restart: unless-stopped
    expose:
      - 9093
    networks:
      - monitor-net
    labels:
      org.label-schema.group: "monitoring"

  nodeexporter:
    image: prom/node-exporter:v0.18.1
    container_name: nodeexporter
    volumes:
      - /proc:/host/proc:ro
      - /sys:/host/sys:ro
      - /:/rootfs:ro
    command:
      - '--path.procfs=/host/proc'
      - '--path.rootfs=/rootfs'
      - '--path.sysfs=/host/sys'
      - '--collector.filesystem.ignored-mount-points=^/(sys|proc|dev|host|etc)($$|/)'
    restart: unless-stopped
    expose:
      - 9100
    networks:
      - monitor-net
    labels:
      org.label-schema.group: "monitoring"

  cadvisor:
    #image: gcr.io/google-containers/cadvisor:v0.34.0
    image: google/cadvisor:v0.33.0 #修改为docker hub上的地址，google地址无法拉取镜像
    container_name: cadvisor
    volumes:
      - /:/rootfs:ro
      - /var/run:/var/run:rw
      - /sys:/sys:ro
      - /var/lib/docker:/var/lib/docker:ro
      #- /cgroup:/cgroup:ro #doesn't work on MacOS only for Linux'
    restart: unless-stopped
    expose:
      - 8080
    networks:
      - monitor-net
    labels:
      org.label-schema.group: "monitoring"

  grafana:
    image: grafana/grafana:6.7.2
    container_name: grafana
    volumes:
      - grafana_data:/var/lib/grafana
      - ./grafana/provisioning:/etc/grafana/provisioning
  environment:
    - GF_SECURITY_ADMIN_USER=${ADMIN_USER}
    - GF_SECURITY_ADMIN_PASSWORD=${ADMIN_PASSWORD}
    - GF_USERS_ALLOW_SIGN_UP=false
  restart: unless-stopped
  expose:
    - 3000
  networks:
    - monitor-net
  labels:
    org.label-schema.group: "monitoring"

  pushgateway:
    image: prom/pushgateway:v1.2.0
    container_name: pushgateway
    restart: unless-stopped
    expose:
      - 9091
    networks:
      - monitor-net
    labels:
      org.label-schema.group: "monitoring"

  caddy:
    image: stefanprodan/caddy
    container_name: caddy
    ports:
      - "3000:3000"
      - "9090:9090"
      - "9093:9093"
      - "9091:9091"
    volumes:
      - ./caddy:/etc/caddy
    environment:
      - ADMIN_USER=${ADMIN_USER}
      - ADMIN_PASSWORD=${ADMIN_PASSWORD}
    restart: unless-stopped
    networks:
      - monitor-net
    labels:
      org.label-schema.group: "monitoring"

#3、运行docker-compose
dockercompose up -d -v

```
## 2.1.2 验证web登录页面
![login](pic/pro-login.png)

## 2.2 Operator部署prometheus监控系统
## 2.2.1 clone项⽬并部署
git clone -b release-0.11 https://github.com/prometheus-operator/kube-prometheus.git  
cd kube-prometheus  
kubectl apply --server-side -f manifests/setup  
# grep image: manifests/ -R | grep "k8s.gcr.io" #有部分镜像⽆法下载
```
准备kube-state-metrics镜像：
nerdctl pull bitnami/kube-statemetrics:2.5.0
nerdctl tag bitnami/kube-state-metrics:2.5.0 registry.cnhangzhou.aliyuncs.com/zhangshijie/kube-state-metrics:2.5.0
nerdctl push registry.cn-hangzhou.aliyuncs.com/zhangshijie/kube-statemetrics:2.5.0
# vim manifests/kubeStateMetrics-deployment.yaml
准备prometheus-adapter镜像：
manifests/prometheusAdapter-deployment.yaml: image:
k8s.gcr.io/prometheusadapter/prometheus-adapter:v0.9.1
nerdctl pull willdockerhub/prometheusadapter:v0.9.1
nerdctl tag willdockerhub/prometheus-adapter:v0.9.1 registry.cnhangzhou.aliyuncs.com/zhangshijie/prometheus-adapter:v0.9.1
nerdctl push registry.cn-hangzhou.aliyuncs.com/zhangshijie/prometheusadapter:v0.9.1
vim manifests/prometheusAdapter-deployment.yaml
# kubectl apply -f manifests/ #有些镜像⽆法下载需要⾃⾏解决
```
## 2.2.2 验证Pod状态
```
kubectl get pod -n monitoring
```
## 2.2.3 通过NodePort访问PrometheusServer
```
cat manifests/prometheus-service.yaml
apiVersion: v1
kind: Service
metadata:
  labels:
  app.kubernetes.io/component: prometheus
  app.kubernetes.io/instance: k8s
  app.kubernetes.io/name: prometheus
  app.kubernetes.io/part-of: kube-prometheus
  app.kubernetes.io/version: 2.33.3
  name: prometheus-k8s
  namespace: monitoring
spec:
  type: NodePort
  ports:
  - name: web
  port: 9090
  targetPort: web
  - name: reloader-web
  port: 8080
  targetPort: reloader-web
  selector:
  app.kubernetes.io/component: prometheus
  app.kubernetes.io/instance: k8s
  app.kubernetes.io/name: prometheus
  app.kubernetes.io/part-of: kube-prometheus
  sessionAffinity: ClientIP
kubectl apply -f manifests/prometheus-service.yaml
```
## 2.2.4 验证prometheusweb界⾯
![web](pic/pro-web.png)

# 2.2.5 通过NodePort访问Grafana
```
cat manifests/grafana-service.yaml
apiVersion: v1
kind: Service
metadata:
  labels:
  app.kubernetes.io/component: grafana
  app.kubernetes.io/name: grafana
  app.kubernetes.io/part-of: kube-prometheus
  app.kubernetes.io/version: 8.4.1
  name: grafana
  namespace: monitoring
spec:
  type: NodePort
  ports:
  - name: http
  port: 3000
  targetPort: http
  nodePort: 33000
  selector:
  app.kubernetes.io/component: grafana
  app.kubernetes.io/name: grafana
  app.kubernetes.io/part-of: kube-prometheus
kubectl apply -f manifests/grafana-service.yaml
```
## 2.2.6 验证grafanaweb界⾯
![web](pic/gra-web.png)

## 2.3 ⼆进制部署PrometheusServer
![开箱即用](pic/t1.png)
## 2.3.1 解压⼆进制程序
```
官网下载二进制文件
https://prometheus.io/download/
https://github.com/prometheus/prometheus

tar xf prometheus-2.38.0.linuxamd64.tar.gz
ln -sfv /usr/local/src/prometheus/prometheus-2.38.0.linux-amd64  /usr/local/src/prometheus/prometheus
cd prometheus
prometheus* #prometheus服务可执行程序
prometheus.yml #prometheus配置文件
promtool* #测试⼯具，⽤于检测配置prometheus配置⽂件、检测metrics数据等

./promtool check config prometheus.yml

```

## 2.3.2  创建prometheus service启动服务文件
```
vim  /etc/systemd/system/prometheus.service
[Unit]
Description=Prometheus Server
Documentation=https://prometheus.io/docs/introduction/overview/
After=network.target
[Service]
Restart=on-failure
WorkingDirectory=/usr/local/src/prometheus/prometheus
ExecStart=/usr/local/src/prometheus/prometheus/prometheus --
config.file=/usr/local/src/prometheus/prometheus/prometheus.yml
[Install]
WantedBy=multi-user.target
```
## 2.3.3 启动prometheus服务
```
systemctl daemon-reload && systemctl restart prometheus && systemctl enable prometheus 

systemctl daemon-reload && systemctl enable --now prometheus.service

systemctl status prometheus.service
```

## 2.3.4 验证prometheus web界⾯
http://x.x.x.x:port/   

## 2.3.5 动态(热)加载配置
```
#vim /etc/systemd/system/prometheus.service
--web.enable-lifecycle

[Unit]
Description=Prometheus Server
Documentation=https://prometheus.io/docs/introduction/overview/
After=network.target
[Service]
Restart=on-failure
WorkingDirectory=/usr/local/src/prometheus/prometheus
ExecStart=/usr/local/src/prometheus/prometheus/prometheus --
config.file=/usr/local/src/prometheus/prometheus/prometheus.yml --web.enablelifecycle
[Install]
WantedBy=multi-user.target

# systemctl daemon-reload
# systemctl restart prometheus.service
# curl -X POST http://10.0.0.23:9090/-/reload #重新加载配置文件
```

## 2.4 ⼆进制安装node-exporter
k8s各node节点使⽤⼆进制或者daemonset⽅式安装node_exporter，⽤于收集各k8snode节点宿主机的监控指标数据，默认监听端⼝为9100。
>> 部署环境：kubernetes的node节点，如果之前已经通过其它⽅式部署了prometheus node-exporter，需要先停⽌再部，避免端⼝冲突  

![exporter](pic/node-exporter.png)







































