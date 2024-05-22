# kube-scheduler调度概述
K8s中调度是指将Pod调度到合适的节点上,以便对应节点上的Kubelet能够运行这些Pod;  
kube-scheduler将Pod分配(调度)到集群内的各个节点,进而创建容器运行进程;Kube-scheduler是K8s集群默认的调度器

scheduler通过k8s的监测(Watch)机制来发现集群中新创建且尚未被调度到Node上的Pod;  
scheduler主要作用是负责资源的调度Pod,通过APIServer的Watch接口监听新建Pod信息, 按照预定的调度策略将Pod调度到相应的Node节点上;

# kube-scheduler工作原理
## kube-scheduler调度流程
![kube-scheduler调度流程](https://developer.qcloudimg.com/http-save/yehe-4831778/3d73d0046339c223113ce327037866b4.png) 

1. scheduler维护待调度的podQueue并监听APIServer;
   >用户提交pod资源请求;可以通过APIServer的RESTAPI,也可用Kubectl命令行工具支持Json和Yaml两种格式  
2. 创建Pod时首先通过APIServer将Pod元数据写入etcd(APIServer处理用户请求,存储Pod数据到Etcd)  
3. scheduler通过Informer监听Pod状态添加新的Pod时,会将Pod添加到podQueue;podQueue中提取Pods并按照一定的算法将节点分配给Pods;  
   >schedule调度pod：schedule通过APIServer的watch机制,实时查看到新的pod,按照预定的调度策略将Pod调度到相应的Node节点上    
   - 过滤主机(节点预选)  
     调度器用一组规则过滤掉不符合要求的主机;比如Pod指定了所需要的资源,么就要过滤掉资源不够的主机从而完成节点的预选  
   - 主机打分(节点优选)  
     对第一步筛选出的符合要求的主机进行打分,在主机打分阶段,调度器会考虑一些整体优化策略;  
     比如把一个RC的副本分布到不同的主机上,使用最低负载的主机等；对预选出的节点进行优先级排序,以便选出最合适运行Pod对象的节点  
   - 选择主机(节点选定)  
     选择打分最高的主机,进行binding操作,结果存储到Etcd中;  
4. node的kubelet也侦听ApiServer如果发现有新的Pod已调度到该节点,则将通过CRI调用高级容器运行时来运行容器;kubelet创建pod
   >kubelet根据schedule调度结果执行Pod创建操作: 
   调度成功后,会启动container, docker run, scheduler会调用APIServer的API在etcd中创建一个boundpod对象,描述在一个工作节点上绑定运行的所有pod信息;  
     运行在每个工作节点上的kubelet也会定期与etcd同步boundpod信息,一旦发现应该在该工作节点上运行的boundpod对象没有更新,则调用DockerAPI创建并启动pod内的容器
 ## [工作原理](https://zhuanlan.zhihu.com/p/339762721)
 ![原理](https://pic1.zhimg.com/80/v2-5e83986aa2469097db5b418d8eac0c50_720w.webp)  
 ![扩展点](https://pic3.zhimg.com/80/v2-a6c4f85223ed8af451710182c62e7a4a_720w.webp)  
如上图所示,我们简单介绍一下支持的扩展点：  
- QueueSort: 对队列中的 Pod 进行排序
- PreFilter: 预处理 Pod 的相关信息,或者检查集群或 Pod 必须满足的某些条件。 如果 PreFilter 插件返回错误,则调度周期将终止。
- Filter: 过滤出不能运行该 Pod 的节点。对于每个节点, 调度器将按照其配置顺序调用这些过滤插件。如果任何过滤插件将节点标记为不可行, 则不会为该节点调用剩下的过滤插件。节点可- 以被同时进行评估。
- PostFilter: 在筛选阶段后调用,但仅在该 Pod 没有可行的节点时调用。 插件按其配置的顺序调用。如果任何后过滤器插件标记节点为“可调度”, 则其余的插件不会调用。典型的后筛选实现- 是抢占,试图通过抢占其他 Pod 的资源使该 Pod 可以调度。
- PreScore: 运行评分任务以生成可评分插件的共享状态
- Score: 通过调用每个评分插件对过滤的节点进行排名
- NormalizeScore: 结合分数并计算节点的最终排名
- Reserve: 在绑定周期之前选择保留的节点
- Permit: 批准或拒绝调度周期的结果
- PreBind: 用于执行 Pod 绑定前所需的任何工作。例如,一个预绑定插件可能需要提供网络卷并且在允许 Pod 运行在该节点之前 将其挂载到目标节点上。
- Bind: 用于将 Pod 绑定到节点上。直到所有的 PreBind 插件都完成,Bind 插件才会被调用。
- PostBind: 这是个信息性的扩展点。 绑定后插件在 Pod 成功绑定后被调用。这是绑定周期的结尾,可用于清理相关的资源  

**scheduler调度pod选择包含两个步骤**  
- 预选(过滤)
  >过滤阶段会将所有满足Pod调度需求的Node选出来
  
- 优选(打分)
  >scheduler会为Pod从所有可调度节点中选取一个最合适的Node根据当前启用的打分规则,scheduler会给每一个可调度节点进行打分  
  最后scheduler会将Pod调度到得分最高的Node上;如果存在多个得分最高的Node,scheduler会从中随机选取一个  

**预选策略Predicates**
- PodFitsHostPorts：检查Pod容器所需的HostPort是否已被节点上其它容器或服务占用,如已被占用,则禁止Pod调度到该节点  
- PodFitsHost：检查Pod指定的NodeName是否匹配当前节点  
- PodFitsResources：检查节点是否有足够空闲资源(例如CPU和内存)来满足Pod的要求  
- PodMatchNodeSelector：检查Pod的节点选择器(nodeSelector)是否与节点(Node)的标签匹配  
- NoVolumeZoneConflict：对于给定的某块区域,判断如果在此区域的节点上部署Pod是否存在卷冲突  
- NoDiskConflict：根据节点请求的卷和已经挂载的卷,评估Pod是否适合该节点   
- MaxCSIVolumeCount：决定应该附加多少CSI卷,以及该卷是否超过配置的限制  
- CheckNodeMemoryPressure：如果节点内存压力,并且没有配置异常,那么将不会往那里调度Pod  
- CheckNodePIDPressure：如果节点报告进程id稀缺,并且没有配置异常,那么将不会往那里调度Pod  
- CheckNodeDiskPressure：如果节点报告存储压力(文件系统已满或接近满),并且没有配置异常,那么将不会往那里调度Pod  
- CheckNodeCondition：节点报告的文件系统网络不可用,或者kubelet没有准备好运行Pods,如果为节点设置了这样的条件,并且没有配置异常,那么将不会往那里调度Pod  
- PodToleratesNodeTaints：检查Pod的容忍度是否能容忍节点的污点  
- CheckVolumeBinding：评估Pod是否适合它所请求的容量,这适用于约束和非约束PVC  

>**如果在predicates(预选)过程中没有合适的节点,那么Pod会一直在pending状态,不断重试调度,直到有节点满足条件;  
经过这个步骤,如果有多个节点满足条件,就继续priorities过程,最后按照优先级大小对节点排序** 
 
**优选Priorities**
- SelectorSpreadPriority：对于属于同一服务、有状态集或副本集（Service,StatefulSet or ReplicaSet）的Pods,会将Pods尽量分散到不同主机上。
- InterPodAffinityPriority：策略有podAffinity和podAntiAffinity两种配置方式。简单来说,就说根据Node上运行的Pod的Label来进行调度匹配的规则,匹配的表达式有：In, NotIn, - Exists, DoesNotExist,通过该策略,可以更灵活地对Pod进行调度。
- LeastRequestedPriority：偏向使用较少请求资源的节点。换句话说,放置在节点上的Pod越多,这些Pod使用的资源越多,此策略给出的排名就越低。
- MostRequestedPriority：偏向具有最多请求资源的节点。这个策略将把计划的Pods放到整个工作负载集所需的最小节点上运行。
- RequestedToCapacityRatioPriority：使用默认的资源评分函数模型创建基于ResourceAllocationPriority的requestedToCapacity。
- BalancedResourceAllocation：偏向具有平衡资源使用的节点。
- NodePreferAvoidPodsPriority：根据节点注释scheduler.alpha.kubernet .io/preferAvoidPods为节点划分优先级。可以使用它来示意两个不同的Pod不应在同一Node上运行。
- NodeAffinityPriority：根据preferredduringschedulingignoredingexecution中所示的节点关联调度偏好来对节点排序。
- TaintTolerationPriority：根据节点上无法忍受的污点数量,为所有节点准备优先级列表。此策略将考虑该列表调整节点的排名。
- ImageLocalityPriority：偏向已经拥有本地缓存Pod容器镜像的节点。
- ServiceSpreadingPriority：对于给定的服务,此策略旨在确保Service的Pods运行在不同的节点上。总的结果是,Service对单个节点故障变得更有弹性。
- EqualPriority：赋予所有节点相同的权值1。
- EvenPodsSpreadPriority：实现择优 pod的拓扑扩展约束
>[官网地址](https://kubernetes.io/zh-cn/docs/reference/scheduling/)  
[k8s中kube-scheduler的调度过程](https://www.toutiao.com/article/7345759512613421568/)  
[聊聊kube-scheduler如何完成调度和调整调度权重](https://www.toutiao.com/article/7313829073661739520/)  
[kube-scheduler调度器原理](https://www.toutiao.com/article/7182031810707210807/)  


# k8s调度Pod的主要方式
- 自动调度：运行在哪个节点上完全由Scheduler经过一系列的算法计算得出(默认kube-scheduler)  
- 定向调度:  [NodeName](https://github.com/gitseen/gitOps/blob/main/k8s/k8s-scheduler.md#NodeName)、[NodeSelector](https://github.com/gitseen/gitOps/blob/main/k8s/k8s-scheduler.md#NodeSelector)  
- 亲和性调度： [NodeAffinity](https://github.com/gitseen/gitOps/blob/main/k8s/k8s-scheduler.md#NodeAffinity)、[PodAffinity](https://github.com/gitseen/gitOps/blob/main/k8s/k8s-scheduler.md#PodAffinity)、[PodAntiAffinity](https://github.com/gitseen/gitOps/blob/main/k8s/k8s-scheduler.md#PodAntiAffinity)  
- 污点(容忍)调度： [Taints](https://github.com/gitseen/gitOps/blob/main/k8s/k8s-scheduler.md#Taints)、[Toleration](https://github.com/gitseen/gitOps/blob/main/k8s/k8s-scheduler.md#Toleration) 
- [Pod拓扑分布约束](https://github.com/gitseen/gitOps/blob/main/k8s/k8s-scheduler.md#Pod拓扑分布约束)  
- [自定义调度器my-scheduler](https://github.com/gitseen/gitOps/blob/main/k8s/k8s-scheduler.md#自定义调度器my-scheduler)  

---

<table><tr><td bgcolor=green>定向调度nodeName、nodeSelector</td></tr></table>  

# NodeName
nodeName属于定向调度(通过nodeName匹配规则是强制匹配);nodeName(直接指定node主机名)   

Pod.spec.nodeName强制约束将Pod调度到指定的Node上,其实指定了nodeName的Pod会直接跳过Scheduler的调度逻辑,直接写入PodList列表  
<details>
  <summary>nodeName调度-指定nodeName调度到指定节点上</summary>
  <pre><code>
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: springbootweb
  name: springbootweb-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: springbootweb
  template:
    metadata:
      labels:
        app: springbootweb
    spec:
      nodeName: node23.turing.com   #指定调度到node23.turing.com节点上
      containers:
      - image: registry.tuling123.com/springboot:latest
        imagePullPolicy: IfNotPresent
        name: springbootweb
        ports:
        - containerPort: 9081
          hostPort: 9981     
      imagePullSecrets:
      - name: registry-key-secret
  </code></pre>
</details>  

>1 如果指定的节点不存在,则容器将不会运行,并且在某些情况下可能会自动删除  
 2 如果指定的节点没有足够的资源来容纳该Pod,则该Pod将会失败,并且其原因将被指出,例如OutOfmemory或OutOfcpu  
 3 云环境中的节点名称并非总是可预测或稳定的   



# NodeSelector
nodeSelector定向调度(通过标签匹配)  
nodeSelector(节点选择器,为Node打上标签,然后Pod中通过nodeSelector选择打上标签的Node)  
<details>
  <summary>nodeSelector调度</summary>
  <pre><code>
#kubectl label nodes k8s-node-1 zone=north  打标签
#kubectl label node  k8s-node-1 zone-       删除标签
#kubectl get node --show-labels
apiVersion:v1
kind: Pod
metadata:
  name: redis-master
  label:
    name: redis-master
spec:
  replicas: 1
  selector:
    name: redis-master
    template:
      metadata:
        labels:
          name: redis-master
      spec:
        containers:
        - name: redis-master
          images: kubeguide/redis-master
          ports:
          - containerPort: 6379
        nodeSelector:    #匹配zone: north标签的节点K:V  这里指定Node的Label
          zone: north
  </code></pre>
</details>

>如果nodeSelector匹配的标签不存在,则容器将不会运行,一直处于Pending状态  
nodeName、nodeSelector属于定向调度  

---

<table><tr><td bgcolor=green>亲和性调度nodeAffinity、podAffinity、podAntiAffinity</td></tr></table>  

**Affinity亲和性调度分类** 
- nodeAffinity(node亲和性): 以node为目标,解决pod可以调度到哪些node的问题 
- podAffinity(pod亲和性): 以pod为目标,解决pod可以和哪些已存在的pod部署在同一个拓扑域中的问题   
- podAntiAffinity(pod反亲和性): 以pod为目标,解决pod不能和哪些已存在pod部署在同一个拓扑域中的问题   

>关于亲和性(反亲和性)使用场景的说明  
亲和性  
  如果两个应用频繁交互,那就有必要利用亲和性让两个应用的尽可能的靠近,这样可以减少因网络通信而带来的性能损耗  
反亲和性  
  当应用的采用多副本部署时,有必要采用反亲和性让各个应用实例打散分布在各个node上,这样可以提高服务的高可用性  

# NodeAffinity
nodeAffinity用于定义Pod与节点之间的亲和性;控制Pod被调度到具有特定标签或属性的节点上  
nodeAffinity节点亲和性功能类似于nodeSelector(通过Node的Label进行精确匹配)字段,但它的表达能力更强,并且允许你指定软规则;  
nodeAffinity增加了In、NotIn、Exists、DoesNotexist、Gt、Lt等操作符来选择Node;调度侧露更加灵活  

- nodeAffinity的亲和性表达  
  + 硬限制：requiredDuringSchedulingIgnoredDuringExecution  
    ```bash
    必须满足指定的规则才可以调度Pod到node上,相当于硬限制; 
    调度器只有在规则被满足的时候才能执行调度。此功能类似于nodeSelector,但其语法表达能力更强
    ```
  + 软限制：preferredDuringSchedulingIgnoredDuringExecution  
    ```bash
    强调优先满足指定规则,调度器会尝试调度Pod到Node上,但并不强求,相当于软限制
    调度器会尝试寻找满足对应规则的节点,如果找不到匹配的节点,调度器仍然会调度该Pod
    多个优先级规则还可以设置权重(weight)值,以此来定义执行的先后顺序
    ```
  + 节点亲和性权重  
    ```bash
    preferredDuringSchedulingIgnoredDuringExecution亲和性类别的每个实例设置weight字段,取值范围是1 ~ 100;
    当调度器找到能够满足Pod的其他调度请求的节点时,调度器会遍历节点满足的所有的偏好性规则,并将对应表达式的weight值加和;
    最终的加和值会添加到该节点的其他优先级函数的评分之上;在调度器为Pod做出调度决定时,总分最高的节点的优先级也最高
    ```
  + IgnoredDuringExecution 
    如一个Pod所在的节点在Pod运行期间标签发生了变更,不再符合该Pod的节点亲和性需求,则系统将忽略Node上label的变化,该Pod能继续在该节点运行
    >IgnoredDuringExecution意味着如果节点标签在K8s调度Pod后发生了变更,Pod仍将继续运行  

- nodeAffinity的语法规则  
  nodeAffinity语法支持的操作符包括In,NotIn,Exists,DoesNotExist,Gt,Lt;
  虽然没有节点排斥功能,但是用NotIn和DoesNotExist就可以实现排斥的功能了
   ```bash
  In：label的值在某个列表中
  NotIn：label的值不在某个列表中
  Gt：label的值大于某个值
  Lt：label的值小于某个值
  Exists：某个label存在
  DoesNotExist：某个label不存在
  ```
  **关系符使用说明: matchExpressions**  
  ```bash
  + key: nodeenv         # 匹配存在标签的key为nodeenv的节点  
    operator: Exists  
  + key: nodeenv         # 匹配标签的key为nodeenv,且value是"k"或"v"的节点  
    operator: In  
    values: "k","v"  
  + key: nodeenv         # 匹配标签的key为nodeenv,且value大于"k"的节点  
    operator: Gt  
    values: "k"   
  ```
- nodeAffinity的注意事项  
>如同时定义了nodeSelector和nodeAffinity那么必须两个条件都得到满足,Pod才能最终运行到指定的Node上  
如nodeAffinity指定了多个nodeSelectorTerms,那么其中一个能够匹配成功即可  
如在nodeSelectorTerms中有多个matchExpressions,则一个节点必须满足所有matchExpressions才能运行该Pod  

<details>
  <summary>requiredDuringSchedulingIgnoredDuringExecution-nodeSelectorTerms硬限制</summary>
  <pre><code>
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
              - matchExpressions:
                  - key: disktype
                    operator: In
                    values:
                      - ssd
      containers:
        - name: nginx
          image: nginx
#nodeAffinity调度pod到具有disktype: ssd标签的节点上;硬限制
  </code></pre>
</details>

<details>
  <summary>requiredDuringSchedulingIgnoredDuringExecution-weight-不强制</summary>
  <pre><code>
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      affinity:
        nodeAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 1
            preference:
              matchExpressions:
                - key: disktype
                  operator: In
                  values:
                    - ssd
      containers:
        - name: nginx
          image: nginx
#preferredDuringSchedulingIgnoredDuringExecution调度器会尽量但不强制将Pod调度到具有disktype: ssd标签的节点上
  </code></pre>
</details>



<details>
  <summary>preferredDuringSchedulingIgnoredDuringExecution优先调度(32G-->16G-->8G内存节点)</summary>
  <pre><code>
spec:
  containers:
  - name: xxxxx
    image: xxxxx
  affinity:
    nodeAffinity:
      preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 20
        preference:
          matchExpressions:
          - key: mem
            operator: In
            values:
            - memory32
      - weight: 10
        preference:
          matchExpressions:
          - key: mem
            operator: In
            values:
            - memory16
      - weight: 1
        preference:
          matchExpressions:
          - key: mem
            operator: In
            values:
            - memory8
  </code></pre>
</details>



---
<table><tr><td bgcolor=green>污点(容忍)调度</td></tr></table>  


<table><tr><td bgcolor=green>Pod拓扑分布约束</td></tr></table>  

<table><tr><td bgcolor=green>自定义调度器my-scheduler</td></tr></table>  




