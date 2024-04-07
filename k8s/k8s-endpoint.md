# [k8s-k8s endpoint](https://www.toutiao.com/article/7353619670840230410/)
Kubernetes(k8s)中,Endpoint是一个核心概念,它代表了一组可访问的网络端点,这些端点通常是一组Pod的IP地址和端口,用于实现Service到Pod的网络流量转发。  

## k8s-Endpoint的作用
- 1、服务发现：  
    - Endpoint使得Service能够找到后端的Pod,即使这些Pod是动态变化的。当Pod被创建或删除时,Endpoint会自动更新,以确保Service总是指向正确的Pod。
- 2、负载均衡：
    - Endpoint配合Service使用,可以实现负载均衡。当外部请求到达Service时,Service会根据Endpoint提供的Pod列表进行负载均衡,将流量分发到不同的Pod上。
- 3、网络抽象：
    - Endpoint 提供了网络抽象,使得客户端不需要知道后端Pod的具体信息,只需通过Service来访问。

## k8s-Endpoint的工作原理
- 1、当你创建一个Service时,Kubernetes会自动创建一个与之关联的Endpoint对象。
- 2、Endpoint控制器会监视Service的选择器（selector）,并根据选择器找到所有匹配的Pod。
- 3、Endpoint控制器会将这些Pod的IP地址和端口信息存储在Endpoint对象中。
- 4、当Service接收到流量时,它会将流量转发到Endpoint中的一个Pod。


## k8s-Endpoint的类型
- 1、ClusterIP：
  - 默认的Endpoint类型,它在集群内部提供一个虚拟IP地址,用于服务发现和负载均衡。
- 2、NodePort：
  - 在集群的所有节点上打开一个端口,将外部流量转发到Service的ClusterIP。
- 3、LoadBalancer：
  - 为Service分配一个外部负载均衡器,自动配置云提供商的负载均衡服务。
- 4、ExternalName：
  - 允许将Service定义为对外部服务的引用,例如,将Service指向一个外部数据库的DNS名称。  

Endpoint是Kubernetes网络模型的重要组成部分,它简化了服务之间的通信和网络配置管理。通过使用Endpoint,你可以确保应用程序的高可用性和可扩展性。
