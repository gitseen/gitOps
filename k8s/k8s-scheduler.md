# k8s调度之初探nodeSelector和nodeAffinity
**k8s的调度中类型** 
  - 有强制性的nodeSelector
  - 节点亲和性nodeAffinity
  - Pod亲和性podAffinity
  - pod反亲和性podAntiAffinity  

进入主题之前,先看看创建pod的大概过程  
![创建pod流程](https://p3-sign.toutiaoimg.com/tos-cn-i-qvj2lq49k0/01235649687f49ab9c753705c94ec72c~noop.image?_iz=58558&from=article.pc_detail&x-expires=1680141269&x-signature=E%2B%2BO60EUmurXwO%2BO6h0bS%2Fal9JE%3D)  
```
1、kubectl向apiserver发起创建pod请求,apiserver将创建pod配置写入etcd
2、scheduler收到apiserver有新pod的事件,scheduler根据自身调度算法选择一个合适的节点,并打标记pod=test-b-k8s-node01
3、kubelet收到分配到自己节点的pod,调用docker api创建容器,并获取容器状态汇报给apiserver
4、执行kubectl get查看,apiserver会再次从etcd查询pod信息
k8s的各个组件是基于list-watch机制进行交互的,了解了list-watch机制,以及结合上述pod的创建流程,就可以很好的理解各个组件之间的交互。
```

# 何为调度
>>何为调度  
说白了就是将Pod指派到合适的节点上,以便对应节点上的Kubelet能够运行这些Pod  
在k8s中,承担调度工作的组件是kube-scheduler,它也是k8s集群的默认调度器,它在设计上就允许编写一个自定义的调度组件并替换原有的kube-scheduler。所以,如果你足够牛逼,就可以自己开发一个调度器来替换默认的了   
调度器通过K8S的监测(Watch)机制来发现集群中新创建且尚未被调度到节点上的Pod,调度器会将所发现的每一个未调度的Pod调度到一个合适的节点上来运行  
- 调度程序会过滤掉任何不满足Pod特定调度需求的节点
- 创建Pod时也可以手动指定一个节点
- 如果没有任何一个节点能满足Pod的资源请求, 那么这个Pod将一直停留在未调度状态直到调度器能够找到合适的Node  

# 调度流程
>>kube-scheduler给一个Pod做调度选择时包含了两个步骤：过滤、打分  
- 1、pod开始创建,通知apiserver
- 2、kube-scheduler在集群中找出所有满足需求的可调度节点（过滤阶段）
- 3、kube-scheduler根据当前打分规则给这些可调度节点打分（打分阶段）
- 4、kube-scheduler选择得分最高的节点运行Pod（存在多个得分最高的节点则随机选取）
- 5、kube-scheduler通知kube-apiserver

# nodeSelector和nodeAffinity
>>实际工作中,可能会有这样的情况,需要进一步控制Pod被部署到哪个节点
例如,确保某些Pod最终落在具有SSD硬盘的主机上,又需要确保某些pod落在具体部门的主机上运行,这时就可以使用标签选择器来进行选择  
 
![eg](https://p3-sign.toutiaoimg.com/tos-cn-i-qvj2lq49k0/cdd26b016dd942f4924d0958a0ce07b6~noop.image?_iz=58558&from=article.pc_detail&x-expires=1680141269&x-signature=w8dCnjlw406IrypgDZBTPNaeNr8%3D)  

- nodeSelector：通过它可以将pod指派到具有特定标签的节点上,nodeSelector只能选择指定标签的节点,它属于强制性的,如果标签不小心写错则无法调度
- nodeAffinity：节点亲和性有以下两种,它的表达能力更强,允许指定软规则,提供了对选择逻辑更强的控制能力,operator字段支持In、NotIn、Exists、DoesNotExist、Gt和Lt,
  * requiredDuringSchedulingIgnoredDuringExecution：调度器只有在规则被满足的时候才能执行调度（硬策略）
  * preferredDuringSchedulingIgnoredDuringExecution：调度器会尝试寻找满足对应规则的节点。如果找不到匹配的节点,调度器仍然会调度该Pod（软策略）  
>>进一步对nodeAffinity的理解
我对亲和性和反亲和性的理解是这样的,亲和性就是希望某些pod在同一个node上,反亲和性是希望某些pod不要在同一个node上  
nodeAffinity是亲和性的,它的NotIn和DoesNotExist可用来实现节点反亲和性行为（当然也可以使用节点污点将Pod从特定节点上驱逐,后面专门分享）,通过逻辑组合可以控制pod要部署在哪些节点上,以及不能部署在哪些节点上  

**注意**  
- 如果同时指定了 nodeSelector 和 nodeAffinity,两者必须都要满足, 才能将Pod调度到候选节点上
- 如果在与 nodeAffinity 类型关联的 nodeSelectorTerms 中指定多个条件, 只要其中一个 nodeSelectorTerms 满足（各个条件按逻辑或操作组合）的话,Pod 就可以被调度到节点上
- 如果在与 nodeSelectorTerms 中的条件相关联的单个 matchExpressions 字段中指定多个表达式,则只有当所有表达式都满足（各表达式按逻辑与操作组合）时,Pod才能被调度到节点上  


# 实战案例
## 1、节点亲和性案例（nodeAffinity）
<details>
  <summary>nodeAffinity-example</summary>
  <pre><code>
#xx.yaml

```
apiVersion: v1
kind: Pod
metadata:
  name: goweb-demo
spec:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution: # 调度器只有在规则被满足的时候才执行调度
        nodeSelectorTerms:
        - matchExpressions:
          - key: team
            operator: In
            values:
            - team-a
            - team-b
      preferredDuringSchedulingIgnoredDuringExecution: # 调度器会尝试寻找满足对应规则的节点（如果找不到匹配的节点,调度器仍然会调度该Pod）
      - weight: 1
        preference:
          matchExpressions:
          - key: hostbrand
            operator: In
            values:
            - ibm
  containers:
  - name: container-goweb-demo
    image: 192.168.11.247/web-demo/goweb-demo:20221229v3
```
配置node的标签
#设置标签
kubectl label node test-b-k8s-node01 team=team-a
kubectl label node test-b-k8s-node02 team=team-b
kubectl label node test-b-k8s-node01 hostbrand=ibm
kubectl get node --show-labels
kubectl create -f xx.yaml 
kubectl get pod -o wide
NAME         READY   STATUS    RESTARTS   AGE   IP              NODE                NOMINATED NODE   READINESS GATES
goweb-demo   1/1     Running   0          17s   10.244.240.58   test-b-k8s-node01   <none>           <none>

在上面的案例中,所应用的规则如下:    
   节点必须包含一个键名为team的标签, 并且该标签的取值必须为team-a或team-b
   节点最好具有一个键名为hostbrand且取值为ibm的标签   

关于节点亲和性权重的weight字段：  
   preferredDuringSchedulingIgnoredDuringExecution亲和性类型可以设置weight字段,其取值范围是1到100。 当调度器找到能够满足Pod的其他调度请求的节点时,调度器会遍历节点满足的所有的偏好性规则, 并将对应表达式的weight值加和。  
   最终的加和值会添加到该节点的其他优先级函数的评分之上;在调度器为Pod作出调度决定时,总分最高的节点的优先级也最高
  </code></pre>
</details>

## 2、节点亲和性+带有权重的例子
<details>
  <summary>nodeAffinity-weight-example</summary>
  <pre><code>
#nodeAffinity-weight-example-yaml

```
apiVersion: v1
kind: Pod
metadata:
  name: goweb-demo
spec:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: team
            operator: In
            values:
            - team-a
      preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 1
        preference:
          matchExpressions:
          - key: disktype
            operator: In
            values:
            - ssd
      - weight: 50
        preference:
          matchExpressions:
          - key: disktype
            operator: In
            values:
            - sas
  containers:
  - name: container-goweb-demo
    image: 192.168.11.247/web-demo/goweb-demo:20221229v3
```

kubectl create -f xx.yaml
kubectl get pods -o wide
NAME         READY   STATUS    RESTARTS   AGE   IP              NODE                NOMINATED NODE   READINESS GATES
goweb-demo   1/1     Running   0          35s   10.244.240.18   test-b-k8s-node01   <none>           <none>
 
  </code></pre>
</details>

>>上面的例子,存在两个候选节点,都满足  
preferredDuringSchedulingIgnoredDuringExecution规则  
其中一个节点具有标签disktype:ssd   
另一个节点具有标签disktype:sas,调度器会考察各个节点的weight取值,并将该权重值添加到节点的其他得分值之上  

## 3、nodeSelector案例
<details>
  <summary>nodeSelector-example</summary>
  <pre><code>
设置节点的标签
#给节点打标签,key和value：gpu=true
kubectl label node test-b-k8s-node02 gpu=true
node/test-b-k8s-node02 labeled

#查看指定节点标签
kubectl get node test-b-k8s-node02 --show-labels

#不指定节点时,查看所有节点标签
kubectl get node --show-labels

添加nodeSelector字段到pod配置
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
      nodeSelector:
        gpu: true
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
提示：刚测了一下,非要取这种标签的话gpu=true,在yaml定义时gpu: true ,true就要加双引号,它是字符串,不加的话,他认为是bool。所以,设置node的标签,value以后尽量不要是true/false,非要的话,指定时加上双引号即可  
kubectl get pods -n test-a -o wide
NAME                          READY   STATUS    RESTARTS   AGE   IP              NODE                NOMINATED NODE   READINESS GATES
goweb-demo-69d79997f7-24862   1/1     Running   0          16m   10.244.222.7    test-b-k8s-node02   <none>           <none>
goweb-demo-69d79997f7-48c62   1/1     Running   0          16m   10.244.222.32   test-b-k8s-node02   <none>           <none>
goweb-demo-69d79997f7-76jd9   1/1     Running   0          16m   10.244.222.51   test-b-k8s-node02   <none>           <none>
goweb-demo-69d79997f7-dt7sf   1/1     Running   0          16m   10.244.222.21   test-b-k8s-node02   <none>           <none>
goweb-demo-69d79997f7-fddpd   1/1     Running   0          16m   10.244.222.60   test-b-k8s-node02   <none>           <none>
goweb-demo-69d79997f7-lw2t8   1/1     Running   0          16m   10.244.222.47   test-b-k8s-node02   <none>           <none>
goweb-demo-69d79997f7-nwwkg   1/1     Running   0          16m   10.244.222.10   test-b-k8s-node02   <none>           <none>
goweb-demo-69d79997f7-v768k   1/1     Running   0          16m   10.244.222.38   test-b-k8s-node02   <none>           <none>
goweb-demo-69d79997f7-vgt5w   1/1     Running   0          16m   10.244.222.56   test-b-k8s-node02   <none>           <none>
goweb-demo-69d79997f7-xqhxp   1/1     Running   0          16m   10.244.222.41   test-b-k8s-node02   <none> 

如果创建pod,指派的标签是不存在任何1台节点时,pod会一直处于pending状态,直至进入Terminating状态,pod的重启策略是always（默认策略：当容器退出时,总是重启容器）,则一直在pending和Terminating中徘徊,直到有符合条件的标签,就会立马分配节点,从而创建pod

删除标签
kubectl label node test-b-k8s-node02 gpu-
node/test-b-k8s-node02 unlabeled
提示：key和小横杠之间不能有空格,否则删除失败

  </code></pre>
</details>


[不背锅运维-k8s调度之初探](https://www.toutiao.com/article/7205499274883727927/?log_from=b4eecc0a67019_1679536467971)  


---

# Kubernetes亲和性学习笔记  
## kubernetes默认调度器的调度过程
   - 预选Predicates  
   - 优选Priorities  
   - 选定Select  
## 亲和性一览
![亲和性先分类](https://p3-sign.toutiaoimg.com/tos-cn-i-qvj2lq49k0/10ef4bd0843c4a7989d7a6fcbc5c843f~noop.image?_iz=58558&from=article.pc_detail&x-expires=1680139477&x-signature=3vvNsNgQrwlG15DysmYNJG7hc1c%3D)  

## 节点亲和性和pod亲和性的区别
- 举个例子,假设给小明分配班级（小明是pod,班级是节点）  
  - 节点亲和性：直接告诉小明,你去一年级  
  - pod亲和性：从小朋友中找出和小明同年的,找到了小张,发现小张是一年级的,于是让小明去一年级  
## 节点亲和性：硬亲和性
  - requiredDuringSchedulinglgnoredDuringExecution  #用于定义节点硬亲和性
  - nodeSelectorTerm #节点选择器,可以有多个,之间的关系是逻辑或,即一个nodeSelectorTerm满足即可  
  - matchExpressions #匹配规则定义,多个之间的关系是逻辑与,即同一个nodeSelectorTerm下所有matchExpressions定义的规则都匹配,才算匹配成功
  - 示例  
```
apiVersion: v1
kind: Pod
metadata:
  name: with-required-nodeaffinity
spec:
  affinity:
    nodeAffinity: 
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - {key: zone, operator: In, values: ["foo"]}
  containers:
  - name: nginx
    image: nginx
功能与nodeSelector类似,用的是匹配表达式,可以被理解为新一代节点选择器
不满足硬亲和性条件时,pod为Pending状态
在预选阶段,节点硬亲和性被用于预选策略MatchNodeSelector
```
## 节点亲和性：软亲和性
   - 特点：条件不满足时也能被调度
   - 示例  
```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp-deploy-with-node-affinity
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      name: nginx
      labels:
        app: nginx
    spec:
      affinity:
        nodeAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 60
            preference:
              matchExpressions:
              - {key: zone, operator: In, values: ["foo"]}
          - weight: 30
            preference:
              matchExpressions:
              - {key: ssd, operator: Exists, values: []}
      containers:
      - name: nginx
        image: nginx
```
   - 集群中的节点,由于标签不同,导致的优先级结果如下
   ![t1](https://p3-sign.toutiaoimg.com/tos-cn-i-qvj2lq49k0/a0df3e5f0f594c7e85a1bfc77657c3b7~noop.image?_iz=58558&from=article.pc_detail&x-expires=1680139477&x-signature=pB0SfI6zhyl%2B1XlMe%2B6WkJLiXb8%3D)  
   - 在优选阶段,节点软亲和性被用于优选函数NodeAffinityPriority
   - 注意：NodeAffinityPriority并非决定性因素,因为优选阶段还会调用其他优选函数,例如SelectorSpreadPriority（将pod分散到不同节点以分散节点故障导致的风险）
   - pod副本数增加时,分布的比率会参考节点亲和性的权重   
## Pod亲和性podAffinity
   - 如果需求是：新增的pod要和已经存在pod(假设是A)在同一node上,此时用节点亲和性是无法完成的,因为A可能和节点没啥关系(可能是随机调度的),此时只能用pod亲和性来实现
   - pod亲和性：一个pod与已经存在的某个pod的亲和关系,需要通过举例来说明
   - 创建一个deployment,这个pod有标签app=tomcat： 
     ```
     kubectl run tomcat -l app=tomcat --image tomcat:alpine
     ----
apiVersion: v1
kind: Pod
metadata:
  name: with-pod-affinity-1
spec:
  affinity:
    podAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
      - labelSelector:
          matchExpressions:
          - {key: app, operator: In, values: ["tomcat"]}
        topologyKey: kubernetes.io/hostname
  containers:
  - name: nginx
    image: nginx
     ```
   - 调度逻辑
     ![c](https://p3-sign.toutiaoimg.com/tos-cn-i-qvj2lq49k0/6d71eca8e755470789d7cdc7bdfbe13e~noop.image?_iz=58558&from=article.pc_detail&x-expires=1680139477&x-signature=VoZtfq9vRAuNcBfDlZ728Z9JrIw%3D)  
   - 表面上看,最终只是根据hostname去调度的,但如果topologyKey的值是多个节点所拥有的,就更有通用性了  
     [topologyKey等于filure-domain.beta.kubernetes.io/zone](https://p3-sign.toutiaoimg.com/tos-cn-i-qvj2lq49k0/3b717ee4bb454c91b728218fd56bca00~noop.image?_iz=58558&from=article.pc_detail&x-expires=1680139477&x-signature=0sEV%2Bp7bzeYg2AwjRPQsFMwXU4c%3D)  
   - 硬亲和：requiredDuringSchedulingIgnoredDuringExecution
   - 软亲和：preferredDuringSchedulingIgnoredDuringExecution   
## Pod反亲和podAntiAffinity
   - 与亲和性相反,将当前pod调度到满足匹配条件之外的节点上
   - 适用场景  
     * 分散同一类应用
     * 将不同安全级别的pod调度至不同节点
   - 示例 匹配表达式和自身标签一致,作用是分散同一类应用,让相同pod不要调度到同一个节点  
```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp-with-pod-anti-affinity
spec:
  replicas: 4
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      name: myapp
      labels:
        app: myapp
    spec:
      affinity:
        podAntiAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
          - labelSelector:
              matchExpressions:
              - {key: app, operator: In, values: ["myapp"]}
            topologyKey: kubernetes.io/hostname
      containers:
      - name: nginx
        image: nginx

``` 
   - 如果集群中只有三个节点,那么执行上述yaml的结果就是最多创建三个pod,另一个始终处于pending状态

# 参考
[亲和性](https://www.toutiao.com/article/7213515634276139554/)  
[源码](https://github.com/zq2599/blog_demos)  
[其它](https://www.ssgeek.com/post/kubernetes-pod-diao-du-zhi-qin-he-xing-diao-du/)  

