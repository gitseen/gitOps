# K8S-Pod知识点
## 1. Pod概念热身
Pod是一个逻辑抽象概念，K8s创建和管理的最小单元，一个Pod由一个容器或多个容器组成。   
**特点**  
+ 一个Pod可以理解为是一个应用实例
+ Pod中容器始终部署在一个Node上
+ Pod中容器共享网络、存储资源 
 
**Pod主要用法**  
* 运行单个容器：最常见的用法，在这种情况下，可以将Pod看作是单个容器的抽象封装
* 运行多个容器：边车模式(Sidecar)通过在Pod中定义专门容器，来执行主业务容器需要的辅助工作，这样好处是将辅助功能同主业务容器解耦，实现独立发布和能力重用。 例如:   
  - 日志收集
  - 应用监控  

**扩展：READY字段的意义:**  
```
tantianran@test-b-k8s-master:~$ kubectl get pods -n test-a
NAME                         READY   STATUS    RESTARTS        AGE
goweb-demo-b98869456-25sj9   1/1     Running   1 (3m49s ago)   5d10h
在READY字段中，1/1的意义为在这个pod里，已准备的容器/一共有多少个容器
```  

**pod3种类型的容器**  
- 基础容器(pause container)
- 初始化容器(init container)
- 普通容器(业务容器/应用容器)

## 2. POD内容器间资源共享实现机制
### 2.1 共享数据的机制
+ emptyDir  
  会在Pod被删除的同时也会被删除，当Pod分派到某个节点上时，emptyDir卷会被创建，并且在Pod在该节点上运行期间，卷一直存在。 就像其名称表示的那样，卷最初是空的。 尽管Pod中的容器挂载emptyDir卷的路径可能相同也可能不同，这些容器都可以读写emptyDir卷中相同的文件。 当Pod因为某些原因被从节点上删除时emptyDir卷中的数据也会被永久删除  
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
  cephfs 卷允许你将现存的CephFS卷挂载到Pod中，cephfs卷的内容在Pod被删除时会被保留，只是卷被卸载了。 这意味着cephfs卷可以被预先填充数据，且这些数据可以在Pod之间共享。同一cephfs卷可同时被多个写者挂载   

### 2.2 共享网络的机制
共享网络的机制是由Pause容器实现，下面慢慢分析一下，啥是pause，了解一下它的作用等等。  
1、先准备一个yaml文件（pod1.yaml ），创建一个pod，pod里包含两个容器，一个是名为nginx1的容器，还有一个是名为bs1的容器  
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
2、开始创建  
```
kubectl create -f pod1.yaml
```
3、创建完后看看在哪个节点  
```
kubectl get pod -o wide
```
4、去到对应的节点查看容器  
```
docker ps | grep test-pod1
0db01653bdac   busybox                                                "/bin/sh -c 'sleep 1…"   9 minutes ago    Up 9 minutes              k8s_bs1_test-pod1_default_c3a15f70-3ae2-4a73-8a84-d630c047d827_0
296972c29efe   nginx                                                  "/docker-entrypoint.…"   9 minutes ago    Up 9 minutes              k8s_nginx1_test-pod1_default_c3a15f70-3ae2-4a73-8a84-d630c047d827_0
a5331fba7f11   registry.aliyuncs.com/google_containers/pause:latest   "/pause"                 10 minutes ago   Up 10 minutes             k8s_POD_test-pod1_default_c3a15f70-3ae2-4a73-8a84-d630c047d827_0
```
通过查看容器,名为test-pod1的pod里除了两个业务容器外(k8s_bs1_test-pod1、nginx1_test-pod1)还有一个pause容器,这个到底是什么?  

**对pause容器的理解**  
- pause容器又叫Infra container，就是基础设施容器的意思，Infra container只是pause容器的一个叫法而已
- 上面看到paus容器，是从registry.aliyuncs.com/google_containers/pause:latest这个镜像拉起的
- 在其中一台node节点上查看docker镜像，可看到该镜像的大小是240KB
  ```
  registry.aliyuncs.com/google_containers/pause        latest       350b164e7ae1   8 years ago     240kB
  ```
## 3. Pod常用管理命令
```
#查看pod里所有容器的名称
kubectl get pods test-pod1 -o jsonpath={.spec.containers[*].name}

#进入pod里的指定容器的终端，如下进入pod为test-pod1里的容器nginx1和bs1
kubectl exec -it test-pod1 -c nginx1 -- bash
kubectl exec -it test-pod1 -c bs1 -- sh

#查看pod里指定容器的log
kubectl logs test-pod1 -c nginx1 
```
## 4. Pod的重启策略+应用健康检查(应用自修复)
**pod重启策略** 
+ Always：当容器终止退出，总是重启容器，默认策略
+ OnFailure：当容器异常退出（退出状态码非0）时，才重启容器
+ Never：当容器终止退出，从不重启容器  
```
#查看pod的重启策略
kubectl get pods test-pod1 -o yaml #找到restartPolicy字段，就是重启策略restartPolicy: Always
```
**pod健康检测(健康检查是检查容器里面的服务是否正常)**  
- livenessProbe(存活探测)：  如果检查失败，将杀死容器，根据pod的restartPolicy来操作。
- readinessProbe(就绪探测)： 如果检查失败，k8s会把Pod从service endpoints中剔除
- startupProbe(启动探测)：   检查成功才由存活检查接手，用于保护慢启动容器

**支持检测试方法**    
* httpGet：   发起HTTP请求，返回200-400范围状态码为成功。
* exec：      执行Shell命令返回状态码是0为成功。
* tcpSocket： 发起TCP Socket建立成功

**案例实战**  

1、livenessProbe（存活探针）：使用exec的方式（执行Shell命令返回状态码是0则为成功）  
```
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

#查看某个pod的里的容器，
kubectl get pods goweb-demo-686967fd56-556m9 -n test-a -o jsonpath={.spec.containers[*].name}
#进入某个pod里的容器
kubectl exec -it goweb-demo-686967fd56-556m9 -c goweb-demo -n test-a -- bash
#进入容器后，手动删除掉runserver可执行文件，模拟故障
rm -rf /opt/goweb-demo/runserver
#查看Pod详情（在输出结果的最下面，有信息显示存活探针失败了，这个失败的容器被杀死并且被重建了。）
kubectl describe pod goweb-demo-686967fd56-556m9 -n test-a
Events:
  Type     Reason     Age                   From     Message
  ----     ------     ----                  ----     -------
  Warning  Unhealthy  177m (x6 over 3h59m)  kubelet  Liveness probe failed: ls: cannot access '/opt/goweb-demo/runserver': No such file or directory

# 一旦失败的容器恢复为运行状态，RESTARTS 计数器就会增加 1
tantianran@test-b-k8s-master:~$ kubectl get pods -n test-a
NAME                          READY   STATUS    RESTARTS      AGE
goweb-demo-686967fd56-556m9   1/1     Running   1 (22s ago)   13m # RESTARTS字段加1，
goweb-demo-686967fd56-8hzjb   1/1     Running   0             13m

```
2、livenessProbe（存活探针）：使用httpGet请求的方式检查uri path是否正常  
3、readinessProbe（就绪探针）结合livenessProbe（存活探针）探测tcp端口  
4、startupProbe（启动探针）保护慢启动容器  

