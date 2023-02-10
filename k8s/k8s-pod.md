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
通过查看容器，名为test-pod1的pod里，除了两个业务容器外（k8s_bs1_test-pod1、nginx1_test-pod1），还有一个pause容器。这个到底是什么?  
**对pause容器的理解**  
- pause容器又叫Infra container，就是基础设施容器的意思，Infra container只是pause容器的一个叫法而已
- 上面看到paus容器，是从registry.aliyuncs.com/google_containers/pause:latest这个镜像拉起的
- 在其中一台node节点上查看docker镜像，可看到该镜像的大小是240KB
  ```
  registry.aliyuncs.com/google_containers/pause        latest       350b164e7ae1   8 years ago     240kB
  ```
## Pod常用管理命令
```
#查看pod里所有容器的名称
kubectl get pods test-pod1 -o jsonpath={.spec.containers[*].name}

#进入pod里的指定容器的终端，如下进入pod为test-pod1里的容器nginx1和bs1
kubectl exec -it test-pod1 -c nginx1 -- bash
kubectl exec -it test-pod1 -c bs1 -- sh

#查看pod里指定容器的log
kubectl logs test-pod1 -c nginx1 
```
## Pod的重启策略+应用健康检查(应用自修复)

