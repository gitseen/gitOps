# k8s-架构 
- 基本工作过程
- 架构：逻辑架构、物理架构

## 基本工作过程
Kubernetes 的核心工作过程  
- 1、资源对象   #Node、Pod、Service、Replication Controller等都可以看作一种资源对象
- 2、操作       #通过使用kubectl工具,执行增删改查
- 3、存储       #对象的目标状态(预设状态)保存在etcd中持久化储存
- 4、自动控制   #跟踪、对比etcd中存储的目标状态与资源的当前状态,对差异资源纠偏,自动控制集群状态
Kubernetes实际是：高度自动化的资源控制系统,将其管理的一切抽象为资源对象,大到服务器Node节点,小到服务实例Pod  

Kubernetes的资源控制是一种声明+引擎的理念  
- 1、声明：对某种资源,声明他的目标状态 
- 2、自动：Kubernetes自动化资源控制系统,会一直努力将该资源对象维持在目标状态  

## 架构(物理+逻辑)
Kubernetes集群是主从架构  

- Master管理节点,集群的控制和调度
  * kube-apiserver
  * kube-controller-manager
  * kube-scheduler
  * etcd  
- Node工作节点,执行具体的业务容器
  * kubelet
  * kube-proxy  
![lt](http://ningg.top/images/kubernetes-series/k8s-cluster-arch.png)  


**Master管理节点：管理整个Kubernetes集群,接收外部命令,维护集群状态**  
- apiserver： Kubernetes API Server
  * 集群控制的入口
  * 资源的增删改查,持久化存储到etcd
  * kubectl直接与API Server交互,默认端口6443
- etcd一个高可用的key-value存储系统
  * 作用：存储资源的状态
  * 支持Restful 的API
  * 默认监听2379和2380端口(2379提供服务,2380用于集群节点通信)
- scheduler负责将pod资源调度到合适的node上
  * 调度算法：根据 node 节点的性能、负载、数据位置等,进行调度。
  * 默认监听 10251 端口。
- controller-manager: 所有资源的自动化控制中心
  * 每个资源,都对应有一个控制器
  * controller manager管理这些控制器
  * controller manager是自动化的循环控制器
  * Kubernetes的核心控制守护进程,默认监听10252端口
  * scheduler和controller-manager都是通过apiserver从etcd中获取各种资源的状态,进行相应的调度和控制操作

**Node节点：Master节点,将任务调度到Node节点,以docker方式运行；当Node节点宕机时,Master会自动将Node上的任务调度到其他Node上** 
- kubelet节点Pod的生命周期管理,定期向Master上报本节点及Pod的基本信息
  * Kubelet是在每个Node节点上运行agent
  * 负责维护和管理所有容器：从apiserver接收Pod的创建请求,启动和停止Pod
  * Kubelet不会管理不是由Kubernetes创建的容器
  * 定期向Master上报信息,如操作系统、CPU、内存、pod运行状态等信息
- kube-proxy：集群中 Service 的通信以及负载均衡
  * 功能：服务发现、反向代理。
  * 反向代理：支持TCP和UDP连接转发,默认基于Round Robin算法将客户端流量转发到与service对应的一组后端pod
  * 服务发现：使用etcd的watch机制,监控集群中service和endpoint对象数据的动态变化,并且维护一个service到endpoint的映射关系(本质是路由关系)
  * 实现方式：userspace、iptables、ipvs
    * userspace：在用户空间,通过kuber-proxy实现负载均衡的代理服务,是最初的实现方案,较稳定、效率不高
    * iptables：在内核空间,是纯采用iptables来实现LB,是Kubernetes目前默认的方式
    * ipvs 
- runtime：一般使用docker容器、rkt、containerd等其他的容器(CRI)







http://ningg.top/kubernetes-series-03-architecture/
