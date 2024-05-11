# [k8s-storage-DOC](https://kubernetes.io/zh-cn/docs/concepts/storage)
# k8s-Volume卷
- [1-k8s-EphemeralVolumes临时卷](https://github.com/gitseen/gitOps/blob/main/k8s/test.md#1-k8s-EphemeralVolumes临时卷)
  + [emptyDir](https://github.com/gitseen/gitOps/blob/main/k8s/test.md#emptyDir)
  + [configMap](https://github.com/gitseen/gitOps/blob/main/k8s/test.md#configMap)
  + [secret](https://github.com/gitseen/gitOps/blob/main/k8s/test.md#secret)
  + [downwardAPI](https://github.com/gitseen/gitOps/blob/main/k8s/test.md#downwardAPI)
  + [CSI临时卷](https://github.com/gitseen/gitOps/blob/main/k8s/test.md#CSI临时卷)
  + [通用临时卷](https://github.com/gitseen/gitOps/blob/main/k8s/test.md#CSI临时卷)
  + [hostPath](https://github.com/gitseen/gitOps/blob/main/k8s/test.md#hostPath)
- [2-k8s-ProjectedVolumes投射卷](https://github.com/gitseen/gitOps/blob/main/k8s/test.md#2-k8s-ProjectedVolumes投射卷)
- [3-k8s-PersistentVolumes持久卷](https://github.com/gitseen/gitOps/blob/main/k8s/test.md#3-k8s-PersistentVolumes持久卷)
- [4-k8s-StoageClasses存储类](https://github.com/gitseen/gitOps/blob/main/k8s/test.md#4-k8s-StoageClasses存储类)

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

# 1-k8s-EphemeralVolumes临时卷
k8s为了不同的用途,支持几种不同类型的临时卷 
- emptyDir： Pod启动时为空,存储空间来自本地的kubelet根目录(通常是根磁盘)或内存
- configMap、 downwardAPI、 secret： 将不同类型的K8s数据注入到Pod中
- CSI临时卷： 类似于前面的卷类型,但由专门支持此特性的指定CSI驱动程序提供
- 通用临时卷： 它可以由所有支持持久卷的存储驱动程序提供
- hostPath:  将node主机中一目录挂在到Pod中供容器使用(半持久化)
>emptyDir、configMap、downwardAPI、secret是作为本地临时存储提供的。它们由各个节点上的kubelet管理

# emptyDir
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


# configMap
Configmap是Kubernetes集群中非常重要的一种配置管理资源对象。借助于ConfigMap API向pod中的容器中注入配置信息的机制  

ConfigMap不仅仅可以保存环境变量或命令行参数等属性，也可以用来保存整个配置文件或者JSON格式的文件  

各种配置属性和数据以k/v或嵌套k/v样式存在到Configmap中  
>所有的配置信息都是以明文的方式来进行传递，实现资源配置的快速获取或者更新。 

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

# secret
在k8s集群中,有一些配置属性信息是非常敏感的,所以这些信息在传递的过程中,是不希望外人能够看到的,所以K8s提供了一种加密场景中的配置管理资源对象Secret  

它在进行数据传输之前,会对数据进行编码,在数据获取的时候,会对数据进行解码。从而保证整个数据传输过程的安全  

>这些数据是根据不同的应用场景,采用不同的加密机制 

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

# downwardAPI
downwardAPI 为运行在pod中的应用容器提供了一种反向引用。让容器中的应用程序了解所处pod或Node的一些基础属性信息  

从严格意义上来说,downwardAPI不是存储卷,它自身就存在。相较于configmap、secret等资源对象需要创建后才能使用;  
而downwardAPI引用的是Pod自身的运行环境信息,这些信息在Pod启动的时候就存在  

<details>
  <summary>downwardAPI清单</summary>
  <pre><code>
```
watting...........................
```
  </code></pre>
</details>

# CSI临时卷
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

# 通用临时卷
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

# hostPath

由于emptyDir中数据不会被持久化,它会随着Pod的结束而销毁,如果想简单的将数据持久化到主机中,可以选择HostPath  

hostPath就是将Node主机中一个实际目录挂在到Pod供容器使用,这样的设计就可以保证Pod销毁了,但是数据依据可以存在于Node主机上  

hostPath同一节点可上共享hostPath卷,使用相同路径的pod相同的文件(共享不同pod,pod挂同一hostPath)

# [2-k8s-ProjectedVolumes投射卷](https://kubernetes.io/zh-cn/docs/concepts/storage/projected-volumes/)
一个projected卷可以将若干现有的卷源映射到同一个目录之上;目前，以下类型的卷源可以被投射  
 + [emptyDir](https://github.com/gitseen/gitOps/blob/main/k8s/test.md#emptyDir)
 + [configMap](https://github.com/gitseen/gitOps/blob/main/k8s/test.md#configMap)
 + [secret](https://github.com/gitseen/gitOps/blob/main/k8s/test.md#secret)
 + [downwardAPI](https://github.com/gitseen/gitOps/blob/main/k8s/test.md#downwardAPI)
 + [serviceAccountToken](https://github.com/gitseen/gitOps/blob/main/k8s/test.md#serviceAccountToken)
 + [clusterTrustBundle](https://github.com/gitseen/gitOps/blob/main/k8s/test.md#clusterTrustBundle) 
<details>
  <summary>带有 Secret、DownwardAPI 和 ConfigMap 的配置示例</summary>
  <pre><code>
```
apiVersion: v1
kind: Pod
metadata:
  name: volume-test
spec:
  containers:
  - name: container-test
    image: busybox:1.28
    volumeMounts:
    - name: all-in-one
      mountPath: "/projected-volume"
      readOnly: true
  volumes:
  - name: all-in-one
    projected:
      sources:
      - secret:
          name: mysecret
          items:
            - key: username
              path: my-group/my-username
      - downwardAPI:
          items:
            - path: "labels"
              fieldRef:
                fieldPath: metadata.labels
            - path: "cpu_limit"
              resourceFieldRef:
                containerName: container-test
                resource: limits.cpu
      - configMap:
          name: myconfigmap
          items:
            - key: config
              path: my-group/my-config
```
  </code></pre>
</details>


<details>
  <summary>带有非默认权限模式设置的 Secret 的配置示例</summary>
  <pre><code>
```
apiVersion: v1
kind: Pod
metadata:
  name: volume-test
spec:
  containers:
  - name: container-test
    image: busybox:1.28
    volumeMounts:
    - name: all-in-one
      mountPath: "/projected-volume"
      readOnly: true
  volumes:
  - name: all-in-one
    projected:
      sources:
      - secret:
          name: mysecret
          items:
            - key: username
              path: my-group/my-username
      - secret:
          name: mysecret2
          items:
            - key: password
              path: my-group/my-password
              mode: 511
```
  </code></pre>
</details>


# serviceAccountToken
```bash
#serviceAccountToken投射卷
apiVersion: v1
kind: Pod
metadata:
  name: sa-token-test
spec:
  containers:
  - name: container-test
    image: busybox:1.28
    volumeMounts:
    - name: token-vol
      mountPath: "/service-account"
      readOnly: true
  serviceAccountName: default
  volumes:
  - name: token-vol
    projected:
      sources:
      - serviceAccountToken:
          audience: api
          expirationSeconds: 3600
          path: token
```

# clusterTrustBundle
```bash
#clusterTrustBundle投射卷
apiVersion: v1
kind: Pod
metadata:
  name: sa-ctb-name-test
spec:
  containers:
  - name: container-test
    image: busybox
    command: ["sleep", "3600"]
    volumeMounts:
    - name: token-vol
      mountPath: "/root-certificates"
      readOnly: true
  serviceAccountName: default
  volumes:
  - name: root-certificates-vol
    projected:
      sources:
      - clusterTrustBundle:
          name: example
          path: example-roots.pem
      - clusterTrustBundle:
          signerName: "example.com/mysigner"
          labelSelector:
            matchLabels:
              version: live
          path: mysigner-roots.pem
          optional: true
```

# 3-k8s-PersistentVolumes持久卷
hostpath
subPath
# 4-k8s-StoageClasses存储类


