# K8S-Pod知识点
  - [k8s-1Pod概念](https://github.com/gitseen/gitOps/blob/main/k8s/k8s-pod.md#1Pod概念)
  - [k8s-2pod资源yaml清单](https://github.com/gitseen/gitOps/blob/main/k8s/k8s-pod.md#2pod资源yaml清单)
  - [k8s-3pod类型](https://github.com/gitseen/gitOps/blob/main/k8s/k8s-pod.md#3pod类型)
  - [k8s-4POD内容器间资源共享实现机制](https://github.com/gitseen/gitOps/blob/main/k8s/k8s-pod.md#4POD内容器间资源共享实现机制)
  - [k8s-5Pod常用管理命令](https://github.com/gitseen/gitOps/blob/main/k8s/k8s-pod.md#5Pod常用管理命令)
  - [k8s-6pod环境变量](https://github.com/gitseen/gitOps/blob/main/k8s/k8s-pod.md#6pod环境变量)
  - [k8s-7pod生命周期](https://github.com/gitseen/gitOps/blob/main/k8s/k8s-pod.md#7pod生命周期)
    * [pod生命周期-pod基础容器Pause](https://github.com/gitseen/gitOps/blob/main/k8s/k8s-pod.md#基础容器Pause)
    * [pod生命周期-Init-container](https://github.com/gitseen/gitOps/blob/main/k8s/k8s-pod.md#)
    * [pod生命周期-Main-container](https://github.com/gitseen/gitOps/blob/main/k8s/k8s-pod.md#)  
      **主容器生命周期事件的处理函数**  
      - postStart事件
      - preStop事件  
      **主容器生命周期健康检查(三种探针)**  
      - startupProbe启动探针
      - LivenessProbe存活探针
      - ReadinessProbe就绪探针
    * [pod生命周期-pod创建过程](https://github.com/gitseen/gitOps/blob/main/k8s/k8s-pod.md#创建过程)
    * [pod生命周期-pod终止过程](https://github.com/gitseen/gitOps/blob/main/k8s/k8s-pod.md#)
    * [pod生命周期-pod创建过程](https://github.com/gitseen/gitOps/blob/main/k8s/k8s-pod.md#创建过程)
    * [pod生命周期-pod创建过程](https://github.com/gitseen/gitOps/blob/main/k8s/k8s-pod.md#创建过程)
    * [pod生命周期-pod创建过程](https://github.com/gitseen/gitOps/blob/main/k8s/k8s-pod.md#创建过程)
    * [pod生命周期-pod创建过程](https://github.com/gitseen/gitOps/blob/main/k8s/k8s-pod.md#创建过程)

---

## 1Pod概念
Pod是k8s的最小单位,里面包含一组容器,其中一个为Pause容器,也称为"根容器"  
Pod是一个逻辑抽象概念,K8s创建和管理的最小单元,一个Pod由一个容器或多个容器组成    
Pod里面的多个业务容器共享Pause容器的网络和Volume卷  
Pod是短暂的,每个Pod都有一个唯一的IP地址,称之为PodIP,k8s管理的是Pod而不是直接管理容器  

**特点**  
+ 一个Pod可以理解为是一个应用实例
+ Pod中容器始终部署在一个Node上
+ Pod中容器共享网络、存储资源  
  
**Pod主要用法**  
* 运行单个容器：最常见的用法,在这种情况下,可以将Pod看作是单个容器的抽象封装
* 运行多个容器：边车模式(Sidecar)在Pod中定义专门容器,来执行主业务容器需要的辅助工作,将辅助功能同业务容器解耦,实现独立发布和能力重用  

**Pod信息状态**  
```bash
tantianran@test-b-k8s-master:~$ kubectl get pods -n test-a
NAME                         READY   STATUS    RESTARTS        AGE
goweb-demo-b98869456-25sj9   1/1     Running   1 (3m49s ago)   5d10h
在READY字段中,1/1的意义为在这个pod里,已准备的容器/一共有多少个容器
STATUS字段指pod当前运行状态,RESTARTS指pod是重启次数,AGE表pod运行时长
```  
---

## 2pod资源yaml清单
<details>
  <summary>k8s-pod-yaml</summary>
  <pre><code>
apiVersion: v1 #指定api版本,此值必须在kubectl apiversion中
kind: Pod #指定创建资源的角色/类型
metadata: #资源的元数据/属性
  name: web04-pod #资源的名字,在同一个namespace中必须唯一
  labels: #设定资源的标签,详情请见http://blog.csdn.net/liyingke112/article/details/77482384
    k8s-app: apache
    version: v1
    kubernetes.io/cluster-service: "true"
  annotations:            #自定义注解列表
    - name: String        #自定义注解名字
spec: #specification of the resource content 指定该资源的内容
  restartPolicy: Always #表明该容器一直运行,默认k8s的策略,在此容器退出后,会立即创建一个相同的容器
  nodeSelector:     #节点选择,先给主机打标签kubectl label nodes kube-node1 zone=node1
    zone: node1
  containers:
  - name: web04-pod #容器的名字
    image: web:apache #容器使用的镜像地址
    imagePullPolicy: Never #三个选择Always、Never、IfNotPresent,每次启动时检查和更新（从registery）images的策略,
                           # Always,每次都检查
                           # Never,每次都不检查（不管本地是否有）
                           # IfNotPresent,如果本地有就不检查,如果没有就拉取
    command: ['sh'] #启动容器的运行命令,将覆盖容器中的Entrypoint,对应Dockefile中的ENTRYPOINT
    args: ["$(str)"] #启动容器的命令参数,对应Dockerfile中CMD参数
    env: #指定容器中的环境变量
    - name: str #变量的名字
      value: "/etc/run.sh" #变量的值
    resources: #资源管理,请求请见http://blog.csdn.net/liyingke112/article/details/77452630
      requests: #容器运行时,最低资源需求,也就是说最少需要多少资源容器才能正常运行
        cpu: 0.1 #CPU资源（核数）,两种方式,浮点数或者是整数+m,0.1=100m,最少值为0.001核（1m）
        memory: 32Mi #内存使用量
      limits: #资源限制
        cpu: 0.5
        memory: 32Mi
    ports:
    - containerPort: 80 #容器开发对外的端口
      name: httpd  #名称
      protocol: TCP
    livenessProbe: #pod内容器健康检查的设置,详情请见http://blog.csdn.net/liyingke112/article/details/77531584
      httpGet: #通过httpget检查健康,返回200-399之间,则认为容器正常
        path: / #URI地址
        port: 80
        #host: 127.0.0.1 #主机地址
        scheme: HTTP
      initialDelaySeconds: 180 #表明第一次检测在容器启动后多长时间后开始
      timeoutSeconds: 5 #检测的超时时间
      periodSeconds: 15  #检查间隔时间
      #也可以用这种方法
      #exec: 执行命令的方法进行监测,如果其退出码不为0,则认为容器正常
      #  command:
      #    - cat
      #    - /tmp/health
      #也可以用这种方法
      #tcpSocket: //通过tcpSocket检查健康
      #  port: number
    lifecycle: #生命周期管理
      postStart: #容器运行之前运行的任务
        exec:
          command:
            - 'sh'
            - 'yum upgrade -y'
          #command: ["/bin/sh", "-c", "yum upgrade -y"]
      preStop:#容器关闭之前运行的任务
        exec:
          command: ['service httpd stop']
    volumeMounts:  #详情请见http://blog.csdn.net/liyingke112/article/details/76577520
    - name: volume #挂载设备的名字,与volumes[*].name 需要对应
      mountPath: /data #挂载到容器的某个路径下
      readOnly: True
  volumes: #定义一组挂载设备
  - name: volume #定义一个挂载设备的名字
    #meptyDir: {}
    hostPath:
      path: /opt #挂载设备类型为hostPath,路径为宿主机下的/opt,这里设备类型支持很多种
#https://www.jianshu.com/p/32042a744d1c
  </code></pre>
</details>

---

## 3pod类型
在K8S中,Pod可以根据其创建和管理的方式分为三类：静态Pod、自主式Pod和动态Pod  
- 静态Pod
- 自主式Pod
- 动态Pod  

### 3.1静态Pod(Static Pods)
**定义**   
静态Pod在指定的节点上由kubelet守护进程直接管理,不需要通过k8sAPI服务创建,而是直接在Node节点上创建并通过kubelet进行管理  
kubelet监视每个静态Pod(在它失败之后重新启动)静态Pod始终都会绑定到特定节点的Kubelet上  
静态Pod的配置文件通常放置在/etc/kubernetes/manifests目录中(或通过 --manifest-dir 参数指定的其他目录)  

**特点**  
不受高可用性HA保护：如果节点宕机,静态Pod将不可用,直到节点恢复  
不支持滚动更新或回滚  
不受k8sAPI服务的管理,因此不支持高级功能,如自动伸缩、健康检查等  
主要用于运行需要在所有节点上运行的服务,如集群监控代理等    

<details>
  <summary>静态pod示例</summary>
  <pre><code> 
随便登录到某台node节点,然后创建/etc/kubernetes/manifests/static_pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: test-static-pod
spec:
  containers:
  - name: test-container
    image: 192.168.11.247/web-demo/goweb-demo:20221229v3
    command: ["/bin/bash", "-c", "while true; do echo 'Hello, world!'; sleep 10; done"]

创建后,回到master节点上查看pod
kubectl get pod
NAME                                READY   STATUS    RESTARTS   AGE
test-static-pod-test-b-k8s-node01   1/1     Running   0          11s
通过上面的输出结果可以看到,该静态pod已经在节点test-b-k8s-node01上面正常运行了
说明kubelet守护进程已经自动发现并创建了它。你可能会问,它不是不需要API服务器监管吗？为啥在master节点能看到它？
因为kubelet会尝试通过Kubernetes API服务器为每个静态Pod自动创建一个镜像Pod这意味着节点上运行的静态Pod对API服务来说是可见的,但是不能通过API服务器来控制
且Pod名称将把以连字符开头的节点主机名作为后缀。
  </code></pre>
</details>

### 3.2自主式Pod(Standalone Pods)
**定义**   
自主式Pod是指通过Kubernetes API服务直接创建的Pod,而不是通过任何控制器(如Deployment、sts、ds、Job等)创建  
这些Pod通常作为一次性任务或测试目的使用  

**特点**  
可以通过kubectl run 或 kubectl create 命令创建   
不受任何控制器的管理,所以如果 Pod 因故障而被删除,它不会被自动重建   
通常不建议在生产环境中使用自主式 Pod,因为它们缺乏高可用性和可扩展性的保障   

**示例**  
```bash
使用kubectl run创建自主式Pod：
kubectl run my-standalone-pod --image=192.168.11.247/web-demo/goweb-demo:20221229v3 
```

### 3.3动态Pod(Dynamic Pods)
**定义**  
动态Pod是通过控制器(Deployment、StatefulSet、ds、Job、CronJob等）创建和管理的Pod  
这些Pod由控制器自动管理,包括创建、更新和删除  

**特点**  
受到高可用性保护：如果 Pod 因故障而被删除,控制器会自动重建Pod  
支持滚动更新、回滚和其他高级功能  
适用于大多数生产环境中的工作负载  

**[声明式pod示例参考](https://github.com/gitseen/gitOps/blob/main/k8s/yaml.md)**   

**Pod类型总结**  
- 静态Pod用于运行需要在所有节点上运行的服务,不受k8sAPI服务管理  
- 自主式Pod通常用于一次性任务或测试目的,直接通过k8ssAPI服务创建  
- 动态Pod通过控制器创建和管理,适用于大多数生产环境中的工作负载 

**[容器类型](https://mp.weixin.qq.com/s/-TXbvQiR-tpB0RgQ5d-QDw)**  
- 基础容器(pause container)  
- 初始化容器(init container)  
- Sidecar Container: 边车容器  
- Ephemeral Container: 临时容器  
- Multi Container: 多容器  
- 普通容器(业务容器/应用容器)  

**创建pod的容器分类**  
* 1、基础容器: pause
* 2、init(初始化状态):init c 1和2过程中,pod的状态init 1/3
* 3、业务容器


----
 
## 4POD内容器间资源共享实现机制
### 4.1Pod共享数据的机制
+ emptyDir  
  会在Pod被删除的同时也会被删除,当Pod分派到某个节点上时,emptyDir卷会被创建,并且在Pod在该节点上运行期间,卷一直存在。 就像其名称表示的那样,卷最初是空的。 尽管Pod中的容器挂载emptyDir卷的路径可能相同也可能不同,这些容器都可以读写emptyDir卷中相同的文件。 当Pod因为某些原因被从节点上删除时emptyDir卷中的数据也会被永久删除  
```
apiVersion: v1
kind: Pod
metadata:
name: test-pod1
spec:
containers:
- image: nginx
    name: nginx1
    volumeMounts:
    - mountPath: /cache
    name: cache-volume
- image: busybox
    name: bs1
    command: ["/bin/sh", "-c", "sleep 12h"]
    volumeMounts:
    - mountPath: /cache
    name: cache-volume
volumes:
- name: cache-volume
    emptyDir:
    sizeLimit: 500Mi
```
+ cephfs  
  cephfs 卷允许你将现存的CephFS卷挂载到Pod中,cephfs卷的内容在Pod被删除时会被保留,只是卷被卸载了。 这意味着cephfs卷可以被预先填充数据,且这些数据可以在Pod之间共享。同一cephfs卷可同时被多个写者挂载   

### 4.2Pod共享网络的机制
共享网络的机制是由Pause容器实现,下面慢慢分析一下,啥是pause,了解一下它的作用等等。  
1、先准备一个yaml文件（pod1.yaml ）,创建一个pod,pod里包含两个容器,一个是名为nginx1的容器,还有一个是名为bs1的容器  
```bash
apiVersion: v1
kind: Pod
metadata:
  name: test-pod1
spec:
  containers:
  - image: nginx
    name: nginx1
    volumeMounts:
    - mountPath: /cache
      name: cache-volume
  - image: busybox
    name: bs1
    command: ["/bin/sh", "-c", "sleep 12h"]
    volumeMounts:
    - mountPath: /cache
      name: cache-volume
  volumes:
  - name: cache-volume
    emptyDir:
      sizeLimit: 500Mi
```
2、开始创建  
```bash
kubectl create -f pod1.yaml
```
3、创建完后看看在哪个节点  
```bash
kubectl get pod -o wide
```
4、去到对应的节点查看容器  
```bash
docker ps | grep test-pod1
0db01653bdac   busybox                                                "/bin/sh -c 'sleep 1…"   9 minutes ago    Up 9 minutes              k8s_bs1_test-pod1_default_c3a15f70-3ae2-4a73-8a84-d630c047d827_0
296972c29efe   nginx                                                  "/docker-entrypoint.…"   9 minutes ago    Up 9 minutes              k8s_nginx1_test-pod1_default_c3a15f70-3ae2-4a73-8a84-d630c047d827_0
a5331fba7f11   registry.aliyuncs.com/google_containers/pause:latest   "/pause"                 10 minutes ago   Up 10 minutes             k8s_POD_test-pod1_default_c3a15f70-3ae2-4a73-8a84-d630c047d827_0
```

通过查看容器,名为test-pod1的pod里除了两个业务容器外(k8s_bs1_test-pod1、nginx1_test-pod1)还有一个pause容器,这个到底是什么?  

**对pause容器的理解**  
- pause容器又叫Infra container,就是基础设施容器的意思,Infra container只是pause容器的一个叫法而已
- 上面看到paus容器,是从registry.aliyuncs.com/google_containers/pause:latest这个镜像拉起的
- 在其中一台node节点上查看docker镜像,可看到该镜像的大小是240KB
```bash
  registry.aliyuncs.com/google_containers/pause        latest       350b164e7ae1   8 years ago     240kB
```
---

## 5Pod常用管理命令
**pod重启策略**  
+ Always：当容器终止退出,总是重启容器,默认策略
+ OnFailure：当容器异常退出（退出状态码非0）时,才重启容器
+ Never：当容器终止退出,从不重启容器

```bash
#查看pod的重启策略
kubectl get pods test-pod1 -o yaml #找到restartPolicy字段,就是重启策略restartPolicy: Always

#查看pod里所有容器的名称
kubectl get pods test-pod1 -o jsonpath={.spec.containers[*].name}

#进入pod里的指定容器的终端,如下进入pod为test-pod1里的容器nginx1和bs1
kubectl exec -it test-pod1 -c nginx1 -- bash
kubectl exec -it test-pod1 -c bs1 -- sh

#查看pod里指定容器的log
kubectl logs test-pod1 -c nginx1 
```

---

## 6pod环境变量
创建Pod时,可以为其下的容器设置环境变量。通过配置文件的env或者envFrom字段来设置环境变量  
**应用场景**  
+ 容器内应用程序获取pod信息
+ 容器内应用程序通过用户定义的变量改变默认行为
+ 变量值定义的方式  

**自定义变量值**  
- 变量值从Pod属性获取
- 变量值从Secret、ConfigMap获取  
<details>
  <summary>POD-ENV示例</summary>
  <pre><code> 
设置自定义变量,使用env给pod里的容器设置环境变量,本例子中,设置了环境变量有SAVE_TIME、MAX_CONN、DNS_ADDR  
apiVersion: v1
kind: Pod
metadata:
  name: test-env-demo
spec:
  containers:
  - name: test-env-demo-container
    image: 192.168.11.247/web-demo/goweb-demo:20221229v3
    env:
    - name: SAVE_TIME
      value: "60"
    - name: MAX_CONN
      value: "1024"
    - name: DNS_ADDR
      value: "8.8.8.8"

#开始创建POD kubectl create -f test-env.yaml
#创建后,验证环境变量是否能获取到(使用printenv打印环境变量) kubectl exec test-env-demo -- printenv
PATH=/go/bin:/usr/local/go/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
HOSTNAME=test-env-demo
SAVE_TIME=60 # 这个是
MAX_CONN=1024 # 这个是
DNS_ADDR=8.8.8.8 # 这个是
KUBERNETES_SERVICE_HOST=10.96.0.1
KUBERNETES_SERVICE_PORT=443
KUBERNETES_SERVICE_PORT_HTTPS=443
KUBERNETES_PORT=tcp://10.96.0.1:443
KUBERNETES_PORT_443_TCP=tcp://10.96.0.1:443
KUBERNETES_PORT_443_TCP_PROTO=tcp
KUBERNETES_PORT_443_TCP_PORT=443
KUBERNETES_PORT_443_TCP_ADDR=10.96.0.1
GOLANG_VERSION=1.19.4
GOPATH=/go
HOME=/root

#进入容器打印环境变量 kubectl exec -it test-env-demo -c test-env-demo-container -- bash
echo $SAVE_TIME # 单独打印一个
60
env  执行env命令查看
KUBERNETES_SERVICE_PORT_HTTPS=443
KUBERNETES_SERVICE_PORT=443
HOSTNAME=test-env-demo
PWD=/opt/goweb-demo
DNS_ADDR=8.8.8.8
HOME=/root
KUBERNETES_PORT_443_TCP=tcp://10.96.0.1:443
MAX_CONN=1024
GOLANG_VERSION=1.19.4
TERM=xterm
SHLVL=1
KUBERNETES_PORT_443_TCP_PROTO=tcp
KUBERNETES_PORT_443_TCP_ADDR=10.96.0.1
SAVE_TIME=60
KUBERNETES_SERVICE_HOST=10.96.0.1
KUBERNETES_PORT=tcp://10.96.0.1:443
KUBERNETES_PORT_443_TCP_PORT=443
PATH=/go/bin:/usr/local/go/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
GOPATH=/go
_=/usr/bin/env

  </code></pre>
</details>


<details>
  <summary>POD_ENV(使用容器字段作为环境变量的值)</summary>
  <pre><code> 
例子设置了资源限制的字段requests和limits,在设置环境变量中,使用资源限制的值作为了变量的值
apiVersion: v1
kind: Pod
metadata:
  name: test-env-demo
spec:
  containers:
  - name: test-env-demo-container
    image: 192.168.11.247/web-demo/goweb-demo:20221229v3
    resources:
      requests:
        memory: "32Mi"
        cpu: "125m"
      limits:
        memory: "64Mi"
        cpu: "250m"
    env:
      - name: CPU_REQUEST
        valueFrom:
          resourceFieldRef:
            containerName: test-env-demo-container
            resource: requests.cpu
      - name: CPU_LIMIT
        valueFrom:
          resourceFieldRef:
            containerName: test-env-demo-container
            resource: limits.cpu
      - name: MEM_REQUEST
        valueFrom:
          resourceFieldRef:
            containerName: test-env-demo-container
            resource: requests.memory
      - name: MEM_LIMIT
        valueFrom:
          resourceFieldRef:
            containerName: test-env-demo-container
            resource: limits.memory
#打印变量 kubectl exec test-env-demo -- printenv
PATH=/go/bin:/usr/local/go/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
HOSTNAME=test-env-demo
MEM_REQUEST=33554432
MEM_LIMIT=67108864
CPU_REQUEST=1
CPU_LIMIT=1
KUBERNETES_SERVICE_PORT_HTTPS=443
KUBERNETES_PORT=tcp://10.96.0.1:443
KUBERNETES_PORT_443_TCP=tcp://10.96.0.1:443
KUBERNETES_PORT_443_TCP_PROTO=tcp
KUBERNETES_PORT_443_TCP_PORT=443
KUBERNETES_PORT_443_TCP_ADDR=10.96.0.1
KUBERNETES_SERVICE_HOST=10.96.0.1
KUBERNETES_SERVICE_PORT=443
GOLANG_VERSION=1.19.4
GOPATH=/go
HOME=/root
  </code></pre>
</details>

---

## 7pod生命周期
