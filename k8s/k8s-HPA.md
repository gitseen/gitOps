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

# HPA实现原理HPA介绍
## HPA(HorizontalPodAutoscaler)水平自动扩缩容
  - 适用对象：Deployment、StatefulSet等  
  - 不适用对象：无法扩缩的对象,例如DaemonSet  
## HPA的演进历程
  - autoscaling/v1          #只支持基于CPU指标的缩放
  - autoscaling/v2beta1     #支持Resource Metrics（资源指标,如pod的CPU）和Custom Metrics（自定义指标）的缩放
  - autoscaling/v2beta2     #支持Resource Metrics（资源指标,如pod的CPU）和Custom Metrics（自定义指标）和ExternalMetrics（额外指标）的缩放
## HPA四种类型的指标
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

