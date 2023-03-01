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

# 2、HPA实现原理  
**使用HPA生效前提**   
- 必须定义requests参数  
- 必须安装metrics-server  
## 2.1 流程
- 1、创建HPA资源,设定目标CPU使用率限额,以及最大、最小实例数
- 2、收集一组中(PodSelector)每个Pod最近一分钟内的CPU使用率,并计算平均值
- 3、读取HPA中设定的CPU使用限额
- 4、计算：平均值之和/限额,求出目标调整的实例个数
- 5、目标调整的实例数不能超过1中设定的最大、最小实例数,如果没有超过,则扩容；超过,则扩容至最大的实例个数
- 6、回到2,不断循环;HPA通过kube-controller-manager定期(定期轮询的时间通过horizontal-pod-autoscaler-sync-period选项来设置,默认的时间为30秒)  
     如果指标变化太频繁,也可以使用--horizontal-pod-autoscaler-downscale-stabilization指令设置扩缩容延迟时间,表示是自从上次缩容执行结束后,多久可以再次执行缩容,默认是5m   
     >>算法说明  
    desiredReplicas = ceil[currentReplicas * ( currentMetricValue / desiredMetricValue )] currentMetricValue表示当前度量值,desiredMetricValue表示期望度量值,desiredReplicas表示期望副本数  
    例如,当前度量值为200m,目标设定值为100m,那么由于200.0/100.0 == 2.0, 副本数量将会翻倍。 如果当前指标为50m,副本数量将会减半,因为50.0/100.0 == 0.5  

 


  
