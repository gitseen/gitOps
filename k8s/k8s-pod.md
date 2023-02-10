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

