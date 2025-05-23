# K8S-Pod知识点
  - [k8s-1Pod概念](https://github.com/gitseen/gitOps/blob/main/k8s/k8s-pod.md#1Pod概念)  
  - [k8s-2pod资源yaml清单](https://github.com/gitseen/gitOps/blob/main/k8s/k8s-pod.md#2pod资源yaml清单)  
  - [k8s-3pod类型](https://github.com/gitseen/gitOps/blob/main/k8s/k8s-pod.md#3pod类型)  
  - [k8s-4POD内容器间资源共享实现机制](https://github.com/gitseen/gitOps/blob/main/k8s/k8s-pod.md#4POD内容器间资源共享实现机制)  
  - [k8s-5Pod常用管理命令](https://github.com/gitseen/gitOps/blob/main/k8s/k8s-pod.md#5Pod常用管理命令)  
  - [k8s-6pod环境变量](https://github.com/gitseen/gitOps/blob/main/k8s/k8s-pod.md#6pod环境变量)  
  - [k8s-7pod生命周期](https://github.com/gitseen/gitOps/blob/main/k8s/k8s-pod.md#7pod生命周期)  
    * [pod生命周期-pod基础容器Pause](https://github.com/gitseen/gitOps/blob/main/k8s/k8s-pod.md#71-pause容器) 
    * [pod生命周期-pod阶段](https://github.com/gitseen/gitOps/blob/main/k8s/k8s-pod.md#72-pod阶段)
    * [pod生命周期-pod创建过程](https://github.com/gitseen/gitOps/blob/main/k8s/k8s-pod.md#73-pod创建)   
    * [pod生命周期-initContainer初始化容器运行](https://github.com/gitseen/gitOps/blob/main/k8s/k8s-pod.md#74-initcontainer初始化容器运行)  
    * [pod生命周期-mainContainer主容器运行](https://github.com/gitseen/gitOps/blob/main/k8s/k8s-pod.md#75-mainContainer主容器运行)  
    * [pod生命周期-主容器钩子函数](https://github.com/gitseen/gitOps/blob/main/k8s/k8s-pod.md#76-主容器钩子函数)  
      - [postStart启动后钩子](https://github.com/gitseen/gitOps/blob/main/k8s/k8s-pod.md#761-postStart启动后钩子)  
      - [preStop终止前钩子](https://github.com/gitseen/gitOps/blob/main/k8s/k8s-pod.md#762-preStop终止前钩子)   
    * [pod生命周期-主容器健康检查(三种探针)](https://github.com/gitseen/gitOps/blob/main/k8s/k8s-pod.md#77-主容器健康检查(三种探针))  
      - [主容器健康检测作用](https://github.com/gitseen/gitOps/blob/main/k8s/k8s-pod.md#771--主容器健康检测作用)  
      - [主容器探针配置参数](https://github.com/gitseen/gitOps/blob/main/k8s/k8s-pod.md#772--探针配置参数)  
      - [主容器探针检测方式与检测结果](https://github.com/gitseen/gitOps/blob/main/k8s/k8s-pod.md#773--探针检测方式与检测结果)  
      - [主容器健康检测示例](https://github.com/gitseen/gitOps/blob/main/k8s/k8s-pod.md#774--主容器健康检测示例)  
    * [pod生命周期-pod终止过程](https://github.com/gitseen/gitOps/blob/main/k8s/k8s-pod.md#78-pod终止过程)  
    * [pod生命周期-pod状态](https://github.com/gitseen/gitOps/blob/main/k8s/k8s-pod.md#79-pod状态)     
  - [k8s-8pod重启方法](https://github.com/gitseen/gitOps/blob/main/k8s/k8s-pod.md#8pod重启方法)  

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

### 3.1 静态Pod(Static Pods)
**静态Pod在指定的节点上由kubelet守护进程直接管理,而是直接在Node节点上启动运行**  
**kubelet监视每个静态Pod(在它失败之后重新启动)静态Pod始终都会绑定到特定节点的Kubelet上**  
**静态Pod的配置文件通常放置在/etc/kubernetes/manifests目录中(或通过 --manifest-dir 参数指定的其他目录)**  
- 特点
  + 不受高可用性HA保护：如果节点宕机,静态Pod将不可用,直到节点恢复
  + 不支持滚动更新或回滚
  + 不受k8sAPI服务的管理,因此不支持高级功能,如自动伸缩、健康检查等
  + 主要用于运行需要在所有节点上运行的服务,如集群监控代理等
  + 节点绑定：仅运行在配置了该Pod的节点上  
  + 独立生命周期：修改配置文件后,kubelet自动同步更新Pod状态   
  + 适用场景：部署系统级组件(如kube-apiserver、kube-proxy、Flannel、Calico) 

<details>
  <summary>静态pod示例</summary>
  <pre><code> 
---
随便登录到某台node节点,然后创建/etc/kubernetes/manifests/static_pod.yaml
apiVersion: v1
kind: Pod 
metadata:
  name: static-web 
  labels:
    role: static-server 
spec:
  containers:
  - name: nginx 
    image: nginx 
    ports:
    - containerPort: 80 
---
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
说明kubelet守护进程已经自动发现并创建了它。你可能会问,它不是不需要API服务器监管吗?为啥在master节点能看到它?
因为kubelet会尝试通过kube-api服务器为每个静态Pod自动创建一个镜像Pod这意味着节点上运行的静态Pod对API服务来说是可见的,但是不能通过API服务器来控制
且Pod名称将把以连字符开头的节点主机名作为后缀 
  </code></pre>
</details>

### 3.2 自主式Pod(Standalone Pods|Bare pod) 
**直接通过kubectl或ymal文件手动创建的Pod,不依赖任何控制器管理**   
**自主式Pod是通过kube-api服务直接创建的Pod,而不是通过任何控制器(deploy、sts、ds、job)创建,该Pod通常作为一次性任务或测试目的使用**  

- 特点 
  + 可以通过kubectl run 或 kubectl create 命令创建
  + 不受任何控制器的管理,所以如果Pod因故障而被删除,它不会被自动重建
  + 通常不建议在生产环境中使用自主式Pod,因为它们缺乏高可用性和可扩展性的保障
  + 生命周期与Pod本身绑定,删除后不会自动重建  
  + 适用于临时性任务或测试场景

<details>
  <summary>自主式Pod-示例</summary>
  <pre><code>
---
apiVersion: v1
kind: Pod 
metadata:
  name: myapp-pod 
spec:
  containers:
  - name: nginx 
    image: nginx:alpine 

or

#使用CLI命令
kubectl run my-standalone-pod --image=192.168.11.247/web-demo/goweb-demo:20221229v3  #使用kubectl run创建自主式Pod
  </code></pre>
</details>

### 3.3 动态Pod(Dynamic Pods)
**由k8s控制器(Deployment、rs、sts、ds、job、cronjob等)自动创建和管理的Pod**  
动态Pod是通过控制器(Deployment、StatefulSet、ds、Job、CronJob等)创建和管理的Pod;这些Pod由控制器自动管理(创建、更新、删除)    

- 特点
  + 受到高可用性保护：如果Pod因故障而被删除,控制器会自动重建Pod  
  + 自愈能力：Pod异常终止或节点故障时,控制器会自动重建Pod    
  + 副本管理：支持定义副本数量,确保应用高可用性(如Deployment通过ReplicaSet控制Pod副本)   
  + 滚动更新/回滚：支持无缝升级应用版本,并支持版本回退(支持滚动更新、回滚和其他高级功能)  
  + 适用于大多数生产环境中的工作负载  

**常见控制器类型**  
* Deployment：无状态应用的标准控制器  
* StatefulSet：适用于有状态应用(如数据库)   
* DaemonSet：确保每个节点运行一个Pod(如日志采集组件)   
* Job/CronJob：执行一次性或周期性任务   

**POD类型比总结**   
| 类型       | 管理方式 | 生命周期 |  典型场景 |
| ---------  | ------- |------- |------- |
| 静态Pod    |  节点kubelet直接管理 | 配置文件驱动 | 系统组件、网络插件 |
| 自主式Pod  |  用户手动管理  |  删除后不可恢复 | 临时任务、调试 |
| 动态Pod(Dynamic Pods) |  控制器自动管理  | 自愈、动态调整 | 生产环境应用(如Web服务、数据库) |  
- 静态Pod用于运行需要在所有节点上运行的服务,不受k8sAPI服务管理  
- 自主式Pod通常用于一次性任务或测试目的,直接通过k8sAPI服务创建
- 动态Pod通过控制器创建和管理,适用于大多数生产环境中的工作负载

>注意事项  
>>控制器管理Pod是生产环境首选,推荐使用Deployment/StatefulSet等控制器实现高可用和自动化运维  
>>静态Pod需谨慎使用,仅适用于节点级核心组件,避免与普通Pod管理方式混淆  

[动态Pod 或 声明式pod示例参考](https://github.com/gitseen/gitOps/blob/main/k8s/yaml.md)    


**[容器类型](https://mp.weixin.qq.com/s/-TXbvQiR-tpB-1RgQ5d-QDw)** 
- 基础容器(pausecontainer)  
- 初始化容器(initcontainer)  
- [SidecarContainer: 边车容器](https://kubernetes.io/zh-cn/docs/concepts/workloads/pods/sidecar-containers/#sidecar-example)  
- EphemeralContainer: 临时容器  
- MultiContainer: 多容器  
- 普通容器(业务容器/应用容器)  

**创建pod的容器分类**  
* 1、基础容器: pause
* 2、initContainer(初始化状态):init c 1和2过程中,pod的状态init 1/3
* 3、manContainer业务容器
每个Pod都有一个特殊的被称为"根容器"的Pause容器  
Pause容器对应的镜像属于k8s平台的一部分,除了Pause容器，每个Pod还包含一个或者多个紧密相关的用户业务容器和init初始化容器  
![pod组成图](pic/pod1.png)  

---
 
## 4POD内容器间资源共享实现机制
**在k8s中Pod内多个容器间通过共享命名空间和存储机制实现资源协同,具体实现方式可归纳为以下四个核心机制**    
### 4.1 网络共享机制(共享网络命名空间)  
Pod内所有容器共享同一个网络命名空间,表现为共享IP地址、端口范围和网络设备视图  
 - 实现原理：创建Pod时,先启动一个infra容器(pause容器),其他容器通过加入该容器的网络命名空间实现共享。所有容器的网络流量通过infra容器的网络栈收发  
 - 应用场景：容器间可通过localhost直接通信(如微服务间API调用)  

<details>
  <summary>示例验证</summary>
  <pre><code>
containers:
- name: nginx 
  image: nginx 
- name: busybox 
  image: busybox   #执行kubectl exec进入busybox容器,可通过netstat -tpln查看到nginx监听的80端口
---
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
  </code></pre>
</details>

**共享网络的机制是由Pause容器实现,下面慢慢分析一下,啥是pause,了解一下它的作用等等**  
<details>
  <summary>Pod共享网络-示例</summary>
  <pre><code>
---
#先准备一个yaml文件(pod1.yaml),创建一个pod,pod里包含两个容器,一个是名为nginx1的容器,还有一个是名为bs1的容
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

kubectl create -f pod1.yaml  #开始创建
kubectl get pod -o wide      #创建完后看看在哪个节点
docker ps | grep test-pod1   #去到对应的节点查看容器
docker ps | grep test-pod1
0db01653bdac   busybox                                                "/bin/sh -c 'sleep 1…"   9 minutes ago    Up 9 minutes              k8s_bs1_test-pod1_default_c3a15f70-3ae2-4a73-8a84-d630c047d827_0
296972c29efe   nginx                                                  "/docker-entrypoint.…"   9 minutes ago    Up 9 minutes              k8s_nginx1_test-pod1_default_c3a15f70-3ae2-4a73-8a84-d630c047d827_0
a5331fba7f11   registry.aliyuncs.com/google_containers/pause:latest   "/pause"                 10 minutes ago   Up 10 minutes             k8s_POD_test-pod1_default_c3a15f70-3ae2-4a73-8a84-d630c047d827_0
  </code></pre>
</details>

通过查看容器,名为test-pod1的pod里除了两个业务容器外(k8s_bs1_test-pod1、nginx1_test-pod1)还有一个pause容器,这个到底是什么?  

**对pause容器的理解** 
- pause容器又叫Infracontainer就是基础设施容器的意思,Infracontainer只是pause容器的一个叫法而已  
- 上面看到paus容器,是从registry.aliyuncs.com/google_containers/pause:latest这个镜像拉起的
- 在其中一台node节点上查看docker镜像,可看到该镜像的大小是240KB  
  ```bash
  registry.aliyuncs.com/google_containers/pause        latest       350b164e7ae1   8 years ago     240kB
  ```

### 4.2 存储共享机制(volumes挂载共享)
通过Pod级别的Volume(emptyDir)挂载到多个容器,实现文件系统共享  
- emptyDir的生命周期与Pod一致,适合临时数据共享  
- emptyDir   
      会在Pod被删除的同时也会被删除,当Pod分派到某个节点上时,emptyDir卷会被创建,并且在Pod在该节点上运行期间,卷一直存在就像其名称表示的那样,卷最初是空的;  
      尽管Pod中的容器挂载emptyDir卷的路径可能相同也可能不同,这些容器都可以读写emptyDir卷中相同的文件;当Pod因为某些原因被从节点上删除时emptyDir卷中的数据也会被永久删除  
- cephfs
      cephfs卷允许你将现存的CephFS卷挂载到Pod中,cephfs卷的内容在Pod被删除时会被保留,只是卷被卸载了;  
      这意味着cephfs卷可以被预先填充数据,且这些数据可以在Pod之间共享。同一cephfs卷可同时被多个写者挂载   
<details>
  <summary>volumes-emptyDir</summary>
  <pre><code>
spec:
  containers:
  - name: nginx 
    volumeMounts:
    - name: shared-data 
      mountPath: /data 
  - name: busybox 
    volumeMounts:
    - name: shared-data 
      mountPath: /data 
  volumes:
  - name: shared-data 
    emptyDir: {}
  </code></pre>
</details>

### 4.3 进程命名空间共享(PID)
默认情况下,Pod内容器的进程相互隔离。通过设置spec.shareProcessNamespace:true,容器可互相查看进程列表  
- 应用场景：调试场景中查看其他容器的进程状态  
- 示例：在 busybox容器中执行ps可查看到nginx 容器的进程

### 4.4 IPC共享内存机制(SystemV/POSIX 共享内存)
通过挂载/dev/shm或使用Volume实现跨容器的内存共享  

配置方式  
   - 使用hostPath卷挂载/dev/shm  
   - 通过emptyDir卷挂载内存目录(medium: Memory)实现高速共享内存  
   - 限制：需注意内存泄漏风险,避免因共享内存异常导致Pod被驱逐  
**对比总结**  

| 共享类型  | 实现机制 | 典型应用场景 | 
| --------- | ------- |------- |
| 网络 |  共享infra容器的网络命名空间  |  容器间直接通信(如微服务) |
| 存储 |  Pod级别Volume | 日志收集、临时文件共享 |
| 进程 |  启用shareProcessNamespace参数  | 跨容器进程调试 |
| 资源计算 |  影响Pod调度资源  | 仅影响自身资源 |
| IPC 共享内存 |  /dev/shm或内存卷挂载  | 高性能计算、实时数据处理 |  
>注意事项  
>>生产环境建议：优先使用控制器管理的Pod(如Deployment)避免直接操作自主式Pod  
>>安全性：共享IPC或PID命名空间可能引入安全风险,需结合Pod安全策略(PSP)进行权限控制    


---

## 5Pod常用管理命令
```bash
kubectl create -f <文件名>  #根据yaml文件部署(第一次create)
kubectl apply -f <文件名>   #根据yaml文件部署(第二次更新应用)
kubectl delete -f <文件名>  #根据yaml文件删除
kubectl get node,pod,svc  #查看k8s个组件的状态
kubectl describe node <node名称>  #查看node详情
kubectl describe pod <pod名称> #查看pod详情
kubectl describe svc <svc名称> #查看service详情
kubectl delete svc <svc名称> -n <命名空间>  #删除svc 
kubectl exec -it <pod名称> -c <容器组空间> -n <命名空间> -- bash   #进入容器内部
kubectl cp -n <命名空间> <pod名称>:/文件src /本地文件  #容器拷贝文件到本地服务器


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
在k8s中Pod环境变量是容器化应用配置的重要手段,提供了灵活的配置管理能力,可通过多种方式定义和管理  
创建Pod时,可以为其下的容器设置环境变量;通过配置文件的env或者envFrom字段来设置环境变量   

### 6.1 环境变量设置方式
- 直接声明  
```bash
在Pod定义文件的env字段中直接指定键值对(#此方式会覆盖镜像默认环境变量)
env:
- name: DEMO_GREETING 
  value: "Hello from env"
- name: DEMO_FAREWELL 
  value: "Goodbye"
```
- ConfigMap/Secret引用    
```bash
1、单个引用: 通过valueFrom.configMapKeyRef或valueFrom.secretKeyRef注入  
env:
- name: DB_HOST 
  valueFrom:
    configMapKeyRef:
      name: cm-db-config 
      key: db.host  

2、批量注入: 通过envFrom字段将ConfigMap/Secret的所有键值注入为环境变量(#若键名不符合POSIX规范(如包含.)可能导致部分变量无法注入)   
envFrom:
- configMapRef:
    name: cm-configmap
- secretRef:
    name: cm-secret  
```

- 动态字段引用  
```bash
通过valueFrom.fieldRef 引用Pod/容器元数据(如IP、名称、命名空间)(#支持引用字段包括metadata.name 、status.hostIP)            
env:
- name: MY_POD_IP 
  valueFrom:
    fieldRef:
      fieldPath: status.podIP  
```

### 6.2 应用场景
- 应用配置管理  
  传递数据库地址、日志级别等参数,避免硬编码在镜像中  

- 容器间依赖  
```bash
通过$(VAR_NAME)语法实现环境变量间的依赖
env:
- name: SERVICE_PORT 
  value: "8080"
- name: SERVICE_URL 
  value: "http://$(SERVICE_NAME):$(SERVICE_PORT)"
```
- 元数据传递  
  内置环境变量(如POD_IP、POD_NAME)可用于日志文件名、服务注册等场景

- 与命令行参数结合  
```bash
环境变量可作为容器启动命令的参数：
args: ["$(GREETING) $(NAME)"]
```

### 6.3 内置环境变量
```bash
k8s自动注入以下元数据(需通过fieldRef显式声明)
status.podIP ：Pod的IP地址
metadata.name ：Pod名称
metadata.namespace ：Pod所在命名空间
spec.serviceAccountName ：使用的服务账号
```

>注意事项  
>>覆盖优先级(env或envFrom设置的变量会覆盖镜像默认值)  
>>更新限制(环境变量在Pod创建后无法修改,需重建Pod生效(ConfigMap/Secret更新后需重启容器))  
>>批量注入风险(使用envFrom时,若ConfigMap/Secret包含无效键名,可能导致部分变量注入失败)  
>>敏感数据保护(敏感信息(如密码)应通过Secret而非普通ConfigMap传递)  

**实际使用时,建议结合ConfigMap/Secret实现配置与代码分离,并通过字段引用动态获取Pod元数据**  

### 6.4 k8s-env示例  
[具体操作可参考主容器配置](https://github.com/gitseen/gitOps/blob/main/k8s/k8s-pod.md#754-maincontainer主容器的配置示例)   
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
**Pod的生命周期是指从Pod被创建开始直到它被删除或终止的时间范围称为其生命周期**   
 
在这段时间中,Pod会处于多种不同的状态,并执行一系统操作,操作如下： 
 
**创建pause容器 → 创建 → 调度 → 初始化init容器启动→ 主容器启动mainContainer → 主容器postStart启动后钩子 → 主容器preStop终止前钩子 → 主容器探针检测 → 主容器运行Running → 终止Termination → 清理**   

***pod生命周期架构图***    
![pod生命周期图1](pic/podlife1.png)  
![pod生命周期图2](pic/podlife2.png)  
![pod生命周期图3](pic/podlife3.png)  
![pod生命周期图4](pic/podlife4.png)  
![pod生命周期图5](pic/podlife5.jpeg)  
![pod生命周期图6](pic/podlife6.png)  

pod对象从创建至终的这段时间范围称为pod的生命周期,它主要包含下面的过程：  
- [pod生命周期-pod基础容器Pause](https://github.com/gitseen/gitOps/blob/main/k8s/k8s-pod.md#71-pause容器)
- [pod生命周期-pod阶段](https://github.com/gitseen/gitOps/blob/main/k8s/k8s-pod.md#72-pod阶段)
- [pod生命周期-pod创建](https://github.com/gitseen/gitOps/blob/main/k8s/k8s-pod.md#73-pod创建)
- [pod生命周期-initContainer初始化容器运行](https://github.com/gitseen/gitOps/blob/main/k8s/k8s-pod.md#74-initcontainer初始化容器运行)
- [pod生命周期-mainContainer主容器运行](https://github.com/gitseen/gitOps/blob/main/k8s/k8s-pod.md#75-mainContainer主容器运行)
- [pod生命周期-主容器钩子函数](https://github.com/gitseen/gitOps/blob/main/k8s/k8s-pod.md#76-主容器钩子函数)
  * [postStart启动后钩子](https://github.com/gitseen/gitOps/blob/main/k8s/k8s-pod.md#761-postStart启动后钩子)   
  * [preStop终止前钩子](https://github.com/gitseen/gitOps/blob/main/k8s/k8s-pod.md#762-preStop终止前钩子)    
- [pod生命周期-主容器健康检查(三种探针)](https://github.com/gitseen/gitOps/blob/main/k8s/k8s-pod.md#77-主容器健康检查(三种探针))
  * [主容器健康检测作用](https://github.com/gitseen/gitOps/blob/main/k8s/k8s-pod.md#771--主容器健康检测作用)  
  * [主容器探针配置参数](https://github.com/gitseen/gitOps/blob/main/k8s/k8s-pod.md#772--探针配置参数)  
  * [主容器探针检测方式与检测结果](https://github.com/gitseen/gitOps/blob/main/k8s/k8s-pod.md#773--探针检测方式与检测结果)  
  * [主容器健康检测示例](https://github.com/gitseen/gitOps/blob/main/k8s/k8s-pod.md#774--主容器健康检测示例)  
- [pod生命周期-pod终止](https://github.com/gitseen/gitOps/blob/main/k8s/k8s-pod.md#78-pod终止过程)   
- [pod生命周期-pod状态](https://github.com/gitseen/gitOps/blob/main/k8s/k8s-pod.md#79-pod状态)   

## 7、1 pause容器
k8s中的Pause容器(又称InfraContainer)是Pod的基础设施组件  
pause核心作用是为Pod内的其他容器提供共享的运行环境;通过共享命名空间和稳定生命周期,实现了多容器的高效协作     
Pod里运行Pause容器、业务容器(mianContainer),业务容器共享Pause容器的网络栈和Volume挂载卷,实现高效通信和数据交换  

pause共享两种资源(存储、网络)
- 网络
        每个pod都会被分配一个集群内部的唯一ip地址,pod内的容器共享网络,pod在集群内部的ip地址和端口  
        pod内部的容器可以使用localhost互相通信,pod中的容器与外部通信时,从共享的资源当中进行分配,宿主机的端口映射  
- 存储
        pod可以指定共享的volume,pod内的容器共享这些volume,volume可以实现持久化。防止pod重新构建之后文件消失  

![pause容器](pic/podpause00.png)  

### 7.1.1、Pause容器的核心作用提供共享命名空间  
kubernetes中的pause容器主要为每个业务容器提供共享命名空间  
- PID命名空间： Pod中的不同应用程序可以看到其他应用程序的进程ID,pid命名空间开启init进程;所有容器共享同一个进程树(通过kubectl exec看进程)
- 网络命名空间：Pod中的多个容器能够共享同一个IP和端口范围;所有Pod内容器共享同一个IP和端口空间  
- IPC命名空间： Pod中的多个容器能够使用SystemV IPC或POSIX消息队列进行通信;允许容器间通过进程间通信(如共享内存)  
- UTS命名空间： Pod中的多个容器共享一个主机名;Volumes(共享存储卷)  
![pod状态的变化](pic/podpause0.png)  


### 7.1.2、Pause容器与Pod生命周期的关系
- Pod启动阶段  
  * 初始化Pause容器：当Pod被调度到节点后,kubelet首先启动Pause容器。它的唯一任务是挂起自身(执行pause命令),占用极少的资源  
  * 创建共享命名空间：Pause容器为Pod建立网络、IPC等命名空间,后续所有用户容器(如业务容器)会加入这些命名空间  
  * Pod网络配置：CNI插件(如Calico、Flannel)会基于Pause容器的网络命名空间配置Pod的IP、路由规则等
  
- Pod运行阶段  
  * 维持命名空间稳定性：Pause容器在整个Pod生命周期中持续运行,确保即使业务容器崩溃重启,Pod的网络命名空间(如IP地址)也不会改变  
  * 处理PID1进程：在Linux中,PID1进程负责孤儿进程回收。Pause容器作为PID1进程,确保业务容器的孤儿进程能被正确回收,避免僵尸进程  
  
- Pod终止阶段  
  * 优雅终止：当Pod被删除时,kubelet首先向Pause容器发送SIGTERM信号,触发Pod内所有容器的终止流程  
  * 清理资源：Pause容器退出后,其占用的网络命名空间等资源会被释放,确保Pod彻底终止  

### 7.1.3、Pause容器常见问题
- 为什么需要Pause容器?  
  * 稳定性：避免因业务容器重启导致Pod网络配置丢失  
  * 资源隔离：将Pod级别的资源(如IP)与容器解耦,实现多容器共享;共享(存储、网络)资源  
  * 标准化：统一Pod的初始化流程,简化CNI插件的实现  

- Pause容器崩溃会怎样?  
  * 如果Pause容器崩溃,整个Pod会被kubelet标记为失败,并触发重建。因为Pause容器是Pod的基础设施,它的崩溃意味着Pod的共享命名空间已不可用。

- 如何查看Pause容器?
  * docker ps |grep pause 或crictl ps  

***pause总结***
- Pause容器是Pod的"基础设施":它不运行业务代码,但为Pod提供共享的命名空间和稳定的运行环境  
- 生命周期绑定：Pause容器的启动、运行和终止与Pod的生命周期完全同步  
- 设计意义：通过解耦Pod基础设施与业务容器,k8s实现了更灵活的容器编排能力  
- 理解Pause容器的作用,有助于深入掌握k8s的网络模型、资源隔离机制以及多容器协作原理  

## 7.2 pod阶段
Pod阶段phase是Pod在其生命周期中的简单宏观概述,该阶段并不是对容器或Pod的综合汇总,也不是为了做为综合状态机   
Pod的"status"字段是一个PodStatus对象,其中包含"phase"字段 (Pod.status.phase)  
```bash
kubectl get pod podName -o yaml | grep phase

kubectl get pod podName -o jsonpath="{.status.phase}"
```
| pod阶段  | 描述 |     
| --------- | ------- | 
| Pending | k8s已开始创建Pod,由于Pod中的容器还未创建成功,所以Pod还处于挂起的状态,这时Pod可能在等待被调度,或者在等待下载镜像  |
| Runging | Pod已被调度到某个节点上,Pod中的所有容器都已成功创建,并且至少有一个容器正处于启动、重启、运行这3个状态中的1个  |
| Success | Pod中的所有容器都已成功执行完成,并且不会再重启  |
| Failed  | Pod所有容器都已经停止运行,并且至少有一个容器是因为失败而退出(即容器以非0状态退出或者被系统强制终止)  |
| Unknown | 因为某些原因导致无法取得Pod的状态。这种情况通常是由于网络的造成,例如Pod所在主机通信失败等  |

## 7.2.1 pod生命周期的几个阶段
- 1.创建阶段在创建新Pod时  
k8s首先会检查使用的容器镜像是否存在,并检查Pod配置是否正确。如果一切正常,k8s将创建一个名为"Pending"的初始状态  

- 2.运行阶段一旦Pod处于Pending状态  
k8s将开始为它分配资源并启动容器。当所有容器都成功启动后,Pod将进入"Running"状态  

- 3.容器故障恢复阶段在运行期间  
如果某个容器意外终止,则k8s将自动重启该容器。如果该容器无法自动重启,则Pod将进入"Failed"状态  

- 4.更新阶段在进行更新操作时  
k8s首先会通过创建一个新的Pod来实现更新。然后k8s将停止旧Pod中的容器,并将它们迁移到新Pod中。一旦所有容器都成功迁移,旧Pod将被删除,"Rolling Update"完成   

- 5.删除阶段当Pod不再需要时  
可以通过删除Pod对象来释放资源。k8s将删除所有关联的容器,并从集群中删除该Pod对象  
![pod状态的变化4](pic/podphase4.png)  

## 7.2.2 pod生命周期的常见状态
***pod生命周期的几个状态phase值*** 
- Pending挂起：apiServer创建了Pod资源对象并已经存入了etcd中,但是它并未被调度完成,或者仍然处于从仓库下载镜像的过程中  
- Running运行中：pod已被调度到某节点上,且容器都已经被kubelet创建完成。至少有一个容器正处于启动、重启、运行这3个状态中的1个  
- Succeeded成功：Pod中的所有容器都被成功终止,并且不会再重启  
- Failed失败：pod中的所有容器都已终止了,但至少有一个容器是因为失败终止,即容器返回了非0值的退出状态
- Unknown未知：apiServer无法获取得pod对象的状态信息,通常是因为与Pod所在主机网络通信失败  
- Completed 或 Successded：容器内部的进程运行完毕,正常退出,没有发生错误  
- Evicted驱除状态：容器已驱除  
- Terminating终止状态中：这个pod正在被删除,里面的容器正在终止,资源回收、垃圾清理、以及终止过程中需要执行的命令  

![pod状态的变化2](pic/podphase2.png)  

***Pod的生命周期示意图,从图中可以看到Pod状态的变化***  
![Pod状态的变化1](pic/podphase1.png)
![Pod状态的变化3](pic/podphase3.jpeg)

## 7.3 pod创建
k8s中Pod的创建过程是一个多组件协作的流程：  
主要涉及etcd、apiServer、kube-scheduler、kubelet、kube-proxy、ControllerManager、CRI等核心组件  
![pod的创建过程](pic/podcreate1.png)  

**组件协作总结**    
| 组件      | 职责 | 
| --------- | ------- |
| apiServer | 接收请求、验证、持久化数据到etcd,并广播状态变更 |
| scheduler | 资源调度决策，确保Pod分配到最优节点 |
| kubelet   | 在节点执行容器生命周期管理,并与容器运行时、网络/存储插件交互 |
| proxy     | 流量转发与服务发现 |
| etcd      | 存储集群所有资源对象的配置和状态信息,保障数据一致性 |
| CRI       | 运行时接口 |

**<font color=red>Client(请求提交) --> apiServer --> etcd(存储配置) --> Scheduler(调度决策绑定节点) --> etcd --> kubelet(创建容器) --> ContainerRuntime**</font>    

**Pod是k8s的基础单元,pod创建过程**  
1、用户通过kubectl或其他API客户端提交Pod.Spec给APIServer  
2、APIServer尝试将Pod对象的相关信息存储到etcd中,等待写入操作完成,APIServer返回确认信息到客户端  
3、APIServer开始反映etcd中的状态变化  
4、所有的k8s组件通过"watch"机制跟踪检查APIServer上的相关信息变动  
5、kube-scheduler调度器通过其"watcher"检测到APIServer创建了新的Pod对象但是没有绑定到任何工作节点  
6、kube-scheduler为Pod对象挑选一个工作节点并将结果信息更新到APIServer  
7、调度结果新消息由APIServer更新到etcd,并且APIServer也开始反馈该Pod对象的调度结果  
8、Pod被调度到目标工作节点上的kubelet尝试在当前节点上调用docker-engine进行启动容器,并将容器的状态结果返回到APIServer  
9、APIServer将Pod信息存储到etcd系统中  
10、在etcd确认写入操作完成,APIServer将确认信息发送到相关的kubelet  


```mermaid
%%{init:{"theme":"neutral"}}%%
sequenceDiagram
    actor me
    participant apiSrv as 控制面<br><br>api-server
    participant etcd as 控制面<br><br>etcd 数据存储
    participant cntrlMgr as 控制面<br><br>控制器管理器
    participant sched as 控制面<br><br>调度器
    participant kubelet as 节点<br><br>kubelet
    participant container as 节点<br><br>容器运行时
    me->>apiSrv: 1. kubectl create -f pod.yaml
    apiSrv-->>etcd: 2. 保存新状态
    cntrlMgr->>apiSrv: 3. 检查变更
    sched->>apiSrv: 4. 监视未分派的 Pod(s)
    apiSrv->>sched: 5. 通知 nodename=" " 的 Pod
    sched->>apiSrv: 6. 指派 Pod 到节点
    apiSrv-->>etcd: 7. 保存新状态
    kubelet->>apiSrv: 8. 查询新指派的 Pod(s)
    apiSrv->>kubelet: 9. 将 Pod 绑定到节点
    kubelet->>container: 10. 启动容器
    kubelet->>apiSrv: 11. 更新 Pod 状态
    apiSrv-->>etcd: 12. 保存新状态
```
![podcreate](pic/podcreate0.png)    

## 7.4 initContainer初始化容器运行
k8s中的initContainer(初始化容器)是一种在pod主容器启动前运行的专用容器,主要用于完成前置初始化任务  

<details>
  <summary>initContainers构建manContainers的前置工作</summary>
  <pre><code>
--- 
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
  initContainers:
  - name: init-container-1
    image: busybox
    command: ["sh", "-c", "echo Initializing...; sleep 5"]
  - name: init-container-2
    image: alpine
    command: ["sh", "-c", "echo Performing setup...; sleep 10"]
  containers:
  - name: main-container
    image: my-app-image
    # 主应用容器的配置
    # ...
    # ...
  </code></pre>
</details>

![initContainers流程图](pic/initContainers.png)  

## 7.4.1 initContainer的核心特点
* 执行顺序  
  - 一个Pod中可以定义多个initContainers,它们按照顺序执行,只有前一个成功退出(exit 0)后,才会启动下一个  
  - 若某个initContainer失败,k8s会根据restartPolicy决定是否重试(默认不重启)
* initContainer与mainContainer主容器的区别   
  - 目标不同：initContainer负责初始化,主容器运行业务逻辑    
  - 生命周期：initContainer执行完成后立即终止,主容器持续运行  
  - 资源隔离：initContainer可以独立配置资源(CPU/内存)和镜像
              initContainer与应用容器共享存储卷Volumes,但拥有独立文件系统视图,可安全执行敏感操作(如访问Secrets)      
  - initContainer不支持探针startupProbe、livenessProbe、readinessProbe   
* 共享机制    
  - initContainer与mainContainer主容器共享同一Pod的Volume、网络命名空间、但文件系统隔离(除非显式挂载)  

### 7.4.2initContainer初始化容器应用场景
* 依赖服务等待  
  - 供主容器镜像中不具备的工具程序或自定义代码(检查数据库、消息队列等依赖服务是否就绪) 
  - 示例：通过循环调用curl、nc、ping、dig命令等待服务可达
* 配置文件生成  
  - 动态生成主容器所需的配置文件(如从ConfigMap/Secret渲染模板)   
  - 示例：使用envsubst替换环境变量生成应用配置  
* 数据预加载  
  - 从远程存储(如 S3、Git)下载数据到共享Volume    
  - 示例：克隆代码仓库到/app目录供主容器使用  
* 权限初始化  
  - 设置文件系统权限或安全上下文(chmod、chown)  
  - 示例：为共享Volume的目录赋予主容器用户权限   

总的来说,如果有的程序不方便放在主容器,或者需要严格指定先后启动顺序的程序可以放在初始化容器中。

### 7.4.3 initContainer容器执行流程
- 1.Pod 创建  
  * 调度器Scheduler将Pod分配到节点,触发initContainer执行  

- 2.顺序执行  
  * 第一个initContainer启动,完成后退出(状态码需为0)  
  * 后续initContainer依次执行,全部成功后主容器启动  

- 3.失败处理  
  * 若某个InitContainer失败(退出码非0)Pod状态为Init:Error  
  * 根据restartPolicy决定是否重启   
     - Always：自动重启失败的InitContainer(无限重试)  
     - OnFailure：仅当失败时重启(默认策略)  
     - Never：不重启,Pod进入Init:Error状态  

- 4.资源释放  
  * 所有initContainer终止后,其占用的资源(如临时存储)会被释放  
  
### 7.4.4 initContainer的容器作用
**initContainer容器与主容器为分离的单独镜像,其启动相关代码具有如下优势**
- Init容器可以包含一些安装过程中应用容器中不存在的实用工具或个性化代码。
  例如,没有必要仅为了在安装过程中使用类似sed、awk、 python、dig这样的工具而去FROM。一个镜像来生成一个新的镜像。
- Init容器可以安全地运行这些工具,避免这些工具导致应用镜像的安全性降低。
- 应用镜像的创建者和部署者可以各自独立工作,而没有必要联合构建–个单独的应用镜像。
- 它们使用LinuxNamespace,所以对应用容器具有不同的文件系统视图。因此Init容器可具有访问Secrets的权限,而应用容器不能够访问。
- 由于Init容器必须在应用容器启动之前运行完成,因此Init容器提供了一种机制来阻塞或延迟应用容器的启动,直到满足了一组先决条件;一旦前置条件满足,Pod内的所有的应用容器会并行启动。


### 7.4.5 initContainer示例
<details>
  <summary>initContainers-域名解析示例</summary>
  <pre><code>
---
apiVersion: v1
kind: Service
metadata:
  name: my-service-1
spec:
  ports:
   - protocol: TCP
     port: 80
     targetPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: my-service-2
spec:
  ports:
   - protocol: TCP
     port: 80
     targetPort: 8080
---
apiVersion: v1
kind: Pod
metadata:
  name: init-demo
  labels:
    app: init-app
spec:
  containers:
  - name: my-init-demo
    image: fangjiaxiaobai/my-app:v1
    command: ["sh", "-c", "echo the app is running! && sleep 3600"]
  initContainers:
  - name: init-myservice-1
    image: busybox
    command: ['sh', '-c', "until nslookup my-service-1; do echo 'waiting for my-service-1'; sleep 2; done;"]
    #command: ['/bin/sh', '-c', 'until ping 192.168.23.188 -c 1; do echo waiting for mysql; sleep 3; done;']
  - name: init-myservice-2
    image: busybox
    command: ['sh', '-c', "until nslookup my-service-2; do echo 'waiting for my-service-2'; sleep 2; done;"]
    #command: ['/bin/sh', '-c', 'until ping 192.168.23.189 -c 1; do echo waiting for redis; sleep 3; done;']
#验证
kubectl create -f init-demo.yaml
kubectl get pods -w -o wide
kubectl logs -f init-demo -c init-myservice-1
kubectl logs -f init-demo -c init-myservice-2
kubectl logs -f init-demo
Defaulted container "my-init-demo" out of: my-init-demo, init-myservice-1 (init), init-myservice-2 (init)
the app is running!
  </code></pre>
</details>

<details>
  <summary>initContainers-busybox</summary>
  <pre><code>
---
apiVersion: v1
kind: Service
metadata:
  name: myservice
spec:
  selector:
    app: myservice
  ports:
    - port: 80
      targetPort: 9376
      protocol: TCP
---
apiVersion: v1
kind: Service
metadata:
  name: mydb
spec:
  selector:
    app: mydb
  ports:
    - port: 80
      targetPort: 9377
      protocol: TCP
---
apiVersion: v1
kind: Pod
metadata:
  name: initcpod-test
  labels:
    app: initcpod-test
spec:
  containers:
    - name: initcpod-test
      image: busybox:1.32.0
      imagePullPolicy: IfNotPresent
      command: ['sh','-c','echo The app is running! && sleep 3600']
  initContainers:
    - name: init-myservice
      image: busybox:1.32.0
      imagePullPolicy: IfNotPresent
      command: ['sh','-c','until nslookup myservice; do echo waitting for myservice; sleep 2;done;']
    - name: init-mydb
      image: busybox:1.32.0
      imagePullPolicy: IfNotPresent
      command: ['sh','-c','until nslookup mydb; do echo waitting for mydb; sleep 2;done;']
  restartPolicy: Always
#先查看pod启动情况kubectl get pods
#详细查看pod启动情况kubectl describe pod initcpod-test
#查看initcpod-test中的第一个initContainer日志kubectl logs initcpod-test -c init-myservice
#运行init服务kubectl apply -f init.yml
#查看init服务运行情况kubectl get svc
#查看initcpod-test运行情况,需要耐心等一会,会发现pod的第一个init已经就绪kubectl get pods
#查看init-myservice服务运行情况kubectl get svc
#查看initcpod-test运行情况,需要耐心等一会,会发现pod的两个init已经就绪,pod状态为ready
kubectl get pod -w
  </code></pre>
</details>

<details>
  <summary>initContainers-test</summary>
  <pre><code>
#第一个等待myservice启动, 第二个等待mydb启动。 一旦这两个Init容器都启动完成,Pod将启动spec节中的应用容器。
---
apiVersion: v1
kind: Service
metadata:
  name: myservice
spec:
  ports:
  - protocol: TCP
    port: 80
    targetPort: 9376
---
apiVersion: v1
kind: Service
metadata:
  name: mydb
spec:
  ports:
  - protocol: TCP
    port: 80
    targetPort: 9377
---
apiVersion: v1
kind: Pod
metadata:
  name: myapp-pod
  labels:
    app.kubernetes.io/name: MyApp
spec:
  containers:
  - name: myapp-container
    image: busybox:1.28
    command: ['sh', '-c', 'echo The app is running! && sleep 3600']
  initContainers:
  - name: init-myservice
    image: busybox:1.28
    command: ['sh', '-c', "until nslookup myservice.$(cat /var/run/secrets/kubernetes.io/serviceaccount/namespace).svc.cluster.local; do echo waiting for myservice; sleep 2; done"]
  - name: init-mydb
    image: busybox:1.28
    command: ['sh', '-c', "until nslookup mydb.$(cat /var/run/secrets/kubernetes.io/serviceaccount/namespace).svc.cluster.local; do echo waiting for mydb; sleep 2; done"]
#操作过程
kubectl apply -f myapp.yaml
kubectl logs myapp-pod -c init-myservice # 查看第一个Init容器
kubectl logs myapp-pod -c init-mydb      # 查看第二个Init容器
  </code></pre>
</details>

<details>
  <summary>initContainers-生成配置文件</summary>
  <pre><code>
---
apiVersion: v1
kind: Pod
metadata:
  name: myapp-pod
spec:
  initContainers:
    - name: init-service-check
      image: busybox:1.28
      command: ['sh', '-c', 'until nslookup mysql-service; do echo "Waiting for MySQL..."; sleep 2; done']
    - name: init-config-download
      image: alpine/curl
      command: ['curl', '-o', '/app/config.yaml', 'https://config-server/config.yaml']
      volumeMounts:
        - name: app-config
          mountPath: /app
  containers:
    - name: main-app
      image: myapp:1.0
      volumeMounts:
        - name: app-config
          mountPath: /etc/app
  volumes:
    - name: app-config
      emptyDir: {}
#init-service-check：等待MySQL服务的DN 解析可用
#init-config-download：从远程服务器下载配置文件到共享Volume app-config 
#主容器 main-app：使用已下载的配置文件启动应用  
  </code></pre>
</details>

***initContainer总结***  
InitContainer是k8s中实现 启动顺序控制 和 初始化依赖管理 的关键机制   
通过将初始化任务与业务逻辑解耦，显著提升了应用的可靠性和可维护性   
合理使用InitContainer可以避免主容器因依赖未就绪而频繁崩溃,是复杂应用部署的必备工具 

## 7.5 mainContainer主容器运行
在k8s中,Pod是最小的调度和部署单元,包含一个或多个共享网络和存储资源的容器(如主容器、Sidecar容器、Init容器)等  
主容器mainContainer是Pod中运行核心业务逻辑的容器  
![mainContainer](pic/mainContainer0.png)  
[mainContiner详细流程图](https://www.n.cn/search/c66b3f3f93564d4387887f8d9f6dd5a3?fr=none&so_key=0)  

### 7.5.1 mainContainer主容器核心特性
- 容器共享同一网络命名空间(通过localhost通信)   
- 容器共享同一组存储卷Volumes   
- 生命周期统一管理(调度、启动、终止)   

### 7.5.2 mainContainer主容器的核心作用
主容器是Pod中承担核心业务逻辑的容器
- 运行Web服务器Nginx、Apache 
- 执行微服务如SpringBoot、Node.js应用  
- 处理数据任务如Spark、Flink作业  

| 主容器的关键特性  | 说明 |
| --------- | ------- |
| 启动顺序 | 在Init容器全部成功后启动  |
| 生命周期 | 持续运行,直到任务完成或Pod被删除  |
| 资源隔离 | 可独立配置CPU/内存资源(requests和limits)  |
| 健康检查 | 支持探针startupProbe启动探针、livenessProbe就绪探针、readinessProbe存活探针  |
| 日志与监控 | 日志通过标准输出(stdout/stderr)收集,监控通过暴露的指标端点实现  |

### 7.5.3 mainContainer主容器的生命周期管理
- 1.启动流程  
  * Pod调度：由调度器Scheduler分配到合适节点  
  * Init容器执行：Init容器按顺序执行并成功退出  
  * 主容器启动(kubelet与CRI同步状态或上报)  
    - 拉取镜像(若本地不存在)  
    - 挂载Volume(如ConfigMap、Secret、emptyDir)  
    - 执行启动命令(command、args)  
- 2.运行阶段
  * 健康检查  
    - startupProbe: 检查成功才由存活检查接手,用于保护慢启动容器(检测pod内的容器是否已经启动成功并准备好接收流量)  
    - livenessProbe：检测容器是否存活(失败则重启容器)
    - readinessProbe：检测容器是否就绪(失败则从Service的Endpoints移除）
    
  * 资源管理
    - 根据resources.requests和resources.limits限制CPU/内存使用   
    - [k8s三个服务质量类别](https://github.com/gitseen/gitOps/blob/main/k8s/k8s-resource-Qos.md)    
 
- 3.终止流程  
  * 优雅终止(Graceful Shutdown）  
    - 收到SIGTERM信号,执行预设的清理逻辑(如关闭数据库连接)  
    - 默认等待30秒(可配置terminationGracePeriodSeconds)  
  * 强制终止：超时后发送SIGKILL强制终止容器  
    ```bash
    kubectl delete ns ns_name --force --grace-period=0  
    kubectl delete pod pod_name --force --grace-period=0  
    ```
### 7.5.4 mainContainer主容器的配置示例
<details>
  <summary>mainContainer主容器的配置示例</summary>
  <pre><code>
---
apiVersion: v1
kind: Pod
metadata:
  name: myapp-pod
spec:
  initContainers:          # 初始化容器(可选)
    - name: init-config
      image: busybox
      command: ["sh", "-c", "echo 'Initializing...'"]
  containers:             # 主容器(必选)
    - name: main-app      # 主容器名称
      image: nginx:1.25   # 主容器镜像
      command: ["python"]        #覆盖镜像默认命令  （可选）
      args: ["-m", "http.server", "8000"]  #传递参数（可选）
      ports:
        - containerPort: 80
      lifecycle: # 主容器(postStart、preStop;command优先于>initContainers优先于>postStart执行)
        postStart:
          exec:
            command: ['/bin/sh', '-c', 'echo Hello from podStart handler > /usr/share/message']
        preStop:
          exec:
            command: ['/bin/sh', '-c', 'echo Bye from podStop handler']
      resources:          # 主容器(资源限制)
        requests:
          cpu: "100m"
          memory: "128Mi"
        limits:
          cpu: "200m"
          memory: "256Mi"
      startupProbe:      # 主容器(启动探针)
          httpGet:
            path: /login
            port: 8090
          failureThreshold: 30
          periodSeconds: 10
      livenessProbe:      # 主容器(存活探针)
        httpGet:
          path: /healthz
          port: 8080
        initialDelaySeconds: 10  #容器启动后等待10秒开始探测
        periodSeconds: 5         #每5秒检查一次
      readinessProbe:       # 主容器(就绪探针)
        tcpSocket:
          port: 8080
        initialDelaySeconds: 5
        periodSeconds: 10
      env:                  # 主容器(环境变量传递)
        - name: NODE_NAME   # k8s内置环境变量(动态自动注入status.podIP、metadata.name、metadata.namespace、spec.serviceAccountName、spec.nodeNam)  
          valueFrom:
            fieldRef:
              fieldPath: spec.nodeName
        - name: POD_IP
          valueFrom:
            fieldRef:
              fieldPath: status.podIP
        - name: DB_HOST           #引用configMap
          valueFrom: 
            configMapKeyRef
              name: cm-db-config
              key: db.host
        - name: REDIS_HOST           #引用configMap
          valueFrom:
            configMapKeyRef
              name: redis-config
              key: redis-hosts
        - name: DATASOURCE_DBUSER  #引用Secret-DBUSER
          valueFrom:
            secretKeyRef: 
              name: secret-mysql
              key: username 
        - name: DATASOURCE_PASSWD  #引用Secret-DBUSER-PASSSWD
          valueFrom:
            secretKeyRef:
              name: secret-mysql
              key: cipher_password
        - name:  TZ
          value： Asia/Shanghai
        - name: CSE-SERVERURL
          value: https://www.g.cn
      envFrom:  #批量注入:通过envFrom字段将ConfigMap/Secret的所有键值注入为环境变量 
        - configMapRef:
            name: example-configmap
        - secretRef:
            name: example-secret
      volumeMounts:          # 主容器(存储挂载)
        - name: main-app-data
          mountPath: /data
      volumeMounts:
        - name: shared-data
          mountPath: /sidecar-data 
    volumes: #   定义一组挂载设备(宿主机或ConfigMap、Secret、emptyDir)
      - name: volume #定义一个挂载设备的名字
        #meptyDir: {}       
        hostPath:
          path: /opt #挂载设备类型为hostPath,路径为宿主机下的/opt,这里设备类型支持很多种
#主容器频繁重启问题
kubectl get events --field-selector involvedObject.name=<pod-name>
    </code></pre>
</details>

***mainContainer主容器运行总结***  
pod是容器编排的核心单元,主容器是其运行业务逻辑的核心组件。  
主容器与Init容器、Sidecar容器协作,通过共享网络和存储实现高效通信。  
合理配置资源、健康检查和生命周期管理,是保障应用稳定性的关键。

## 7.6 主容器钩子函数
在k8s中Pod的主容器支持生命周期钩子函数(Lifecycle Hooks)用于在容器启动和终止的关键节点触发自定义操作  
![mainContainerHook](pic/Hooks.png)  
[mainContinerHooks详细流程图](https://www.n.cn/search/07c24bf429f44b5eb2f90379ec58e227?fr=none&so_key=0)  

k8s支持钩子函数postStart和preStop为容器提供了更精细的生命周期管理能力  
- postStart  
           于容器创建完成之后立即运行的钩子处理器;在主容器启动后,k8s将立即发送postStart事件  
- preStop  
           容器终止之前执行,执行完成之后容器将成功终止,在其完成之前会阻塞删除容器的操作;在主容器被终结之前,k8s将发送一个preStop事件  

- 钩子函数语法示例  
```bash
kubectl explain pods.spec.containers.lifecycle.postStart.exec.command
kubectl explain pods.spec.containers.lifecycle.postStart.httpGet
kubectl explain pods.spec.containers.lifecycle.postStart.tcpSocket

kubectl explain pods.spec.containers.lifecycle.preStop.exec.command
kubectl explain pods.spec.containers.lifecycle.preStop.httpGet
kubectl explain pods.spec.containers.lifecycle.preStop.tcpSocket
```

- 钩子函数处理实现方法   
  * exec:      在容器内执行命令,如果命令的退出状态码是0表示执行成功,否则表示失败  
  * httpGet:   在当前容器中向指定url发起http请求(URL返回的HTTP状态码在[200、400]之间表示请求成功,否则表示失败)  
  * tcpSocket: 在当前容器尝试访问指定的socket  

### 7.6.1 postStart启动后钩子
**作用**   
- 触发时机：在容器创建后立即执行(与容器的主进程并行启动,而非严格顺序)  
- 目的：执行容器启动后的初始化任务(如配置生成、服务注册、依赖检查等)  

**使用场景**  
- 生成动态配置文件（例如从环境变量渲染模板） 
- 向服务注册中心(如Consul、Etcd)注册服务实例  
- 检查依赖服务(如数据库、缓存)是否可用  
- 初始化日志或监控组件  
  
**注意事项**    
- 执行结果不影响容器状态:即使postStart钩子执行失败,容器仍会被标记为Running  
- 超时处理：如果钩子未在指定时间内完成(默认无超时),容器可能继续运行但钩子任务被终止  
- 与Init容器的区别：postStart在主容器启动后触发,而Init容器在主容器启动前运行  
  

### 7.6.2 preStop钩子
**作用**   
- 触发时机：在容器终止前执行(收到SIGTERM信号后,但在强制终止前)  
- 目的：执行优雅关闭逻辑(如保存状态、清理资源、通知其他服务)  
  
**使用场景**  
- 向服务注册中心注销服务实例   
- 等待正在处理的请求完成(例如睡眠30秒)   
- 保存内存中的缓存数据到持久化存储  
- 关闭数据库连接或释放文件锁  
  
**注意事项** 
- 必须快速完成: preStop 钩子的执行时间应远小于 terminationGracePeriodSeconds(默认30秒),否则容器会被强制终止  
- 幂等性设计：确保钩子任务可重复执行(避免因重试导致副作用)  
- 依赖外部服务的风险: 如果钩子需要调用外部API需考虑网络不可用的情况  


### 7.6.3 钩子示例 
<details>
  <summary>commandline-postStart-exec测试示例</summary>
  <pre><code>
---
apiVersion: v1
kind: Pod
metadata:
  name: nginx-test-post-start
spec: 
  containers:
  - name: main-container
    image: nginx
    command: ["/bin/sh", "-c"]
    args: ["echo $(date +'%Y-%m-%d %H:%M:%S.%3N') ' :container command started!!!' >> /var/log/testlog.log; nginx -g 'daemon off;'"]
    lifecycle:
      postStart: 
        exec:   
          command:  
            - sh
            - -c
            - echo $(date +'%Y-%m-%d %H:%M:%S.%3N') " :postStart done!!!" >> /var/log/testlog.log
          #command: ["/bin/sh", "-c","echo $(date +'%Y-%m-%d %H:%M:%S.%3N') ':postStart done!!!' >> /var/log/testlog.log"]
  
#容器启动命令和postStart都会写入1条信息入指定的log
kubectl exec -it nginx-test-post-start -c main-container -- /bin/bash
cat /var/log/testlog.log 
2024-03-31 18:14:15.797  :container command started!!!
2024-03-31 18:14:15.821  :postStart done!!!
实际log上看到, commandline执行的时间比postStart更早, 虽然只有几毫秒的区别
  </code></pre>
</details>


<details>
  <summary>postStart-preStop-exec</summary>
  <pre><code>
apiVersion: v1
kind: Pod
metadata:
  name: lifecycle-demo
spec:
  containers:
    - name: app
      image: myapp:1.0
      ports:
        - containerPort: 8080
      lifecycle:
        postStart:
          exec:
            command: ["/bin/sh", "-c", "echo 'App started' > /app/status.txt"]
      lifecycle:
        postStart: 
          exec: # 在容器启动的时候执行一个命令,修改掉nginx的默认首页内容
            command: ["/bin/sh", "-c", "echo postStart... > /usr/share/nginx/html/index.html"]
        preStop:
          exec:
            command: ["/bin/sh", "-c", "curl -X POST http://localhost:8080/stop && sleep 30"]
        preStop:
        exec: # 在容器停止之前停止nginx服务
          command: ["/usr/sbin/nginx","-s","quit"]
      terminationGracePeriodSeconds: 60
  </code></pre>
</details>


<details>
  <summary>钩子处理器支持使用下面三种方式定义动作</summary>
  <pre><code>

* Exec命令  #在容器内执行一次命令
```
lifecycle:
    postStart: 
      exec:
        command:
        - cat
        - /tmp/healthy
```

* TCPSocket #在当前容器尝试访问指定的socket
```
lifecycle:
    postStart:
      tcpSocket:
        port: 8080
```

* HTTPGet   #在当前容器中向某url发起http请求  
```
lifecycle:
    postStart:
      httpGet:
        path: / #URI地址
        port: 80 #端口号
        host: 192.168.5.3 #主机地址
        scheme: HTTP #支持的协议,http或者https
```
  </code></pre>
</details>


**钩子函数总结**
- PostStart hook是在容器创建(created)之后立马被调用,并且PostStart跟容器的ENTRYPOINT是异步执行的,无法保证它们之间的顺序
- PreStop hook是容器处于Terminated状态时立马被调用(也就是说要是Job任务的话,执行完之后其状态为completed,所以不会触发PreStop的钩子),同时PreStop是同步阻塞的,PreStop执行完才会执行删除Pod的操作
- PostStart会阻塞容器成为Running状
- PreStop会阻塞容器的删除,但是过了terminationGracePeriodSeconds时间后,容器会被强制删除

>postStart和preStop是k8s中管理容器生命周期的重要工具    
>>postStart: 初始化任务(非关键路径)  
>>preStop: 优雅关闭(关键路径,必须可靠)  
>核心价值: 通过自定义逻辑增强应用的可观测性和健壮性,确保服务平滑启停  


## 7.7 主容器健康检测(三种探针)  
在k8s中,健康检查(Health Checks)是确保容器应用可靠运行的核心机制   
启动探针(StartupProbe)、就绪探针(readinessProbe)、存活探针(livenessProbe)健康检测是检查容器里面的服务是否正常 
 
![mainContainer-health-Probe](pic/healthProbe.png)  
[mainContiner-health-Probe详细流程图](https://www.n.cn/search/9315b5209e2448e0b5447c8531c14b43?fr=none&so_key=0)  

### 7.7.1  主容器健康检测作用  

| 探针类型  | 触发时机 |  失败后果 |   典型场景  | 说明  |
| --------- | ------- |  ------- |    -------  |  -------  |
| startupProbe   | 容器启动后立即检测 | 若失败,持续重试直到成功或超时 | 保护启动慢的应用(Java),避免被存活探针误杀           | 关注启动阶段,避免误杀初始化慢的应用 |
| readinessProbe | 容器启动后周期检测 | 从Service的Endpoints中移除Pod | 等待依赖项(如数据库)就绪,避免流量涌入未准备好的容器 | 关注服务可用性,失败暂停流量 |
| livenessProbe  | 容器启动后周期检测 | 重启容器(根据restartPolicy)   | 检测死锁、内存泄漏等不可恢复的故障        | 关注容器存活状态,失败触发重启  |

- startupProbe启动探针  
  * 检查成功才由存活检查接手,用于保护慢启动容器    
  * 适用于需要较长启动时间的应用场景,如应用程序需要大量预热或者需要等待外部依赖组件的应用程序  
  
- readinessProbe就绪探针
  * 如果检查失败,k8s会把Pod从serviceEndpoints中剔除(Pod的IP:Port从对应Service关联的EndPoint地址列表中删除)
  * 用于检测应用实例当前是否可以接收请求,如果不能,k8s不会转发流量;决定是否对外提供服务(决定是否将请求转发给容器)  

- livenessProbe存活探针 
   * 如果检查失败,kubelet会杀死容器,根据pod的restartPolicy来操作    
   * 用于检测应用实例是否处于Running状态,如果不是,k8s会重启容器;决定是否重启容器   

**startupProbe > readinessProbe > livenessProbe**  

>如定义startupProbe、livenessProbe或者startupProbe、readinessProbe,则只有startupProbe探测成功后,才执行livenessProbe、readinessProbe探针


[pod容器重启策略](https://blog.csdn.net/junbaozi/article/details/127077046)  
Always:当容器终止退出,总是重启容器,默认策略  
OnFailure:当容器异常退出(退出状态码非0)时,才重启容器  
Never:当容器终止退出,从不重启容器  

**restartPolicy**  
podS.pec中的restartPolicy可以用来设置是否对退出的Pod重启,可选项包括Always、OnFailure、Never  
```bash
kubectl explain pods.sepc.restartPolicy
kubectl get pod podname -oyaml |grep restartPolicy
```

- 单容器的Pod,容器成功退出时,不同restartPolicy时的动作为  
   * Always: 重启Container; Pod phase保持Running  
   * OnFailure: Pod phase变成Succeeded  
   * Never: Pod phase变成Succeeded  

- 单容器的Pod,容器失败退出时,不同restartPolicy时的动作为  
  * Always: 重启Container; Pod phase保持 Running  
  * OnFailure: 重启Container; Pod phase保持 Running  
  * Never: Pod phase变成Failed  
  
- 2个容器的Pod,其中一个容器在运行而另一个失败退出时,不同restartPolicy时的动作为  
  * Always: 重启Container; Pod phase保持Running  
  * OnFailure: 重启Container; Pod phase保持Running  
  * Never: 不重启Container; Pod phase保持Running  

- 2个容器的Pod,其中一个容器停止而另一个失败退出时,不同restartPolicy时的动作为  
  * Always: 重启Container; Pod phase保持Running  
  * OnFailure: 重启Container; Pod phase保持Running  
  * Never: Pod phase变成Failed  
  
- 单容器的Pod,容器内存不足(OOM),不同restartPolicy时的动作为  
  * Always: 重启Container; Pod phase保持Running  
  * OnFailure: 重启Container; Pod phase保持Running  
  * Never: 记录失败事件; Pod phase变成Failed  

- Pod还在运行,但磁盘不可访问时  
  * 终止所有容器Pod phase变成Failed  
  * 如果Pod是由某个控制器管理的,则重新创建一个Pod并调度到其他Node运行   

- Pod还在运行,但由于网络分区故障导致Node无法访问   
  * Node controller等待Node事件超时  
  * Node controller将Pod phase设置为Failed  
  * 如果Pod是由某个控制器管理的,则重新创建一个Pod并调度到其他Node运行 


### 7.7.2  探针配置参数
>所有探针支持以下通用参数   
- initialDelaySeconds：容器启动后等待多少秒开始探测(默认0)   
  * 容器启动后要等待多少秒后才启动startupProbe、livenessProbe、readinessProbe探针   
  * 如定义了starupProbe成功之后才开始执行livenessProbe、readinessProbe  
  * 如periodSeconds的值大于initialDelaySeconds,则initialDelaySeconds将被忽略;默认是0秒,最小值是0  

- periodSeconds：探测周期(默认10)   
  * 执行探测的时间间隔(单位是秒);默认是10秒,最小值是1  

- timeoutSeconds：探测超时时间(默认1)   
  * 探测超时后等待多少秒;默认值是1秒,最小值是1  

- successThreshold：连续成功次数视为探测成功(默认1)  
  * 探针在失败后,被视为成功的最小连续成功数;默认值是1,最小值是1  
  * startupProbe、livenessProbe探测参数值必须是1  

- failureThreshold：连续失败次数视为探测失败(默认3)  
  * 探针连续失败了failureThreshold次之后, k8s认为总体上检查已失败:容器状态未就绪、不健康、不活跃   
  * 对于startupProbe、livenessProbe而言,如至少有一个failureThreshold失败, k8s会将容器视为不健康并触发重启操作,kubelet遵循该容器的terminationGracePeriodSeconds   
  * 对于失败的readinessProbe探针,kubelet继续运行检查失败的容器,并继续运行更多探针; 因为检查失败,kubelet将Pod的Ready状况设置为false  

>terminationGracePeriodSeconds  
为kubelet配置从为失败的容器触发终止操作到强制容器运行时停止该容器之前等待的宽限时长    
默认值是继承Pod级别的terminationGracePeriodSeconds值;如果不设置则为30秒,最小值为1     

***探针语法***  
```bash
kubectl explain pods.spec.containers.startupProbe
kubectl explain pods.spec.containers.readinessProbe
kubectl explain pods.spec.containers.livenessProbe

kubectl explain pods.spec.containers.startupProbe.initialDelaySeconds
kubectl explain pods.spec.containers.startupProbe.tcpSocket
....

```
***探针参数***  

| 参数名称  | 默认值 |  最小值 |   描述  |
| --------- | ------- |  ------- |    -------  |
| initialDelaySeconds | 0秒  |  0秒 | 容器启动后多久开始进行第一次探测 |
| periodSeconds  | 10秒  |  1秒 | 探测频度,频率过高会对pod带来较大的额外开销,频率过低则无法及时反映容器真实情况  |
| timeoutSeconds | 1秒   |  1秒 | 探测超时时间 |
| successThreshold | 1   |  1 | 处于失败状态时,探测连续成功几次,被认为成功 |
| failureThreshold | 3   |  1 | 处于成功状态时,探测连续失败几次可被认为失败 |
| terminationGracePeriodSeconds | 1 |  1 | 宽限时间 与kubectl explain pods.spec.terminationGracePeriodSeconds有区别 |
| exec |    |   | 在容器内部执行执行Shell命令 |
| grpc |    |   | 发起一个grpc请求 |
| httpGet |    |   | 发起HTTP请求 监听接口,属于七层 |
| tcpSocket |    |   | 发起tpcSocket请求 监听端口,属于四层|
```bash
initialDelaySeconds: 5  #容器启动多久后开始去执行当前探针
periodSeconds: 5        #每隔多久去执行一次探针
successThreshold: 1     #至少探针执行多少次过后才会被认为是真正的成功
failureThreshold: 3     #执行失败多少次过后才会被认为是真正的失败

timeoutSeconds：#探测超时时间,默认1秒,最小1秒
successThreshold：#探测失败后,最少连续探测成功多少次才会被认定为成功,默认是1,但是如果是liveness则必须是1,最小值1
failureThreshold：#探测成功后,最少连续探测失败多少次才会被认定为失败,默认是3,最小值是1  #尽量设置大(30)
```

### 7.7.3  探针检测方式与检测结果
容器探测是pod对象生命周期中的一项重要的日常任务,它是kubelet对容器周期性执行的健康状态诊断,诊断操作由容器的处理器进行定义  

***探针检测方式***  

* exec:  在容器内部执行执行Shell命令返回状态码是0为成功  
  - 执行Shell命令返回状态码是0为成功  
  - ExecAction(执行命令)在容器内执行命令,若退出码为0则视为成功 
  - 适用场景：自定义脚本检查(如检查文件是否存在、进程状态等)  

* httpGet:  对容器的IP地址、端口号及路径发起HTTP请求,返回>=200且<400范围状态码为成功  
  - 发起HTTP请求,返回200-400范围状态码为成功  
  - 向容器IP发送httpGet请求,响应状态码为>=200且<400成功   
  - 适用场景：Web服务健康检查(如/healthz端点)  

* tcpSocket:  对容器的IP地址、端口号执行TCP检查,如果能够建立TCP连接,则表明容器成功   
  - 尝试与容器指定端口建立TCP连接,若连接成功视为健康  
  - 适用场景：非HTTP服务(如数据库、Redis)  
  
* grpc:   对容器的IP地址、端口发起一个grpc请求(前提是服务实现了grpc健康检查协议),返回响应的状态是SERVING则认为诊断成功  
          使用gRPC执行一个远程过程调用。目标应该实现gRPC健康检查;如果响应的状态是 "SERVING"则认为诊断成功

***探针执行者***   
execAction(借助容器运行时执行)  
tcpSocketAction(由kubelet直接检测)  
httpGetAction(由kubelet直接检测)  
grpc(由grpc健康检查协议检测)  

***探针结果***  
Success(成功)：容器通过了诊断  
Failure(失败)：容器未通过诊断   
Unknown(未知)：诊断失败,因此不会采取任何行动  


### 7.7.4  主容器健康检测示例

<details>
  <summary>startupProbe示例</summary>
  <pre><code> 
#startupProbe(启动探针)保护慢启动容器
有一种情景是这样的,某些应用在启动时需要较长的初始化时间。要这种情况下,若要不影响对死锁作出快速响应的探测,设置存活探测参数是要技巧  
技巧就是使用相同的命令来设置启动探测,针对HTTP或TCP检测,可以通过将failureThreshold * periodSeconds参数设置为足够长的时间来应对糟糕情况下的启动时间 
---
apiVersion: v1
kind: Namespace
metadata:
  name: test-a
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: goweb-demo
  namespace: test-a
spec:
  replicas: 10
  selector:
    matchLabels:
      app: goweb-demo
  template:
    metadata:
      labels:
        app: goweb-demo
    spec:
      containers:
      - name: goweb-demo
        image: 192.168.11.247/web-demo/goweb-demo:20221229v3
        livenessProbe:   #定义探测机制
          httpGet:       #探测方式为httpGet
            scheme: HTTP ##指定协议
            path: /login #指定路径下的文件，如果不存在，探测失败
            port: 8090   
          initialDelaySeconds: 10 #当容器运行多久之后开始探测(单位是s) 
          failureThreshold: 1     #探测失败的重试次数
          periodSeconds: 5       ##探测频率(单位s),每隔5秒探测一次
        startupProbe:
          httpGet:
            path: /login
            port: 8090
          failureThreshold: 30
          periodSeconds: 10
---
apiVersion: v1
kind: Service
metadata:
  name: goweb-demo
  namespace: test-a
spec:
  ports:
  - port: 80
    protocol: TCP
    targetPort: 8090
  selector:
    app: goweb-demo
  type: NodePort

#注 应用程序将会有最多5分钟(30 * 10 = 300s)的时间来完成其启动过程
     一旦启动探测成功一次,存活探测任务就会接管对容器的探测,对容器死锁作出快速响应
     如果启动探测一直没有成功,容器会在300秒后被杀死,并且根据restartPolicy来执行进一步处置
 </code></pre>
</details>

 
<details>
  <summary>livenessProbe-exec</summary>
  <pre><code>
#livenessProbe(存活探针):使用exec的方式(执行Shell命令返回状态码是0则为成功) 
---
apiVersion: v1
kind: Namespace
metadata:
  name: test-a
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: goweb-demo
  namespace: test-a
spec:
  replicas: 10
  selector:
    matchLabels:
      app: goweb-demo
  template:
    metadata:
      labels:
        app: goweb-demo
    spec:
      containers:
      - name: goweb-demo
        image: 192.168.11.247/web-demo/goweb-demo:20221229v3
        livenessProbe:
          exec:
            command:
            - ls
            - /opt/goweb-demo/runserver
            #command: ["/bin/ls","/opt/goweb-demo/runserver"]  
          initialDelaySeconds: 5
          periodSeconds: 5
---
apiVersion: v1
kind: Service
metadata:
  name: goweb-demo
  namespace: test-a
spec:
  ports:
  - port: 80
    protocol: TCP
    targetPort: 8090
  selector:
    app: goweb-demo
  type: NodePort
#注 periodSeconds字段指定了kubelet应该每5秒执行一次存活探测
    initialDelaySeconds字段告诉kubelet在执行第一次探测前应该等待5秒
    kubelet在容器内执行命令 ls /opt/goweb-demo/runserver来进行探测;如果命令执行成功并且返回值为0,kubelet就会认为这个容器是健康存活的。 
                                                                 如果这个命令返回非0值,kubelet会杀死这个容器并重新启动它
#验证存活检查的效果
1.查看某个pod的里的容器,
kubectl get pods goweb-demo-686967fd56-556m9 -n test-a -o jsonpath={.spec.containers[*].name}
2.进入某个pod里的容器
kubectl exec -it goweb-demo-686967fd56-556m9 -c goweb-demo -n test-a -- bash
3.进入容器后,手动删除掉runserver可执行文件,模拟故障
rm -rf /opt/goweb-demo/runserver
4.查看Pod详情(在输出结果的最下面,有信息显示存活探针失败了,这个失败的容器被杀死并且被重建了。)
kubectl describe pod goweb-demo-686967fd56-556m9 -n test-a
Events:
  Type     Reason     Age                   From     Message
  ----     ------     ----                  ----     -------
  Warning  Unhealthy  177m (x6 over 3h59m)  kubelet  Liveness probe failed: ls: cannot access '/opt/goweb-demo/runserver': No such file or directory
5.一旦失败的容器恢复为运行状态,RESTARTS 计数器就会增加 1
tantianran@test-b-k8s-master:~$ kubectl get pods -n test-a
NAME                          READY   STATUS    RESTARTS      AGE
goweb-demo-686967fd56-556m9   1/1     Running   1 (22s ago)   13m # RESTARTS字段加1,
goweb-demo-686967fd56-8hzjb   1/1     Running   0             13m
  </code></pre>
</details>


<details>
  <summary>livenessProbe-httpGet</summary>
  <pre><code>
#livenessProbe(存活探针):使用httpGet请求的方式检查uri path是否正常  
---
apiVersion: v1
kind: Namespace
metadata:
  name: test-a
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: goweb-demo
  namespace: test-a
spec:
  replicas: 10
  selector:
    matchLabels:
      app: goweb-demo
  template:
    metadata:
      labels:
        app: goweb-demo
    spec:
      containers:
      - name: goweb-demo
        image: 192.168.11.247/web-demo/goweb-demo:20221229v3
        livenessProbe:
          httpGet:
            path: /login
            port: 8090
            httpHeaders:
            - name: Custom-Header
              value: Awesome
          initialDelaySeconds: 3
          periodSeconds: 3
---
apiVersion: v1
kind: Service
metadata:
  name: goweb-demo
  namespace: test-a
spec:
  ports:
  - port: 80
    protocol: TCP
    targetPort: 8090
  selector:
    app: goweb-demo
  type: NodePort
#注:在这个配置文件中Pod定义 periodSeconds字段指定了kubelet每隔3秒执行一次存活探测
                             initialDelaySeconds字段告诉kubelet在执行第一次探测前应该等待3秒
                             kubelet会向容器内运行的服务(服务在监听8090端口)发送一个HTTP GET请求来执行探测。 如果服务器上/login路径下的处理程序返回成功代码,则kubelet认为容器是健康存活的
                             如果处理程序返回失败代码,则kubelet会杀死这个容器并将其重启。返回大于或等于200并且小于400的任何代码都表示成功,其它返回代码都表示失败。
#验证效果
1. 进入容器删除静态文件,模拟故障
kubectl exec -it goweb-demo-586ff85ddb-4646k -c goweb-demo -n test-a -- bash
rm -rf login.html
2. 查看pod的log
kubectl logs goweb-demo-586ff85ddb-4646k -n test-a
2023/01/12 06:45:19 [Recovery] 2023/01/12 - 06:45:19 panic recovered:
GET /login HTTP/1.1
Host: 10.244.222.5:8090
Connection: close
Accept: */*
Connection: close
Custom-Header: Awesome
User-Agent: kube-probe/1.25
html/template: "login.html" is undefined
/root/my-work-space/pkg/mod/github.com/gin-gonic/gin@v1.8.2/context.go:911 (0x8836d1)
/root/my-work-space/pkg/mod/github.com/gin-gonic/gin@v1.8.2/context.go:920 (0x88378c)
/root/my-work-space/src/goweb-demo/main.go:10 (0x89584e)
3. 查看pod详情
kubectl describe pod goweb-demo-586ff85ddb-4646k -n test-a
Warning  Unhealthy  34s (x3 over 40s)   kubelet            Liveness probe failed: HTTP probe failed with statuscode: 500 # 状态码为500
4. 恢复后查看Pod,RESTARTS计数器已经增1
kubectl get pod goweb-demo-586ff85ddb-4646k -n test-a
NAME                          READY   STATUS    RESTARTS      AGE
goweb-demo-586ff85ddb-4646k   1/1     Running   1 (80s ago)   5m39s
  </code></pre>
</details>

  
<details>
  <summary>readinessProbe-tcpSocket示例</summary>
  <pre><code>
#readinessProbe(就绪探针)结合livenessProbe(存活探针)探测tcp端口  
存活探测是使用TCP套接字,使用这种配置时kubelet会尝试在指定端口和容器建立套接字链接。 如果能建立连接,这个容器就被看作是健康的,如果不能则这个容器就被看作是有问题的
---
apiVersion: v1
kind: Namespace
metadata:
  name: test-a
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: goweb-demo
  namespace: test-a
spec:
  replicas: 10
  selector:
    matchLabels:
      app: goweb-demo
  template:
    metadata:
      labels:
        app: goweb-demo
    spec:
      containers:
      - name: goweb-demo
        image: 192.168.11.247/web-demo/goweb-demo:20221229v3
        readinessProbe:
          tcpSocket:
            port: 8090
          initialDelaySeconds: 5
          periodSeconds: 10
        livenessProbe:
          tcpSocket:
            port: 8090
          initialDelaySeconds: 15
          periodSeconds: 20
---
apiVersion: v1
kind: Service
metadata:
  name: goweb-demo
  namespace: test-a
spec:
  ports:
  - port: 80
    protocol: TCP
    targetPort: 8090
  selector:
    app: goweb-demo
  type: NodePort
#注:TCP检测的配置和HTTP检测非常相似。 这个例子同时使用就绪和存活探针
            kubelet会在容器启动5秒后发送第一个就绪探针。 探针会尝试连接goweb-demo容器的8090端口
            如果探测成功则Pod会被标记为就绪状态,kubelet将继续每隔10秒运行一次探测。除了就绪探针,这个配置包括了一个存活探针
            kubelet会在容器启动15秒后进行第一次存活探测。与就绪探针类似,存活探针会尝试连接goweb-demo容器的8090端口。如果存活探测失败,容器会被重新启动
#验证效果
1. 进入容器后,杀掉goweb-demo的进程
kubectl exec -it goweb-demo-5d7d55f846-vm2kc -c goweb-demo -n test-a -- bash
root@goweb-demo-5d7d55f846-vm2kc:/opt/goweb-demo# ps -aux
USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root           1  0.0  0.0   2476   576 ?        Ss   07:23   0:00 /bin/sh -c /opt/goweb-demo/runserver
root@goweb-demo-5d7d55f846-vm2kc:/opt/goweb-demo# kill -9 1
2. 查看pod详情,已经发出警告
kubectl describe pod goweb-demo-5d7d55f846-vm2kc -n test-a
  Warning  Unhealthy  16s                 kubelet            Readiness probe failed: dial tcp 10.244.240.48:8090: connect: connection refused
  Warning  BackOff    16s                 kubelet            Back-off restarting failed container
3. 查看pod,RESTARTS计数器已经增加为2,因为有两个探针
kubectl get pod -n test-a
NAME                          READY   STATUS    RESTARTS        AGE
goweb-demo-5d7d55f846-vm2kc   1/1     Running   2 (2m55s ago)   12m
  </code></pre>
</details> 

<details>
  <summary>startupProbe-readinessProbe-livenessProbe混合使用示例</summary>
  <pre><code>
---
apiVersion: v1
kind: Service
metadata:
  name: rlprobe
  labels:
    app: rlprobe
spec:
  type: NodePort
  ports:
  - name: server
    port: 8080
    targetPort: 8080
    nodePort: 32280
  - name: managerment
    port: 8081
    targetPort: 8081
    nodePort: 32281
  selector:
    app: rlprobe
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: rlprobe
  labels:
    app: rlprobe
spec:
  replicas: 1
  selector:
    matchLabels:
      app: rlprobe
  template:
    metadata:
      name: rlprobe
      labels:
        app: rlprobe
    spec:
      containers:
      - name: rl
        image: mydlqclub/springboot-helloworld:0.0.1
        imagePullPolicy: IfNotPresent
        ports:
        - name: server
          containerPort: 8080
        - name: managerment
          containerPort: 8081
        startupProbe:
          tcpSocket:
           port: 8080  #这里故意写错端口，为了验证探测失败后pod是否重启
          initialDelaySeconds: 5 #容器启动后多久开始探测
          periodSeconds: 10   #检查的间隔时间
          timeoutSeconds: 10  #探针执行检测请求后,等待响应的超时时间
          successThreshold: 1 #探测成功多少次才算成功
          failureThreshold: 3 #探测失败多少次才算失败
        readinessProbe:
          httpGet:
            scheme: HTTP
            port: 8081
            path: /actuator/health
          initialDelaySeconds: 20
          periodSeconds: 5
          timeoutSeconds: 10
        livenessProbe:
          httpGet:
            scheme: HTTP
            port: 8081
            path: /actuator/health
          initialDelaySeconds: 20
          periodSeconds: 5
          timeoutSeconds: 10
#说明：查看pod的Events信息,通过探测，可以知道pod是不健康的,且http访问失败。它会不断重启,而且会将pod设置为不可用的状态,直到重启之后探测成功会将pod状态设置为ready。
  </code></pre>
</details> 

<details>
  <summary>Pod的生命周期-示例</summary>
  <pre><code>
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: pod-hook-exec
spec:
  replicas: 1
  selector:
    matchLabels:
     app: pod-hook-exec
  template:
    metadata:
      labels:
        app: pod-hook-exec
    spec:
      terminationGracePeriodSeconds: 5 #设置5秒宽限时间,默认是30s
      nodeName: local-168-182-110 #指定调度机器
      initContainers:
      - name: init-containers
        image: busybox
        command: ["sh","-c","echo init-containers...|tee -a /tmp/pod-hook-exec.log;sleep 5s"]
        volumeMounts:
        - name: logs
          mountPath: /tmp/pod-hook-exec.log
          subPath: pod-hook-exec.log
      containers:
      - name: main-container
        image: busybox
        command: ["sh","-c","echo main-container...|tee -a /tmp/pod-hook-exec.log;sleep 3600s"] #只有这个才会输出到屏幕,也就是通过logs只能查看主容器日志
        volumeMounts:
        - name: logs
          mountPath: /tmp/pod-hook-exec.log
          subPath: pod-hook-exec.log
        startupProbe:
          exec:
            command: ["sh","-c","echo startupProbe...|tee -a /tmp/pod-hook-exec.log;sleep 5s"]
          timeoutSeconds: 10
        livenessProbe:
          exec:
            command: ["sh","-c","echo livenessProbe...|tee -a /tmp/pod-hook-exec.log;sleep 5s"]
          timeoutSeconds: 10
        readinessProbe:
          exec:
            command: ["sh","-c","echo readinessProbe...|tee -a /tmp/pod-hook-exec.log;sleep 5s"]
          timeoutSeconds: 10
        lifecycle:
          postStart:
            exec: #在容器启动的时候执行一个命令
              command: ["sh","-c","echo postStart...|tee -a /tmp/pod-hook-exec.log;sleep 5s"]
          preStop: # 在pod停止之前执行
            exec:
              command: ["sh","-c","echo preStop...|tee -a /tmp/pod-hook-exec.log"]
      volumes:
      - name: logs #和上面保持一致 这是本地的文件路径，上面是容器内部的路径
        hostPath:
          path: /opt/k8s/test/
  </code></pre>
</details>

![Pod的生命周期-示例](pic/podlife00.png)  
从上图的日志就可看出,被分为6个执行阶段;执行的先后顺序：   

**<font color=red>initContainers --> mainContainer --> postStart --> startupProbe --> readinessProbe --> livenessProbe --> preStop</font>**       
>main-container和postStart是同时执行,虽然readinessProbe和livenessProbe也是同时执行,但是他们不是真正的并行执行,也有先后顺序的   

[探针-路多辛](https://www.toutiao.com/article/7206670428587164192/)  
[kubernetes官方文档](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/)   
[探针介绍](https://blog.csdn.net/weixin_39941298/article/details/137277508)

**健康检测(三种探针)总结**  
通过合理配置三种探针,可以实现   
- 启动保护：避免慢启动应用被误杀StartupProbe 
- 流量控制：确保只有就绪的Pod接收请求readinessProbe 
- 高可用性：快速恢复故障容器livenessProbe  

## 7.8 pod终止过程
**pod终止(删除)过程**   
1、用户向apiserver发送删除pod对象的命令  
2、apiserver中的pod对象信息会随着时间的推移而更新,在宽限期内(默认30s,spec.terminationGracePeriodSeconds),pod被视为dead  
3、将pod标记为terminating(正在删除)状态  
4、kubelet在监控到pod对象转为terminating状态的同时就会启动pod关闭过程  
5、endpoint控制器监控到pod对象的关闭行为时将其从所有匹配到此endpoint的svc资源endpoint列表中删除  
6、如果当前pod对象定义了preStop钩子处理器,则在其被标记为terminating后会意同步的方式启动执行  
7、pod对象中的容器进程收到停止信号  
8、宽限期结束后,若pod中还存在运行的进程,kubelet向容器发送SIGKILL信号,强制关闭容器进程   
9、kubelet请求apiServer将此pod资源的宽限期设置为0,从而完成删除操作,此时pod对用户已不可见  
![pod删除流程1](pic/poddel1.png)  

![pod删除流程2](pic/poddel2.png)  

![pod终止过程](pic/podstop.png)  

**删除pod时有两条平行的时间线。一条是改变网络规则,一条是删除pod**     
- 1、网络规则生效  
apiserver接收到pod删除请求,将pod在Etcd中的状态更新为Terminating  
EndpointController从Endpoint对象中删除pod的IP  
kuber-proxy根据Endpoint对象的变化更新iptables的规则,不再将流量路由到被删除的Pod  

- 2、删除pod  
apiserver接收到Pod删除请求,将Pod在Etcd中的状态更新为terminating  
preStop钩子被执行  
kubelet向容器发送SIGTERM   
继续等待,直到容器停止,或者超时spec.terminationGracePeriodSeconds默认30s  
如果超过了spec.terminationGracePeriodSeconds容器仍然没有停止,k8s将会发送SIGKILL信号给容器,强制关闭容器进程  
Pod被终止,处于terminating状态  
k8s删除Pod相关资源:如网络配置、数据卷等  

![pod删除过程](pic/poddel0.png)  


## 7.9 pod状态

在k8s中Pod的状态(PodStatus)反映了其生命周期中的不同阶段和运行情况  

![podstatus](pic/podstatus.png)

### 7.9.1 Pod详细的状态说明       
| 状态    | 描述 | 
| :-------- | :----- |
| CrashLoopBackOff  | 容器异常退出,kubelet正在将它重启  |
| CreateContainerConfigError  | 不能创建kubelet使用的容器配置  |
| CreateContainerError  |  创建容器失败 |
| CreateContainerConfigError | 不能创建kubelet使用的容器配置  |
| Completed | 容器内部的进程运行完毕,正常退出,没有发生错误  |
| ContainersNotInitialized  | 容器没有初始化完毕  |
| ContainersNotReady	  | 容器没有准备完毕  |
| ContainerCreating	  | Pod正在创建中  |
| ContainersReady | 表示Pod中的所有容器是否已经准备就绪  |
| DockerDaemonNotReady   | docker还没有完全启动  |
| Evicted  | 被驱除 |
| Error    | Pod启动过程中发生错误,配置错误或其他问题无法启动 |
| ErrImageNeverPull  | 策略禁止拉取镜像,镜像中心权限是私有等  |
| ErrImagePull	  |  镜像拉取出错,超时或下载被强制终止 |	
| NetworkPluginNotReady  | 网络插件还没有完全启动  |
| NodeLost               | Pod所在节点失联 |
| ImageInspectError  | 无法校验镜像,镜像不完整导致  |
| ImagePullBackOff	  |  镜像拉取失败,但是正在重新拉取 |
| Initialized | 表示Pod中的所有容器是否已经初始化  |
| Initializing | Pod正在初始化中 |
| InvalidImageName | node节点无法解析镜像名称,导致镜像无法下载  |
| Outofcpu         | 0/4 nodes are available: 1 Insufficient memory , 3 Insufficient cpu |
| Pending          | Pending(挂起),Pod等待被调度、未调度到节点上或正在下载镜像 |
| PreStartContainer |  执行preStarthook报错 |
| PostStartHookError  | 执行postStart-hook报错  |
| PodScheduled  | 表示Pod是否已经被调度到了节点上  |
| PodInitializing  | pod初始化中  |
| RunContainerError | Pod运行失败,容器中没有初始化PID为1的守护进程等  |
| Ready   | Pod是否已经准备就绪,即所有容器都已经启动并且可以接收流量|
| RegistryUnavailable | 连接不到镜像中心  |
| Terminating | Pod正在被销毁或删除 |
| Terminated  | PodPod中的所有容器已终止 |
| Unkown      | Pod所在节点失联或其它未知异常 |
| Waiting     | Pod已被调度到某个节点,但容器尚未完成启动,等待启动 |

**pod状态说明**
```bash
1. Pending(挂起)
描述：Pod已经被创建,但还没有完成调度,或者说有一个或多个镜像正处于从远程仓库下载的过程。
处理过程：Pod可能正在写数据到etcd中、调度、pull镜像或启动容器;如果节点资源不足或镜像下载失败,Pod会保持Pending状态。


2. ContainerCreating(容器创建中)
描述：Pod已调度到节点,正在创建容器。
处理过程：节点上的kubelet拉取镜像并创建容器;如果镜像拉取失败或容器启动失败,Pod会保持此状态。

3. Running(运行中)
描述：Pod已绑定到节点,所有容器已创建且至少有一个在运行,或者正处于启动或重启状态。
处理过程：容器按定义启动并运行;kubelet监控容器状态,确保其持续运行。


4. Succeeded(成功)
描述：Pod中的所有的容器已正常执行后退出,并且不会自动重启,一般会是在部署job的时候会出现。
处理过程：容器完成任务后退出,状态码为0;Pod不再运行,但保留在集群中以供查询。


5. Failed(失败)
描述：Pod中的所有容器都已终止,且至少有一个容器是因为失败终止;也就是说,容器以非0状态退出或者被系统终止。
处理过程：容器因非零状态码或系统错误退出;kubelet记录失败原因,Pod保留在集群中供查询。


6. Unknown(未知)
描述：Pod状态无法确定,通常由于与节点通信失败。
处理过程：apiServer无法正常获取Pod状态信息,通常是由于其无法与所在工作节点的kubelet通信所致。

7. Terminating(终止中)
描述：Pod正在被删除。
处理过程：用户或控制器发出删除请求后,Pod进入Terminating状态;kubelet发送终止信号给容器,等待其优雅关闭;如果容器未及时关闭,kubelet会强制终止。

7. Terminated(已终止)
描述：Pod中的所有容器已终止。
处理过程：容器因任务完成或错误终止,Pod进入Terminated状态;Pod不再运行,但保留在集群中以供查询。

8. Deleted(已删除)
描述：Pod已从集群中移除。
处理过程：所有资源被释放,Pod从API服务器中删除;相关日志和事件可能保留供后续分析。

9. CrashLoopBackOff(崩溃循环)
描述：容器反复崩溃并重启。
处理过程：kubelet检测到容器频繁崩溃,进入CrashLoopBackOff状态;每次重启间隔时间逐渐增加,以减少系统负载。

10. ImagePullBackOff(镜像拉取失败)
描述：无法拉取容器镜像。
处理过程：kubelet尝试拉取镜像失败,进入ImagePullBackOff状态;每次重试间隔时间逐渐增加,以减少系统负载。

11. Error(错误)
描述：Pod因配置错误或其他问题无法启动。
处理过程：kubelet检测到配置错误或启动失败,进入Error状态;错误信息记录在事件日志中,供管理员排查。

12. Completed(完成)
描述：Pod中的所有容器成功完成任务并退出。
处理过程：容器完成任务后退出,状态码为0;Pod不再运行,但保留在集群中以供查询。

13. Evicted(驱逐)
描述：Pod因资源不足被驱逐。
处理过程：节点资源不足时,kubelet驱逐部分Pod以释放资源;被驱逐的Pod进入Evicted状态(需手动清理)。

14. OutOfCPU(CPU不足)
描述：Pod因CPU资源不足无法调度。
处理过程：调度器检测到节点CPU资源不足,Pod无法调度;Pod保持Pending状态,直到有足够CPU资源。

15. OutOfMemory(内存不足)
描述：Pod因内存资源不足无法调度。
处理过程：调度器检测到节点内存资源不足,Pod无法调度;Pod保持Pending状态,直到有足够内存资源。

16. NodeAffinity(节点亲和性)
描述：Pod因节点亲和性规则无法调度。
处理过程：调度器根据节点亲和性规则选择节点;如果没有符合规则的节点,Pod保持Pending状态。

17. PodAffinity(Pod亲和性)
描述：Pod因Pod亲和性规则无法调度。
处理过程：调度器根据Pod亲和性规则选择节点;如果没有符合规则的节点,Pod保持Pending状态。

18. PodAntiAffinity(Pod反亲和性)
描述：Pod因Pod反亲和性规则无法调度。
处理过程：调度器根据Pod反亲和性规则选择节点;如果没有符合规则的节点,Pod保持Pending状态。

19. Taint(污点)
描述：Pod因节点污点无法调度。
处理过程：调度器检测到节点有污点,Pod无法调度;Pod保持Pending状态,直到污点被移除或Pod容忍污点。

20. Toleration(容忍)
描述：Pod容忍节点污点。
处理过程：调度器检测到Pod容忍节点污点,Pod可以调度到该节点;Pod进入Running状态,容器正常启动。

21. Preempting(抢占)
描述：Pod因优先级较高抢占其他Pod资源。
处理过程：调度器检测到高优先级Pod需要资源,驱逐低优先级Pod;被抢占的Pod进入Terminating状态,高优先级Pod进入Pending状态。

22. Preempted(被抢占)
描述：Pod因优先级较低被其他Pod抢占资源。
处理过程：调度器检测到高优先级Pod需要资源,驱逐低优先级Pod;被抢占的Pod进入Terminating状态,高优先级Pod进入Pending状态。

23. Unschedulable(不可调度)
描述：Pod因资源不足或其他原因无法调度。
处理过程：调度器检测到Pod无法调度,保持Pending状态;相关事件记录在事件日志中,供管理员排查。

24. Scheduled(已调度)
描述：Pod已成功调度到节点。
处理过程：调度器为Pod选择合适节点,Pod进入Pending状态;kubelet开始拉取镜像并创建容器。

25. Initialized(已初始化)
描述：Pod的初始化容器已完成。
处理过程：初始化容器按顺序运行并成功完成;主容器开始启动,Pod进入Running状态。

26. Ready(已就绪)
描述：Pod已准备好接收流量。
处理过程：所有容器通过就绪探针检查,Pod进入Ready状态;服务可以将流量路由到该Pod。

27. NotReady(未就绪)
描述：Pod未准备好接收流量。
处理过程：容器未通过就绪探针检查,Pod进入NotReady状态;服务不会将流量路由到该Pod。

28. Unhealthy(不健康)
描述：Pod的健康检查失败。
处理过程：容器未通过健康检查,Pod进入Unhealthy状态;kubelet尝试重启容器或Pod。

29. Healthy(健康)
描述：Pod的健康检查通过。
处理过程：容器通过健康检查,Pod进入Healthy状态;Pod正常运行,服务可以路由流量。

30. Restarting(重启中)
描述：Pod中的容器正在重启。
处理过程：容器因故障或配置更改重启,Pod进入Restarting状态;kubelet监控重启过程,确保容器恢复正常。

31. OOMKilled(内存不足被杀死)
描述：容器因内存不足被系统杀死。
处理过程：容器内存使用超出限制,被系统杀死;kubelet记录OOMKilled事件,Pod进入Failed状态。

32. DeadlineExceeded(超时)
描述：Pod因超时未完成初始化或任务。
处理过程：初始化容器或主容器未在规定时间内完成,Pod进入DeadlineExceeded状态;kubelet记录超时事件,Pod进入Failed状态。

33. AdmissionError(准入错误)
描述：Pod因准入控制错误无法创建。
处理过程：准入控制器拒绝Pod创建请求,Pod进入AdmissionError状态;相关事件记录在事件日志中,供管理员排查。

36. FailedScheduling(调度失败)
描述：Pod因资源不足或其他原因调度失败。
处理过程：调度器无法为Pod找到合适节点,Pod进入FailedScheduling状态;相关事件记录在事件日志中,供管理员排查。

37. Scheduling(调度中)
描述：Pod正在被调度到节点。
处理过程：调度器为Pod选择合适节点,Pod进入Scheduling状态;如果调度成功,Pod进入Pending状态；否则进入FailedScheduling状态。

38. Binding(绑定中)
描述：Pod正在绑定到节点。
处理过程：调度器为Pod选择节点后,Pod进入Binding状态;绑定成功后,Pod进入Pending状态；否则进入FailedScheduling状态。

39. Bound(已绑定)
描述：Pod已成功绑定到节点。
处理过程：调度器为Pod选择节点并成功绑定,Pod进入Bound状态;kubelet开始拉取镜像并创建容器。

40. Unbound(未绑定)
描述：Pod未绑定到任何节点。
处理过程：调度器未为Pod选择节点,Pod进入Unbound状态;Pod保持Pending状态,直到成功绑定到节点。

41. Unscheduleable(不可调度)
描述：Pod因资源不足或其他原因无法调度。kube-scheduler没有匹配到合适的node节点。
处理过程：调度器检测到Pod无法调度,保持Pending状态;相关事件记录在事件日志中,供管理员排查。
```
### 7.9.2 [Pod状况](https://kubernetes.io/zh-cn/docs/concepts/workloads/pods/pod-lifecycle/#pod-conditions) 

Pod有一个PodStatus对象,其中包含一个PodConditions数组。Pod可能通过也可能未通过其中的一些状况测试  

```bash
kubelet explain pods.status.Conditions
```

| 字段名称    | 描述 | 
| :-------- | :----- |
| type     | Pod状况的名称  |
| status   | 表明该状况是否适用,可能的取值有"True"、"False"、"Unknown"  |
| reason   | 机器可读的、驼峰编码(UpperCamelCase)的文字,表述上次状况变化的原因  |
| message  | 人类可读的消息,给出上次状态转换的详细信息  |
| lastProbeTime | 上次探测Pod状况时的时间戳   |
| lastTransitionTime | Pod上次从一种状态转换到另一种状态时的时间戳  |  

typeCondition类型,kubelet管理以下PodCondition包含如下  
- PodScheduled：Pod已经被调度到某节点  
- PodReadyToStartContainers：Pod沙箱被成功创建并且配置了网络  
- ContainersReady：Pod 中所有容器都已就绪  
- Initialized：所有的Init容器都已成功完成  
- Ready：Pod可以为请求提供服务,并且应该被添加到对应服务的负载均衡池中   


### 7.9.3 Pod状态查询方式    
- 1.基础状态(kubectl get pods)  

```bash
Pending(挂起)
Running(运行中)
Succeeded(成功终止)
Completed(已完成)
Failed(失败终止)
Unknown(未知)
Terminating(终止中) 
Evicted(已驱逐)节点资源不足导致Pod被驱逐
CrashLoopBackOff(崩溃循环)容器频繁崩溃重启,kubelet正在尝试恢复
ImagePullBackOff镜像拉取失败(如镜像不存在或权限不足)
ContainerCreating容器创建中(可能因镜像拉取或资源分配延迟)
Init:0/x   
PodInitializing
Initialized所有pod中的初始化容器已经完成了。
...
```

- 2.详细状态(kubectl describe pod) 
  
```bash
PodScheduled：是否已调度到节点
Initialized：初始化容器是否完成执行
ContainersReady：所有容器是否准备就绪
Ready：Pod是否可接收流量(如服务流量)
...
```

- 3.排查总结  

```bash
kubectl get po -A
kubectl describe pod <pod-name>  #查看Events、Conditions
kubectl logs <pod-name>          #分析容器内部运行情况
```
---

## 8pod重启方法
在k8s中重启Pod有多种方式,具体方法的选择取决于Pod的管理方式(Deployment、Statefulset、DaemonSet等)和操作需求  
![pod-reboot](pic/podreboot.png)    

一、通过控制器管理Pod的重启(kubectl [rollout|scale] )  
滚动重启: (Rolling Restart）  
适用场景：Deployment、Statefulset、DaemonSet等管理的Pod需优雅重启避免服务中断;调整副本数(Scale to Zero & Back)  
```bash
kubectl rollout restart deployment <deployment_name> -n <namespace> #推荐滚动升级类似比较平滑

kubectl scale deployment/<deployment-name> -n <namespace> --replicas=0  #缩容至0,然后再改回目的副本数
kubectl scale deployment/<deployment-name> -n <namespace> --replicas=2  #恢复,会中断服务;#这种方法相对来说,比较粗放,我们可以先将副本调成0
```

二、直接操作Pod重启(kubectl delete pod)  
适用场景：单个Pod异常时快速重启;强制替换Pod(Replace API)  
```bash
kubectl delete pod <pod_name> -n <namespace>  #删除后控制器会自动重建,k8s声明式API会自动补足副本数 

kubectl replace --force -f pod.yaml   #强制替换Pod对象
kubectl get pod <pod_name> -n <namespace> -o yaml | kubectl replace --force -f -  #导出并重建;这种方法是通过更新Pod,触发k8spod的更新

pod容器中执行kill 1
kubectl exec -it <pod_name> -c <container_name> --/bin/sh -c "kill 1" #这种方法就是在容器里面kill 1号进程。但是此方法有个局限,必须要求你的1号进程要捕获TERM信号,否则在容器里面无法kill
```

三、高级配置触发重启(kubectl [annotate|set [image|env] ])  
修改注解(Annotation)或环境变量;修改Pod模板触发滚动更新  
适用场景：触发Pod重建以应用新配置;通过更新镜像版本或环境变量触发重建  
```bash
kubectl annotate pod/<pod-name> app-version=$(date +%s) --overwrite  #更新时间戳原理,k8s检测到注解变化后重建Pod  
kubectl      get pod/<pod-name> -o jsonpath='{.metadata.annotations}' | jq #验证注解更新

kubectl set image deployment/<deployment-name> <container>=<new-image>  #更新镜像  

kubectl set env deployment <deployment name> -n <namespace> DEPLOY_DATE="$(date)" #通过设置环境变量,其实也是更新podspec从而触发滚动升级。只不过这里通过kubectl命令行,当我们通过API更新podspec后一样会触发滚动升级  
```

>Pod重启说明  
>>优先选择滚动重启(rollout restart)兼顾稳定性和无缝性  
>>临时调试场景：直接删除Pod或替换YAML  
>>配置更新场景：通过修改镜像或注解触发重建  


