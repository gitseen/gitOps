# Welcome to k8s
![free](https://p3-sign.toutiaoimg.com/tos-cn-i-qvj2lq49k0/dd05af2377a94127b4bdf9dd31e70929~noop.image?_iz=58558&from=article.pc_detail&x-expires=1677638272&x-signature=HnjacwT5vK8NkO1EigZ7Qy9jkks%3D) 
# 集群架构(物理+逻辑）
![k8s](pic/k8s.png)  
# 集群高可用
![cluster](https://d33wubrfki0l68.cloudfront.net/d1411cded83856552f37911eb4522d9887ca4e83/b94b2/images/kubeadm/kubeadm-ha-topology-stacked-etcd.svg)  

# [Official-website](https://kubernetes.io/zh-cn/docs/setup/production-environment/tools/kubeadm/ha-topology/)

# [k8s架构-wljslmz](https://www.toutiao.com/article/7399959706342523430/)

---

# Kube-APIServer
**Kube-APIServer是Kubernetes控制平面的核心组件,负责处理所有的REST操作,暴露KubernetesAPI.它是整个集群的前端,所有的控制请求都要经过它**  
**功能**
- **验证和授**  
  Kube-APIServer 负责验证用户的身份,并根据配置的访问控制策略进行授权,确保只有合法的请求才能对集群进行操作
- **集群状态管理**  
  APIServer 是集群的状态中心,所有的集群状态信息都通过它来访问和更新
- **通信枢纽**  
  Kube-APIServer是其他控制平面组件和工作节点与集群进行通信的桥梁。所有的组件和节点都通过它来获取和更新集群状态
```bash
当用户或其他组件向Kube-APIServer发送请求时,APIServer首先进行身份验证和授权检查,然后对请求的数据进行验证和处理;处理完成后,APIServer会将数据存储到etcd中,同时通知其他组件进行相应的操作
```

# ETCD
**Etcd是一个分布式键值存储,用于存储Kubernetes集群的所有数据,它是Kubernetes集群的源数据存储系统,所有的配置信息、状态信息都存储在etcd中**  
**功能**
- **数据存储**  
    Etcd负责存储所有的集群状态数据,包括 Pod、Service、ConfigMap、Secret等
- **数据可靠性**  
    Etcd通过分布式架构保证数据的高可用性和一致性,确保集群状态数据在发生故障时仍能可靠存储  
- **数据访问**   
    Etcd提供了高效的键值对存储和访问接口,支持高频率的读写操作,满足K8s对集群状态数据的高频访问需求  
```bash
Kube-APIServer通过etcd API进行数据的读写操作。当集群状态发生变化时,APIServer会将新的状态数据写入etcd,同时其他组件可以监听etcd的变化,从而进行相应的处理
```
# Kube-Scheduler
**Kube-Scheduler是Kubernetes的调度组件,负责将新创建的Pod调度到合适的工作节点上,它根据预设的调度策略和节点状态,选择最合适的节点来运行Pod**  
**功能**  
**资源调度**   
-  Kube-Scheduler根据节点的资源使用情况和Pod的资源需求,选择合适的节点来运行Pod  
**策略配置**  
-  Kube-Scheduler支持多种调度策略,包括资源优先、亲和性、反亲和性等,用户可以根据需求自定义调度策略  
**负载均衡**  
-  通过合理的调度策略,Kube-Scheduler能够有效地分配负载,避免节点过载,确保集群的高效运行  
```bash
Kube-Scheduler通过监听Kube-APIServer上的调度请求,获取需要调度的Pod列表。然后,它根据预设的调度策略和节点的状态,选择最合适的节点,并将调度结果写回APIServer,最终由相应的节点来运行Pod
```

# Kube-Controller-Manager
**Kube-Controller-Manager是K8s控制平面的控制管理组件,负责管理集群的各种控制器。这些控制器是用于处理集群状态变化的后台进程**  
**功能**  
- **控制器管理**  
    包括NodeController、ReplicationController、EndpointController、NamespaceController等,这些控制器分别负责节点管理、副本管理、服务发现、命名空间管理等功能  
- **自动化操作**  
    控制器通过监听集群状态变化,自动执行相应的操作,如副本调整、故障节点隔离、服务更新等    
- **一致性保证**  
    通过控制器的自动化操作,Kube-Controller-Manager 保证了集群状态的一致性和可靠性
```bash
Kube-Controller-Manager通过监听Kube-APIServer的事件,获取集群状态变化的信息。根据不同的控制器,它会执行相应的操作,如创建或删除Pod、副本调整、节点故障处理等,并将结果写回APIServer,从而更新集群状态
```

# Cloud-Controller-Manager
**Cloud-Controller-Manager是K8s控制平面的云服务管理组件,用于将K8s与底层的云服务集成。它抽象了底层云平台的差异,使得K8s可以在不同的云平台上运行**  
**功能**  
- **云资源管理**  
    包括节点管理、负载均衡、存储管理等功能,支持将K8s与各种云服务（如 AWS、GCP、Azure）集成
- **多云支持**  
    通过抽象底层云平台的差异,Cloud-Controller-Manager使得K8s可以在多种云平台上无缝运行
- **自动化操作**   
    通过自动化管理云资源,Cloud-Controller-Manager提高了K8s集群的可用性和灵活性
```bash
Cloud-Controller-Manager通过调用底层云平台的API,执行相应的操作,如节点创建、负载均衡配置、存储卷管理等。它通过监听Kube-APIServer 的事件,获取需要执行的操作,然后调用云平台的API来完成相应的操作,并将结果写回APIServer,从而更新集群状态。
```

# Kubelet
**Kubelet是运行在每个工作节点上的主要代理进程,负责管理节点上的Pod和容器。它通过与Kube-APIServer交互,确保节点上容器的正确运行**  
**功能**  
- **Pod 管理**  
    Kubelet负责启动和停止节点上的Pod,并监控它们的状态,确保每个Pod按照预期运行  
- **状态报告**  
   Kubelet定期向Kube-APIServer报告节点和Pod的状态,包括资源使用情况、健康状态等  
- **配置管理**  
    Kubelet根据从Kube-APIServer获取的配置信息,配置和管理节点上的容器运行环境 
```bash
Kubelet通过监听Kube-APIServer的调度信息,获取需要在本节点上运行的Pod列表。它根据Pod的配置文件,调用容器运行时（如 Docker、containerd）来启动和管理容器。同时,Kubelet会定期向Kube-APIServer发送心跳信号和状态报告,确保控制平面能够及时了解节点和Pod的运行状况。
```
# Kube-Proxy
**Kube-Proxy是K8s中的网络代理服务,运行在每个工作节点上,负责维护网络规则,管理Pod间的网络通信和负载均衡**  
**功能**  
- **服务发现**   
    Kube-Proxy负责维护节点上的网络规则,确保服务IP和端口能够正确映射到相应的Pod上
- **负载均衡**  
    Kube-Proxy通过IPTables或IPVS实现服务的负载均衡,将请求分发到后端的多个Pod上
- **网络路由**  
    Kube-Proxy处理网络流量,确保节点内外的通信能够正确路由到目标Pod  
```bash
Kube-Proxy通过监听Kube-APIServer获取服务和端点的变化信息,然后根据这些信息动态更新节点上的网络规则;它使用IPTables或IPVS来实现网络流量的转发和负载均衡,确保请求能够正确分发到相应的Pod上
```

# 容器运行时
**容器运行时(Container Runtime)是K8s中用于运行和管理容器的组件,常见的容器运行时有Docker、containerd、CRI-O等** 
**功能**  
- **容器管理**  
    容器运行时负责启动、停止和监控容器的运行状态
- **资源隔离**  
    容器运行时通过cgroup、namespace等机制实现容器的资源隔离和限制
- **镜像管理**  
    容器运行时负责从镜像仓库拉取容器镜像,并在节点上进行存储和管理
```bash
Kubelet通过CRI(ContainerRuntimeInterface)与容器运行时进行交互,向其发送启动和停止容器的指令。容器运行时根据这些指令,调用底层操作系统的容器技术（如cgroup、namespace）来管理容器的生命周期和资源使用,同时,容器运行时还负责从镜像仓库拉取和管理容器镜像,确保容器能够按需启动
```



