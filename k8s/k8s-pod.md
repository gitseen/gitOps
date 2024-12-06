# K8S-Pod知识点
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
* 
**Pod信息状态**  
```bash
tantianran@test-b-k8s-master:~$ kubectl get pods -n test-a
NAME                         READY   STATUS    RESTARTS        AGE
goweb-demo-b98869456-25sj9   1/1     Running   1 (3m49s ago)   5d10h
在READY字段中,1/1的意义为在这个pod里,已准备的容器/一共有多少个容器
STATUS字段指pod当前运行状态,RESTARTS指pod是重启次数,AGE表pod运行时长
```  

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

## [容器类型](https://mp.weixin.qq.com/s/-TXbvQiR-tpB0RgQ5d-QDw)
- 基础容器(pause container)  
- 初始化容器(init container)  
- Sidecar Container: 边车容器  
- Ephemeral Container: 临时容器  
- Multi Container: 多容器  
- 普通容器(业务容器/应用容器)  
- 
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
## 5Pod常用管理命令
```
#查看pod里所有容器的名称
kubectl get pods test-pod1 -o jsonpath={.spec.containers[*].name}

#进入pod里的指定容器的终端,如下进入pod为test-pod1里的容器nginx1和bs1
kubectl exec -it test-pod1 -c nginx1 -- bash
kubectl exec -it test-pod1 -c bs1 -- sh

#查看pod里指定容器的log
kubectl logs test-pod1 -c nginx1 
```
## 6Pod的重启策略+Pod健康检查(三种探针)
### 6.1 pod重启策略
+ Always：当容器终止退出,总是重启容器,默认策略
+ OnFailure：当容器异常退出（退出状态码非0）时,才重启容器
+ Never：当容器终止退出,从不重启容器  
```
#查看pod的重启策略
kubectl get pods test-pod1 -o yaml #找到restartPolicy字段,就是重启策略restartPolicy: Always
```
### 6.2 pod健康检测-探针(健康检查是检查容器里面的服务是否正常)
k8s中探测容器的三种探针(Probe)是用于检测容器内部状态是否正常运行。三种探针分别是Liveness、Readiness、Startup。

- livenessProbe(存活探测)：  如果检查失败,将杀死容器,根据pod的restartPolicy来操作   
  ```
  #用于确定容器是否仍在运行;如果容器不响应LivenessProbe则Kubernetes将在重启容器之前将其标记为失败  
  #常用于检测容器内部的应用程序状态;如果LivenessProbe失败,Kubernetes将重启该容器;这对于检测容器内存泄漏、死锁和其他常见问题非常有用   
  ```
- readinessProbe(就绪探测)： 如果检查失败,k8s会把Pod从service endpoints中剔除  
  ```
  #用于确定容器是否准备好接收网络流量;如果容器不响应ReadinessProbe则Kubernetes将不会将网络流量路由到该容器(通过修改Endpoints)  
  #常用于检测应用程序是否已完成启动和初始化过程;如果ReadinessProbe失败,Kubernetes将停止将网络流量路由到该容器,直到它再次响应探测请求    
  ```
- startupProbe(启动探测)：   检查成功才由存活检查接手,用于保护慢启动容器  
  ```
  #如果三个探针同时存在,先执行StartupProbe探针,其他两个探针将会被暂时禁用,直到pod满足StartupProbe探针配置的条件,与LivenessProbe和ReadinessProbe不同,StartupProbe仅在容器启动时运行一次  
  #常用于确定容器是否已经启动并准备好接收请求。与LivenessProbe和ReadinessProbe不同,StartupProbe仅在容器启动时运行一次,因此它适用于应用程序需要长时间启动的情况。如果StartupProbe失败,Kubernetes将重启该容器  
  ```  
>>注意事项  
探针的类型和检测方式可以根据应用程序的需求进行配置。例如LivenessProbe可以使用TCP、HTTP或命令行检查容器内部状态,具体取决于应用程序的类型和需要

