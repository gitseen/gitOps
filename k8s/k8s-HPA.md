# k8s-弹性伸缩
弹性伸缩主要解决的问题是容量规划与实际负载的矛盾  

云计算为云原生中提供的优势之一就是弹性能力  

从Kubernetes实战出发,不管是在业务稳定性保障还是成本治理角度,弹性扩缩容能力都是必要研究方向  

当实际的负载随着业务量访问增大,而逐渐的向集群的资源瓶颈靠拢的时候,接近的时候,能不能快速的响应,来扩容集群的流量,从而来应对这种突发  

Kubernetes平台中,资源弹性分为两个维度  
   - Node级别  
     针对Node负载,当集群资源池不足时,可以使用CA（Cluster Autoscaler）自动增加Node  
   - Pod级别   
     针对Pod负载,当Pod资源不足时,可以使用HPA(Horizontal Pod Autoscaler)自动增加Pod副本数量  

**水平扩缩容方案HPA和KEDA**   

# 1、HPA介绍
## 1.1 HPA(HorizontalPodAutoscaler)水平自动扩缩容
  - 适用对象：Deployment、StatefulSet等  
  - 不适用对象：无法扩缩的对象,例如DaemonSet  
## 1.2 HPA的演进历程
  - autoscaling/v1          #只支持基于CPU指标的缩放
  - autoscaling/v2beta1     #支持Resource Metrics(资源指标,如pod的CPU)和Custom Metrics(自定义指标)的缩放
  - autoscaling/v2beta2     #支持Resource Metrics(资源指标,如pod的CPU)和Custom Metrics(自定义指标)和ExternalMetrics(额外指标的缩放
## 1.3 HPA四种类型的指标
  - Resource
  - Object
  - External
  - Pods  

通过kubectl api-versions |grep autoscal 查看集群内支持的版本
```
kubectl api-versions |grep autoscal
autoscaling/v1
autoscaling/v2beta1
autoscaling/v2beta2
```
## 1.4 HPA中metrics类型介绍
**HPA中 metrics中的type字段有四种类型的值：Object、Pods、Resource、External**    

<details>
  <summary>Resource</summary>
  <pre><code>
Resource：指的是当前伸缩对象下的pod的cpu和memory指标,只支持Utilization(使用率)和AverageValue类型的目标值
  # Resource类型的指标
  - type: Resource
    resource:
      name: cpu
      # Utilization类型的目标值,Resource类型的指标只支持Utilization和AverageValue类型的目标值
      target:
        type: Utilization
        averageUtilization: 50
  </code></pre>
</details>

<details>
  <summary>Object</summary>
  <pre><code>
Object：指的是指定k8s内部对象的指标,数据需要第三方adapter提供,只支持Value和AverageValue类型的目标值
  # Object类型的指标
  - type: Object
    object:
      metric:
        # 指标名称
        name: requests-per-second
      # 监控指标的对象描述,指标数据来源于该对象
      describedObject:
        apiVersion: networking.k8s.io/v1beta1
        kind: Ingress
        name: main-route
      # Value类型的目标值,Object类型的指标只支持Value和AverageValue类型的目标值
      target:
        type: Value
        value: 10k
  </code></pre>
</details>

<details>
  <summary>pods</summary>
  <pre><code>
Pods：指的是伸缩对象Pods的指标,数据需要第三方的adapter提供,只允许AverageValue类型的目标值
  # Pods类型的指标
  - type: Pods
    pods:
      metric:
        name: packets-per-second
      # AverageValue类型的目标值,Pods指标类型下只支持AverageValue类型的目标值
      target:
        type: AverageValue
        averageValue: 1k
  </code></pre>
</details>

<details>
  <summary>External</summary>
  <pre><code>
External：指的是k8s外部的指标,数据同样需要第三方的adapter提供,只支持Value和AverageValue类型的目标值
  # External类型的指标
  - type: External
    external:
      metric:
        name: queue_messages_ready
        # 该字段与第三方的指标标签相关联,（此处官方文档有问题,正确的写法如下）
        selector:
          matchLabels:
            env: "stage"
            app: "myapp"
      # External指标类型下只支持Value和AverageValue类型的目标值
      target:
        type: AverageValue
        averageValue: 30
  </code></pre>
</details>

