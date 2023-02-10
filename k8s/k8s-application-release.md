# k8s应用发布
## 1. 使用yaml文件创建资源对象
每种资源的apiVersion和kind可通过 kubectl api-resources 命令进行查看
```
kubectl api-resources | grep Deployment
```
eg:
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

```
关于标签的主要作用：标记、过滤、关联(主要体现在deployment、pod、service、3者标签保持一致)，可设定多个标签，建议设定至少2个标签，一个为项目标签，一个为应用标签  
![资源关系图](https://p3-sign.toutiaoimg.com/tos-cn-i-qvj2lq49k0/1c65027c67aa4e3da1fc9d15ec96f377~noop.image?_iz=58558&from=article.pc_detail&x-expires=1676454852&x-signature=3Zlc%2FocMgdwwWwvlU6j4yIRop7A%3D)  

关于创建、更新和删除的命令  
```
# 只用于创建
kubectl create -f xxx.yaml

# 创建和更新（需要yaml文件里的字段支持更新，并不是所有字段都支持更新）
kubectl apply -f xxx.yaml

# 卸载
kubectl delete -f xxx.yaml
```
## 2. 编写yaml的套路分享
- 套路1：可以直接手写，但容易出错
- 套路2：参考官方示例，然后改成自己的
- 套路3：通过命令行来获取，也是有2个方式，一是利用尝试运行（--dry-run）的机制再配合-o来输出一个yaml文件），二是通过get来得到yaml文件，得到yaml文件后再自行修改  
下面演示通过create来得到yaml   
```
# 在kubectl级别上进行验证
kubectl create deployment web1 --image=nginx --replicas=5 --dry-run=client

# 指的是提交到apiserver进行验证
kubectl create deployment web1 --image=nginx --replicas=5 --dry-run=server

# 下面来一个deployment的例子，得到其他资源的yaml也是这个套路
tantianran@test-b-k8s-master:~$ kubectl create deployment web1 --image=nginx --replicas=5 --dry-run=client -o yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  creationTimestamp: null
  labels:
    app: web1
  name: web1
spec:
  replicas: 5
  selector:
    matchLabels:
      app: web1
  strategy: {}
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: web1
    spec:
      containers:
      - image: nginx
        name: nginx
        resources: {}
status: {}

# 还可以配合重定向输出到yaml文件
kubectl create deployment web1 --image=nginx --replicas=5 --dry-run=client -o yaml > test.yaml
```
下面演示通过get命令来得到yaml文件，使用-o来指定yaml的格式输出，其他资源也是这个套路  
```
kubectl get pods -n test-a -o yaml
```
编写yaml的时候，字段名太多记不住或者想不起来怎么办？可以使用explain来查看字段层级  
```
# 找第一级
kubectl explain deployment

# 找第二级
kubectl explain deployment.spec

# 再比如查pod相关的
kubectl explain pods.spec.containers
```
##3. 应用生命周期管理
deployment是最常用的k8s工作负载控制器Workload Controllers是k8s的一个抽象概念，用于更高级层次对象，部署和管理Pod，卡控制器还有DaemonSet、StatefulSet等  
应用生命周期管理流程  
![app](https://p3-sign.toutiaoimg.com/tos-cn-i-qvj2lq49k0/1eb19284fd7249ed9ea5906b0525626a~noop.image?_iz=58558&from=article.pc_detail&x-expires=1676454852&x-signature=9W33molatSdQ3bTTNe579jeb8Mo%3D)  
## 3.1 应用部署的基本流程
部署->升级->回滚->删除  
## 3.1.1 部署
```
# 推荐的方式
kubectl apply -f xxx.yaml

# 或者
kubectl create deployment web --image=nginx --replicas=3
```
## 3.1.2 升级
所谓的升级，其实就是更新镜像，且有3种方式，自动触发滚动升级  
```
# 方式1：直接修改yaml文件中的镜像，然后apply
kubectl apply -f xxx.yaml
# 方式2：使用命令设置deployment使用的镜像
kubectl set image deployment/web nginx=nginx1.17
# 使用系统编辑器打开进行编辑
kubectl edit deployment
``` 
## 发布(发布方式有3种)
- 滚动发布
  K8S默认是滚动升级;滚动发布是指每次只升级一个或多个服务，升级完成后加入生产环境，不断执行这个过程，直到集群中的全部旧版本升级新版本。
  + 滚动升级在k8s中的实现
    ```
    它是通过1个Deployment和2个ReplicaSet来实现的，滚动更新一次只升级一小部分pod，成功后，再升级一部分pod，最终完成所有Pod升级，整个过程始终有Pod在运行，从而保证了业务的连续性。
    ```
  + ReplicaSet
    ```
    副本集，主要维护Pod副本数量，不断对比当前Pod数量于期望Pod数量。「ReplicaSet用途：」 Deployment每次发布都会创建一个RS（ReplicaSet的缩写）作为记录，用于实现滚动升级和回滚
    ```
可以查看deployment的详情，详情里其实是记录了升级的过程  
```
kubectl get deployment -n test-a
kubectl describe deployment goweb-demo -n test-a
# 命令格式
kubectl set image deployment <DeploymentName> <ContainerName>=<Image> -n <Namespace>

# 例子
# step 1：获取deployment
kubectl get deployment -n test-a

# step 2：查看deployment详情
kubectl describe deployment goweb-demo -n test-a
水平扩缩容，也就是修改副本的数量，也有2种方式
kubectl scale deployment goweb-demo --replicas=5 -n test-a
```
- 蓝绿发布
- 灰度发布（金丝雀、A/B测试、冒烟测试。灰度发布是最复杂的方式，发布的方式是为了避免上线后出现的问题）

## 3.1.3 回滚
当应用发布失败，需要回滚时  
查看发过有哪些版本  
```
#查看历史
kubectl rollout history deployment -n xx

#通过命令修改deployment的镜像进行升级时，后面加--record参数，再查看历史后就会记录这条命令
kubectl set image deployment goweb-demo goweb-demo=192.168.11.247/web-demo/goweb-demo:20221229v2 -n test-a --record

#上面加了--record参数，再查看历史，可以看到记录的这条命令
kubectl rollout history deployment -n test-a
#查看版本号和RS的对应关系，以及和镜像的对应关系
kubectl get rs -n xx
#查看当前使用的RS详情
kubectl describe rs goweb-demo-b98869456 -n xx
#查看历史版本
kubectl rollout history deployment -n xx

#只回滚到上一个版本
kubectl rollout undo deployment goweb-demo -n test-a
#回滚到指定的历史版本
kubectl describe $(kubectl get rs -o name -n test-a | grep "goweb-") -n test-a | grep -E "revision:|Replicas:"
```
# 3.1.4 删除（当项目需要下线时）
```
# 如果该项目是直接编写yaml的，可这样删除（下线）
kubectl delete -f goweb-demo.yaml

# 如果该项目的命名空间、deployment、service是用命令的，那就需要手动删除下线
kubectl delete deployment goweb-demo -n test-a
kubectl delete svc goweb-demo -n test-a
kubectl delete ns test-a
```
[https://www.toutiao.com/article/7192944727292117541](https://mp.weixin.qq.com/s/jBJTLYvXkCtd__yO4Ap9UA)