>>控制探针的频率和超时时间非常重要。如果探测时间太长或间隔太短,可能会导致应用程序响应变慢或容器资源被消耗殆尽。通常建议将探测时间保持在几秒钟以内,以确保在应用程序出现问题时能够及时检测到并进行处理  

>>如果应用程序需要进行一些初始化操作,例如加载配置文件或连接数据库,可以在容器启动时使用Startup Probe进行检测。这可以确保应用程序在接收流量之前已经完成了必要的初始化过程  

**Pod探针是确保Kubernetes应用程序正常运行的重要机制;通过使用不同类型的探针,可以检测应用程序的各种状态,从而帮助自动化地管理容器集群,并提高应用程序的可靠性和可用性**  

### 6.3 探针检测试方法与示例
* httpGet：   发起HTTP请求,返回200-400范围状态码为成功。
* exec：      执行Shell命令返回状态码是0为成功。
* tcpSocket： 发起TCP Socket建立成功
* grpc：      通过容器的IP地址和端口,发起一个grpc请求（前提是服务实现了grpc健康检查协议）,返回服务健康的结果正常则认为服务是健康的 

**案例实战**  
1、 livenessProbe（存活探针）：使用exec的方式（执行Shell命令返回状态码是0则为成功）  
<details>
  <summary>livenessProbe-exec</summary>
  <pre><code>
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
4.查看Pod详情（在输出结果的最下面,有信息显示存活探针失败了,这个失败的容器被杀死并且被重建了。）
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

2、livenessProbe（存活探针）：使用httpGet请求的方式检查uri path是否正常  
<details>
  <summary>livenessProbe-httpGet</summary>
  <pre><code>
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
#注：在这个配置文件中Pod定义 periodSeconds字段指定了kubelet每隔3秒执行一次存活探测
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

3、readinessProbe（就绪探针）结合livenessProbe（存活探针）探测tcp端口  
第三种类型的存活探测是使用TCP套接字。 使用这种配置时kubelet会尝试在指定端口和容器建立套接字链接。 如果能建立连接,这个容器就被看作是健康的,如果不能则这个容器就被看作是有问题的  
<details>
  <summary>readinessProbe示例</summary>
  <pre><code>
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
#注：TCP检测的配置和HTTP检测非常相似。 这个例子同时使用就绪和存活探针
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

4、startupProbe（启动探针）保护慢启动容器  
有一种情景是这样的,某些应用在启动时需要较长的初始化时间。要这种情况下,若要不影响对死锁作出快速响应的探测,设置存活探测参数是要技巧  
技巧就是使用相同的命令来设置启动探测,针对HTTP或TCP检测,可以通过将failureThreshold * periodSeconds参数设置为足够长的时间来应对糟糕情况下的启动时间  
<details>
  <summary>startupProbe示例</summary>
  <pre><code> 
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
          failureThreshold: 1
          periodSeconds: 10
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

#注 应用程序将会有最多5分钟（30 * 10 = 300s）的时间来完成其启动过程
     一旦启动探测成功一次,存活探测任务就会接管对容器的探测,对容器死锁作出快速响应
     如果启动探测一直没有成功,容器会在300秒后被杀死,并且根据restartPolicy来执行进一步处置
 </code></pre>
</details>