## 1.5 HPA实现原理  
**使用HPA生效前提**   
- 必须定义requests参数  
- 必须安装metrics-server  
### 1.5.1 流程
- 1、创建HPA资源,设定目标CPU使用率限额,以及最大、最小实例数
- 2、收集一组中(PodSelector)每个Pod最近一分钟内的CPU使用率,并计算平均值
- 3、读取HPA中设定的CPU使用限额
- 4、计算：平均值之和/限额,求出目标调整的实例个数
- 5、目标调整的实例数不能超过1中设定的最大、最小实例数,如果没有超过,则扩容；超过,则扩容至最大的实例个数
- 6、回到2,不断循环;HPA通过kube-controller-manager定期(定期轮询的时间通过horizontal-pod-autoscaler-sync-period选项来设置,默认的时间为30秒)  
     如果指标变化太频繁,也可以使用--horizontal-pod-autoscaler-downscale-stabilization指令设置扩缩容延迟时间,表示是自从上次缩容执行结束后,多久可以再次执行缩容,默认是5m   
     >>算法说明  
    desiredReplicas = ceil[currentReplicas * ( currentMetricValue / desiredMetricValue )]   
    currentMetricValue表示当前度量值,desiredMetricValue表示期望度量值,desiredReplicas表示期望副本数  
    例如,当前度量值为200m,目标设定值为100m,那么由于200.0/100.0 == 2.0, 副本数量将会翻倍。 如果当前指标为50m,副本数量将会减半,因为50.0/100.0 == 0.5   

