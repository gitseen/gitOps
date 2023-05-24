# k8s工作负载控制器
# [k8s原来不是直接创建Pod-小心程序猿QAQ](https://www.toutiao.com/article/7235184706738962948/)  
## Deployment
**1、Deployment主要功能**    
- 管理Pod和ReplicaSet
- 具有上线部署、副本设定、滚动升级、回滚等功能  
- 提供声明式更新,例如只更新一个新的Images 
- 使用场景：网站、API、微服务  
 
Pod与控制器的关系图  
![https://www.cnblogs.com/yypc/articles/17166489.html](https://img2023.cnblogs.com/blog/1283445/202302/1283445-20230228232534364-1236199343.png)  

**2、Deployment应用生命周期管理流程**  
![https://www.cnblogs.com/yypc/articles/17166489.html](https://img2023.cnblogs.com/blog/1283445/202302/1283445-20230228232534286-869392573.png) 

**3、Deployment生命周期管理流程操作**  
3.1 Deployment部署应用 
<details>
  <summary>xx.yaml</summary>
  <pre><code>
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web
  namespace: aliang-cka
spec:
 replicas: 3 #pod副本预期数量 
 selector:
  matchLabels:
   app: web
 template:
  metadata:
   labels:
     app: web # Pod的副本标签
  spec:
   containers:
   - name: web
     image: nginx:1.16
  </code></pre>
</details>  

- kubectl apply -f xxx.yaml  
- kubectl create deployment web --image=nginx:1.16 --replicas=3  
 
3.2 Deployment滚动升级 
应用升级(更新镜像三种方式,自动触发滚动升级)  
- kubectl apply -f xxx.yaml  
- kubectl set image deployment/web nginx=nginx:1.17
- kubectl edit deploment/web #使用系统编辑打开
![xx](https://img2023.cnblogs.com/blog/1283445/202302/1283445-20230228233041523-1343991503.png)   
>>滚动升级：k8s对pod升级的默认策略,通过使用新版本pod逐步更新旧版pod,实现零停机发布,用户无感知  

3.3 Deployment滚动升级在k8s中实现  
- 1个deployment  
- 2个ReplicaSet  
![](https://img2023.cnblogs.com/blog/1283445/202302/1283445-20230228233041495-195266682.png)  
 
3.4 Deployment水平扩缩溶  
水平扩缩容(启动多实例,提供并发)  
- 修改yaml里replicas值,再apply  
- Kubectl scale deployment web -replicas=10  
>>注意：replicas参数控制pod的副本数量  
![xx](https://img2023.cnblogs.com/blog/1283445/202302/1283445-20230228233847579-488572200.png)  

3.5 Deployment回滚  
```
kubectl set image deployment web web=nginx:1.18 --record  #record记录到发布版本里
3.4：回滚（项目升级失败恢复到正常版本） 
Kubectl rollout history deployment/web #查看历史版本  
Kubectl rollout undo deployment/web 回滚上一个版本   
Kubectl rollout undo deployment/web -to-revision=2 #回滚历史指定版本  
注意:回滚是重新部署某一次部署的状态,即当时版本所有配置  
```
查询service关联的pod
kubectl get endpoints -n aliang-cka  
replicaSet（RS）：副本集,是一个控制器,具体是管理Pod副本的,他是deployment小弟,是滚动升级的执行者  
- 滚动升级执行者
- 发布版本记录者
```
kubectl get rs -n aliang-cka
NAME             DESIRED   CURRENT   READY   AGE
web-545c8dd8d8   0         0         0       15m    nginx:1.16
web-5ffdd58fff   3         3         3       8m47s  nginx:1.17
web-7995df6956   0         0         0       25m    java-demo
kubectl describe deployment web -n aliang-cka
...
初次部署：
  Normal  ScalingReplicaSet  28m                  deployment-controller  Scaled up replica set web-7995df6956 to 3

第一次升级,由java-demo升级到nginx:1.16
  Normal  ScalingReplicaSet  18m                  deployment-controller  Scaled up replica set web-545c8dd8d8 to 1
  Normal  ScalingReplicaSet  17m                  deployment-controller  Scaled down replica set web-7995df6956 to 2
  Normal  ScalingReplicaSet  17m                  deployment-controller  Scaled up replica set web-545c8dd8d8 to 2
  Normal  ScalingReplicaSet  17m                  deployment-controller  Scaled down replica set web-7995df6956 to 1
  Normal  ScalingReplicaSet  17m                  deployment-controller  Scaled up replica set web-545c8dd8d8 to 3
  Normal  ScalingReplicaSet  16m                  deployment-controller  Scaled down replica set web-7995df6956 to 0

第二次升级,由nginx:1.16升级到nginx:1.17
  Normal  ScalingReplicaSet  11m                  deployment-controller  Scaled up replica set web-5ffdd58fff to 1
  Normal  ScalingReplicaSet  10m                  deployment-controller  Scaled down replica set web-545c8dd8d8 to 2
  Normal  ScalingReplicaSet  10m                  deployment-controller  Scaled up replica set web-5ffdd58fff to 2
  Normal  ScalingReplicaSet  9m44s (x3 over 10m)  deployment-controller  (combined from similar events): Scaled down replica set web-545c8dd8d8 to 0

旧版本：545c8dd8d8  nginx:1.16
新版本：5ffdd58fff  nginx:1.17

滚动升级步骤：
5ffdd58fff scale-up 扩容为1个Pod副本
545c8dd8d8 scale-dwon 缩容为2个Pod副本
5ffdd58fff scale-up 扩容为2个Pod副本
545c8dd8d8 scale-dwon 缩容为1个Pod副本
5ffdd58fff scale-up 扩容为3个Pod副本
545c8dd8d8 scale-dwon 缩容为0个Pod副本

RS在其中不断调谐副本数量,实现滚动策略。
kubectl set image deployment web web=nginx:1.18 --record  # record记录到发布版本里
```
3.6 Deployment删除 
最后,项目下线：  
- kubectl delete deploy/web
- kubectl delete svc/web 

3.7 Deployment控制器用途  
- Pod副本数量管理,不断对当前Pod数量与期望pod数量  
- Deployment每次发布都会创建一个RS作为记录,用于实现回滚 
Kubectl get rs 查看RS记录  
Kubectl rollout history deployment web #版本对应RS记录  

**Deployment: 一般用来部署长期运行的、无状态的应用;特点：集群之中,随机部署**  
[Deployment-官方文档](https://kubernetes.io/zh-cn/docs/concepts/workloads/controllers/deployment/)  

## StatefulSet
## DaemonSet