[探针-路多辛](https://www.toutiao.com/article/7206670428587164192/)  
[kubernetes官方文档](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/)   


## 7环境变量
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

## 8init container(初始化容器)
**初始化容器的特点**  
- Init容器是一种特殊容器,在Pod内,会在应用容器启动之前运行
- 如果Pod的Init容器失败,kubelet会不断地重启该Init容器,直到该容器成功为止
- 如果Pod对应的restartPolicy值为 "Never",并且Pod的Init容器失败,则Kubernetes会将整个Pod状态设置为失败
- 如果为一个Pod指定了多个Init容器,这些容器会按顺序逐个运行。每个Init容器必须运行成功,下一个才能够运行
- Init容器不支持探针包括lifecycle、livenessProbe、readinessProbe和startupProbe  
<details>
  <summary>init-check</summary>
  <pre><code> 
假设应用容器是依赖数据库的,如果数据库没起来,那么应用容器就算起来了也是服务不可用。所以,现在的主要目的是想在应用容器启动之前检查mysql服务器的IP地址是否可ping通,如果是通的才启动应用容器。这个例子应该是比较贴近实际场景了  
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
  replicas: 3
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
      initContainers:
      - name: init-check-mysql-ip
        image: 192.168.11.247/os/busybox:latest
        command: ['sh', '-c', "ping 192.168.11.248 -c 5"]
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

mysql服务器故意没拉起,看看效果
kubectl get pods -n test-a
NAME                          READY   STATUS                  RESTARTS      AGE
goweb-demo-859cc77bd5-jpcfs   0/1     Init:CrashLoopBackOff   3 (34s ago)   2m11s
goweb-demo-859cc77bd5-n8hqd   0/1     Init:CrashLoopBackOff   3 (33s ago)   2m11s
goweb-demo-859cc77bd5-sns67   0/1     Init:CrashLoopBackOff   3 (34s ago    2m11s
观察STATUS字段发现,它经历了3个阶段,第一阶段是正常的运行,也就是执行ping检查的操作,因为死活Ping不同
所以进入了第二阶段,状态为Error。
紧接着是第三阶段,状态变成了CrashLoopBackOff,对于这个状态,我的理解是,初始化容器运行失败了,准备再次运行
它就会的状态就会一直这样：运行->Error->CrashLoopBackOff。当然这种情况是当Pod对应的restartPolicy为"Always"（这是默认策略）才会这样不断的循环检查
如果Pod对应的restartPolicy值为"Never",并且Pod的 Init容器失败,则Kubernetes会将整个Pod状态设置为失败。
#当我把mysql服务器启动后,初始化容器执行成功,那么应用容器也就成功起来
kubectl get pods -n test-a
NAME                          READY   STATUS    RESTARTS   AGE
goweb-demo-859cc77bd5-jpcfs   1/1     Running   0          30m
goweb-demo-859cc77bd5-n8hqd   1/1     Running   0          30m
goweb-demo-859cc77bd5-sns67   1/1     Running   0          30m
  </code></pre>
</details>



## 9[Kubernetes中钩子函数详解实例](https://www.toutiao.com/article/7214297018754204219/)  
**钩子函数能够感知自身生命周期中的事件,并在相应的时刻到来时运行用户指定的程序代码**  

kubernetes在主容器的启动之后和停止之前提供了两个钩子函数  
- postStart  #容器创建之后执行,如果失败了会重启容器
- preStop    #容器终止之前执行,执行完成之后容器将成功终止,在其完成之前会阻塞删除容器的操作  

**钩子处理器支持使用下面三种方式定义动作**  
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
<details>
  <summary>exec-postStart-preStop-example</summary>
  <pre><code>
#xx.yaml
apiVersion: v1
kind: Pod
metadata:
  name: pod-hook-exec
  namespace: dev
spec:
  containers:
  - name: main-container
    image: nginx
    ports:
    - name: nginx-port
      containerPort: 80
    lifecycle:
      postStart: 
        exec: # 在容器启动的时候执行一个命令,修改掉nginx的默认首页内容
          command: ["/bin/sh", "-c", "echo postStart... > /usr/share/nginx/html/index.html"]
      preStop:
        exec: # 在容器停止之前停止nginx服务
          command: ["/usr/sbin/nginx","-s","quit"]
  </code></pre>
</details>

**钩子函数总结**
- PostStart hook是在容器创建(created)之后立马被调用,并且PostStart跟容器的ENTRYPOINT是异步执行的,无法保证它们之间的顺序
- PreStop hook是容器处于Terminated状态时立马被调用(也就是说要是Job任务的话,执行完之后其状态为completed,所以不会触发PreStop的钩子),同时PreStop是同步阻塞的,PreStop执行完才会执行删除Pod的操作
- PostStart会阻塞容器成为Running状
- PreStop会阻塞容器的删除,但是过了terminationGracePeriodSeconds时间后,容器会被强制删除
- 如果PreStop或者PostStart失败的话, 容器会被杀死   


## 10pod-status

## 11pod-xx