![HPA原理](https://p3-sign.toutiaoimg.com/tos-cn-i-qvj2lq49k0/72c66064ee5b4526a565bfc06a6b3147~noop.image?_iz=58558&from=article.pc_detail&x-expires=1678179285&x-signature=GNBFlk1oDi3U%2Ftk3YUYoFds4GH4%3D)  

### 1.5.2 弹性伸缩实例
**为nginx服务创建一个HPA资源,当时nginx服务CPU使用率超过30%时则触发水平扩容机制(依赖metrics数据,集群中需要提前部署好metrics-server)** 
<details>
  <summary>k8s-hpa-example</summary>
  <pre><code>
apiVersion: apps/v1 
kind: Deployment
metadata:
  name: nginx-hpa
  labels:
    app: nginx-hpa
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx-hpa  
  template:
    metadata:
      labels:
        app: nginx-hpa
    spec:
      containers:
      - name: nginx-hpa
        image: nginx:1.7.9 
        ports:
        - containerPort: 80
        resources:
          requests:                         ##必须设置,不然HPA无法运行。
            cpu: 200m
---
apiVersion: v1
kind: Service
metadata:
  labels:
    app: nginx-hpa
  name: nginx-hpa
spec:
  ports:
  - port: 80
    protocol: TCP
    targetPort: 80
  selector:
    app: nginx-hpa     
---
kind: HorizontalPodAutoscaler
metadata:
  name: nginx-hpa-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: nginx-hpa
  minReplicas: 1
  maxReplicas: 3
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 30

#也可以通过kubectl autoscale来创建HPA对象 
#将会为名为nginx-hpa的ReplicationSet创建一个HPA对象,目标CPU使用率为%,副本数量配置为1到3之间
kubectl autoscale rs nginx-hpa --min=1 --max=3 --cpu-percent=30 

使用ab命令创建一个简易http服务压测逻辑
yum install httpd -y
for i in {1..600}
do
    ab -c 1000 -n 100000000 http://ServiceIP/
    sleep $i
done
  </code></pre>
</details> 

### 1.5.3 HPA实现局限性
- 1、HPA 无法将pod实例缩到0,即不能从n->0,或者从0-1  
      根据算法实现说明可以看出desiredReplicas = ceil[currentReplicas * ( currentMetricValue / desiredMetricValue )]  
      desiredMetricValue作为分母,期望值不能是'0'；currentMetricValue当前值是'0'的时候,任务数乘'0'都为零  
- 2、使用率计算方式在Resource类型中,使用率计算是通过request而不是limit,如果按照request来计算使用率(会超过100%)是不符合预期的。但也是可以修改源码,或者使用自定义指标来代替  
- 3、多容器Pod使用率问题1.20版本中已经支持了ContainerResource可以配置基于某个容器的资源使用率来进行扩缩,如果是之前的版本建议使用自定义指标替换
- 4、性能问题  
      单线程架构：默认的hpa-controller是单个Goroutine执行的,随着集群规模的增多,势必会成为性能瓶颈
      目前默认hpa资源同步周期会15s,假设每个metric请求延时为100ms,当前架构只能支持150个HPA资源(保证在15s内同步一次)
 


# 2、KEDA 
## 2.1 KEDA是什么?KEDA和HPA是什么关系  
KEDA是一个基于Kubernetes的事件驱动自动扩缩器。它为Kubernetes资源提供了30多个内置缩放器，因此我们不必担心为我们需要的各种指标源编写自定义适配器   
KEDA提供了将资源扩展到零的强大功能。KEDA可以将资源从0扩展到,1或从1扩展到0，从1到n以及向后扩展由HPA负责   
KEDA安装使用要求Kubernetes集群1.16或以上版本  

KEDA和HPA是什么关系：既生瑜何生亮,主要是HPA这哥们天生有缺陷，无法基于灵活的事件源进行伸缩，KEDA去帮助实现，当然没有一个事物诞生是完美的，只有在特定的场景下才能相较谁更完美  

## 2.2 KEDA实现原理
**KEDA哪些核心组件**  
- Metrics Adapter： 将 Scaler 获取的指标转化成 HPA 可以使用的格式并传递给  
- HPA Controller：负责创建和更新一个HPA对象，并负责扩缩到零  
- Scaler：连接到外部组件(例如Prometheus或者例如，RabbitMQ并获取指标(例如，待处理消息队列大小))获取指标KEDA实现  
![k8s-keda原理](https://p3-sign.toutiaoimg.com/tos-cn-i-qvj2lq49k0/08d5a06c06ab41e19ac318a0403edfac~noop.image?_iz=58558&from=article.pc_detail&x-expires=1678241117&x-signature=b7YY%2BJpTkx2T%2Bt92Yd8PTTUSXF0%3D)  

## 2.2 KEDA配置
```
kubectl apply -f https://github.com/kedacore/keda/releases/download/v2.4.0/keda-2.6.1.yaml
```
组件介绍keda-operator负责创建维护hpa对象资源，同时激活和停止hpa伸缩   
在无事件的时候将副本数降低为0(如果未设置minReplicaCount的话)   
keda-metrics-apiserver实现了hpa中external metrics，根据事件源配置返回计算结果  
创建ScaledObject资源  

<details>
  <summary>k8s-keda-example</summary>
  <pre><code>
apiVersion: keda.sh/v1alpha1
# 由 Keda 运营商提供的自定义 CRD
kind: ScaledObject
metadata:
  name: nginx-scaledobject
  namespace: hpa-tmp
spec:
  advanced:
    # HPA config
    # Read about it here: https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/
    horizontalPodAutoscalerConfig:
      behavior:
        scaleDown:
          policies:
          - periodSeconds: 30
            type: Pods
            value: 1
          stabilizationWindowSeconds: 30
        scaleUp:
          policies:
          - periodSeconds: 10
            type: Pods
            value: 1
          stabilizationWindowSeconds: 0
  # 在将部署缩放回 1 之前，最后一个触发报告活动后等待的时间
  cooldownPeriod: 30
  # keda 将扩展到的最大副本数
  maxReplicaCount: 3
  # keda 将扩展到的最小副本数
  minReplicaCount: 1
  # 查询 Prometheus 的时间间隔
  pollingInterval: 15
  scaleTargetRef:
  # 针对哪个deployment
    name: nginx-hpa
  triggers:
  - type: cpu
    metadata:
      type: Utilization
      value: "30"  
#deployment复用上文nginx-hpa，创建好ScaledObject后会自动创建出hpa资源
更多type类型配置介绍
通过多个指标控制更精准的控制扩缩容动作，支持Prometheus指标、Metrics-server指标、计划任务指标等
    triggers:
    - metadata:
      # Prometheus指标支持
        metricName: istio_request_qps_1m
        query: istio_request_qps_1m{app_name="test-hpa"}
        serverAddress: http://prometheus-service.monitoring.svc.cluster.local:9090
        threshold: "100"
      name: istio-qps-trigger  
      type: prometheus
    - metadata:
      # metrics-server 指标支持
        type: AverageValue
        value: "10"
      name: cpu-trigger
      type: cpu
    - metadata:
      # 计划任务指标支持
        desiredReplicas: "3"
        end: 45 * * * *
        start: 40 * * * *
        timezone: Asia/Shanghai
      type: cron
  </code></pre>
</details>

# 参考
[HPA-闪念基因](https://www.toutiao.com/article/7205015057346888244)  
[KEDA相关](https://github.com/kedacore/keda  https://keda.sh/)
