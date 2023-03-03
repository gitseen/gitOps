# k8s调度之初探nodeSelector和nodeAffinity
**k8s的调度中类型** 
  - 有强制性的nodeSelector
  - 节点亲和性nodeAffinity
  - Pod亲和性podAffinity
  - pod反亲和性podAntiAffinity  

进入主题之前,先看看创建pod的大概过程  
![创建pod流程](https://p3-sign.toutiaoimg.com/tos-cn-i-qvj2lq49k0/01235649687f49ab9c753705c94ec72c~noop.image?_iz=58558&from=article.pc_detail&x-expires=1678325352&x-signature=UV6Rxxr5pBaRgksqFDMfeddJI34%3D)  
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
![eg](https://p3-sign.toutiaoimg.com/tos-cn-i-qvj2lq49k0/cdd26b016dd942f4924d0958a0ce07b6~noop.image?_iz=58558&from=article.pc_detail&x-expires=1678325352&x-signature=kovHYav8gbx2iTSDAtaXrtyFrQ4%3D) 

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
# 设置标签
kubectl label node test-b-k8s-node01 team=team-a
kubectl label node test-b-k8s-node02 team=team-b
kubectl label node test-b-k8s-node01 hostbrand=ibm
kubectl get node --show-labels
kubectl create -f xx.yaml 
kubectl get pod -o wide
NAME         READY   STATUS    RESTARTS   AGE   IP              NODE                NOMINATED NODE   READINESS GATES
goweb-demo   1/1     Running   0          17s   10.244.240.58   test-b-k8s-node01   <none>           <none>
在上面的案例中,所应用的规则如下：
   节点必须包含一个键名为 team 的标签, 并且该标签的取值必须为 team-a 或 team-b
   节点最好具有一个键名为 hostbrand 且取值为 ibm 的标签
关于节点亲和性权重的weight字段：
   preferredDuringSchedulingIgnoredDuringExecution 亲和性类型可以设置 weight 字段,其取值范围是 1 到 100。 当调度器找到能够满足 Pod 的其他调度请求的节点时,调度器会遍历节点满足的所有的偏好性规则, 并将对应表达式的 weight 值加和。
   最终的加和值会添加到该节点的其他优先级函数的评分之上。 在调度器为 Pod 作出调度决定时,总分最高的节点的优先级也最高。

  </code></pre>
</details>

## 2、节点亲和性+带有权重的例子
<details>
  <summary>nodeAffinity-weight-example</summary>
  <pre><code>
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
preferredDuringSchedulingIgnoredDuringExecution 规则  
其中一个节点具有标签 disktype:ssd  
另一个节点具有标签 disktype:sas,调度器会考察各个节点的weight取值,并将该权重值添加到节点的其他得分值之上  

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


[不背锅运维-k8s调度之初探](https://www.google.com/)
