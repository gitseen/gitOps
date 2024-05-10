
# [k8s-storage](https://kubernetes.io/zh-cn/docs/concepts/storage)

# k8s-Volume卷
1. 概念  
  K8s的卷是pod的一个组成部分,因此像容器一样在pod的规范中就定义了。它们不是独立的K8s对象,也不能单独创建或删除。  
pod中的所有容器都可以使用卷,但必须先将它挂载在每个需要访问它的容器中。在每个容器中,都可以在其文件系统的任意位置挂>载卷。  

2. 为什么需要Volume  
   容器磁盘上的文件的生命周期是短暂的,这就使得在容器中运行重要应用时会遇到问题。当容器崩溃时,kubelet会重启它,但是容器中的文件将丢失——容器以干净的状态(镜像最初的状态)重新启动。  
其次,在Pod中同时运行多个容器时,这些容器之间通常需要共享文件。K8s中的Volume抽象就很好的解决了这些问题。  

3. Volume类型  
![Kubernetes支持以下Volume 类型](https://ask.qcloudimg.com/http-save/yehe-6211241/icx05vjlba.png)  

![k8s-storage](pic/k8s-storage.png)  

# 1、k8s-Ephemeral Volumes临时卷
k8s为了不同的用途,支持几种不同类型的临时卷 
- emptyDir： Pod启动时为空,存储空间来自本地的kubelet根目录(通常是根磁盘)或内存
- configMap、 downwardAPI、 secret： 将不同类型的K8s数据注入到Pod中
- CSI临时卷： 类似于前面的卷类型,但由专门支持此特性的指定CSI驱动程序提供
- 通用临时卷： 它可以由所有支持持久卷的存储驱动程序提供
>emptyDir、configMap、downwardAPI、secret是作为本地临时存储提供的。它们由各个节点上的kubelet管理

## 1.1 emptyDir
1. 概念
emptyDir是在Pod被分配到Node时创建的,它的初始为空,且无须指定host上对应的目录文件,因为k8s会自动分配目录,当Pod销毁时,EmptyDir中的数据也会被永久删除。用途如下：
   - 临时空间,例如用于某些应用程序运行时所需的临时目录,且无须永久保留
   - 一个容器需要从另一个容器中获取数据的目录(多容器共享目录)

2. ymal清单
**emptyDir卷实现在同一pod中两个容器之间的文件共享**  
![pod-two-container](https://ask.qcloudimg.com/http-save/yehe-6211241/r4omerzdy6.png)  
<details>
  <summary>emptyDir-pod示例清单</summary>
  <pre><code>

```
apiVersion: v1
kind: Pod
metadata:
  labels:
    app: prod                           #pod标签 
  name: emptydir-fortune
spec:
  containers:
  - image: loong576/fortune
    name: html-generator
    volumeMounts:                       #名为html的卷挂载至容器的/var/htdocs目录
    - name: html
      mountPath: /var/htdocs
  - image: nginx:alpine
    name: web-server
    volumeMounts:                       #挂载相同的卷至容器/usr/share/nginx/html目录且设置为只读
    - name: html
      mountPath: /usr/share/nginx/html 
      readOnly: true
    ports:
    - containerPort: 80
      protocol: TCP
  volumes:
  - name: html                          #卷名为html的emptyDir卷同时挂载至以上两个容器
    emptyDir: {} 
```
  </code></pre>
</details>


## 1.2 configMap
<details>
  <summary>configMap清单</summary>
  <pre><code>
```
#kind: Namespace
#apiVersion: v1
#metadata:
#  name: zzjz
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: mysql-config2
  namespace: zzjz
data:
  mysqld.cnf: |
    [client]
    port = 3306
    socket = /var/run/mysqld/mysqld.sock
    [mysql]
    no-auto-rehash
    [mysqld]
    user = mysql
    port = 3306
    socket = /var/run/mysqld/mysqld.sock
    datadir = /var/lib/mysql
    bind-address = 0.0.0.0
    symbolic-links=0
    max_connections=10000
    sql_mode=STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION
    skip-ssl
    max_allowed_packet=64M
    [mysqld_safe]
    log-error= /var/log/mysql/mysql_oldboy.err
    pid-file = /var/run/mysqld/mysqld.pid
---
apiVersion: apps/v1
kind: Deployment
metadata:
  namespace: zzjz
  name: zzjz-mysql
  labels:
    app: zzjz-mysql
spec:
  replicas: 1
  selector:
    matchLabels:
      app: zzjz-mysql
  template:
    metadata:
      name: zzjz-mysql 
      labels:
        app: zzjz-mysql
    spec:
      nodeSelector:
        role: di-node2
      containers:
      - name: zzjz-mysql
        #image: mysql:5.7
        image: myshare.io:5000/zzjz-mysql:latest
        #image: registry.cn-hangzhou.aliyuncs.com/iot-private-caicaiju/mysql:latest
        #image: mysql:latest
        env:
        - name: MYSQL_ROOT_PASSWORD
          value: password
        ports:
        - containerPort: 3306
          name: zzjz-mysql
        volumeMounts:
        - name: mysql-persistent-storage
          mountPath: /var/lib/mysql
        - name: mysql-t1
          mountPath: /etc/mysql/mysql.conf.d
      volumes:
      - name: mysql-persistent-storage
        hostPath:
          path: /home/DeepInsight/zzjz-mysql
      - name: mysql-t1
        configMap:
          name: mysql-config2
      #imagePullSecrets:
      #- name: myregistrykey
---
apiVersion: v1
kind: Service
metadata:
  name: zzjz-mysql
  namespace: zzjz
  labels:
    app: zzjz-mysql
spec:
  type: NodePort
  selector:
    app: zzjz-mysql
  ports:
  - protocol: TCP
    port: 3306
    targetPort: 3306
    nodePort: 32306
  #externalIPs:
  #  - 192.168.32.240
```
  </code></pre>
</details>

## 1.3 secret
<details>
  <summary>secret清单</summary>
  <pre><code>
```
apiVersion: v1
kind: Secret
metadata:
  name: mysql-ex-secret
  namespace: default
type: Opaque
data:
  password: password
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mysqld-exporter
spec:
  selector:
    matchLabels:
      app: mysqld-exporter
  replicas: 1
  template:
    metadata:
      annotations:
        prometheus.io/scrape: "true"
        prometheus.io/port: "9104"
      labels:
        app: mysqld-exporter
    spec:
      containers:
      - name: mysqld-exporter
        image: prom/mysqld-exporter:latest
        env:
        - name: DATA_SOURCE_NAME
          valueFrom:
            secretKeyRef:
              name: mysql-ex-secret
              key: password
        ports:
        - containerPort: 9104
```
  </code></pre>
</details>

## 1.4 downwardAPI
<details>
  <summary>downwardAPI清单</summary>
  <pre><code>
```
watting...........................
```
  </code></pre>
</details>


---
## 1.5 CSI临时卷
<details>
  <summary>CSI临时卷-Pod的示例清单</summary>
  <pre><code>
```
kind: Pod
apiVersion: v1
metadata:
  name: my-csi-app
spec:
  containers:
    - name: my-frontend
      image: busybox:1.28
      volumeMounts:
      - mountPath: "/data"
        name: my-csi-inline-vol
      command: [ "sleep", "1000000" ]
  volumes:
    - name: my-csi-inline-vol
      csi:
        driver: inline.storage.kubernetes.io  #CSI提供驱动程序
        volumeAttributes:
          foo: bar
```
  </code></pre>
</details>

--- 
## 1.6 通用临时卷
<details>
  <summary>通用临时卷-Pod的示例清单</summary>
  <pre><code>
```
kind: Pod
apiVersion: v1
metadata:
  name: my-app
spec:
  containers:
    - name: my-frontend
      image: busybox:1.28
      volumeMounts:
      - mountPath: "/scratch"
        name: scratch-volume
      command: [ "sleep", "1000000" ]
  volumes:
    - name: scratch-volume
      ephemeral:  #属性
        volumeClaimTemplate:
          metadata:
            labels:
              type: my-frontend-volume
          spec:
            accessModes: [ "ReadWriteOnce" ]
            storageClassName: "scratch-storage-class"  #所提供的持久卷存储
            resources:
              requests:
                storage: 1Gi
```
  </code></pre>
</details>


# 2、k8s-Projected Volumes投射卷
一个projected卷可以将若干现有的卷源映射到同一个目录之上;目前，以下类型的卷源可以被投射  
+ [configMap](https://github.com/gitseen/gitOps/blob/main/k8s/k8s-storage.md##12-configMap)
+ [secret](https://github.com/gitseen/gitOps/blob/main/k8s/k8s-storage.md#13-configmap)
+ [downwardAPI](https://github.com/gitseen/gitOps/blob/main/k8s/k8s-storage.md#14-configmap)
+ serviceAccountToken
+ clusterTrustBundle

# 3、k8s-Persistent Volumes持久卷
hostpath
subPath
# 4、k8s-Stoage Classes存储类


