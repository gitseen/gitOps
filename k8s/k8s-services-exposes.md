# K8S的Service
## 1. Service存在的意义
Kubernetes中的Service是一种网络抽象,用于将一组Pod暴露给其他组件,例如其他Pod或外部用户。Service可以作为一个负载均衡器,为一组Pod提供单一的IP地址和DNS名称,并通过选择器来将流量路由到这些Pod  

**Services的存在有以下几个意义** 
- 1、透明的服务发现  
     Kubernetes使用Service作为一种透明的服务发现机制;使用Service可以将Pod隐藏在后面,这样其他组件可以使用Service的DNS名称来访问它们,而不需要知道Pod的实际IP地址和端口号
- 2、负载均衡
     Service可以将流量路由到一组Pod上,并使用标签选择器将流量均匀地分配给这些Pod。这使得可以轻松地进行水平扩展,以满足不断增长的负载  
- 3、稳定的IP地址
     Kubernetes为每个Service分配一个稳定的IP地址,这个IP地址与Pod的生命周期无关。这意味着可以在Pod启动和停止时保持稳定的服务地址,并且无需手动更改任何配置  
- 4、外部访问
     通过将Service类型设置为NodePort或LoadBalancer可以将Service暴露给外部用户或外部负载均衡器;这使得可以轻松地将Kubernetes集群与外部服务和用户集成  
总之,Service是Kubernetes中非常重要的一部分,可以提供透明的服务发现、负载均衡、稳定的IP地址和外部访问。在实际生产环境中,使用Service是构建可靠和可扩展应用程序的关键  

## 2. Pod、Service、Label的关系
Pod是Kubernetes中最小的可部署单元,它是由一个或多个容器组成的;Pod提供了一个运行环境,其中包含应用程序所需的资源,如存储、网络和命名空间  

Service是Kubernetes中的一种抽象,用于定义一组Pod,这些Pod执行相同的任务,并且可以通过Service的IP地址和端口号进行访问;  
Service允许应用程序通过固定的IP和端口号进行访问,而不必考虑后端Pod的IP和端口号  

在Kubernetes中,Pod和Service之间有一种紧密的关系。Service使用标签选择器来确定哪些Pod应该成为它的后端。一旦Service选择了一组Pod,它将为这些Pod分配一个固定的IP和端口号,这些IP和端口号将用于访问这些Pod  

当Pod被创建或删除时,Service会自动更新它的后端列表。这意味着当Pod被添加到Service的后端时,它们将自动成为Service的一部分,并且可以通过Service的IP和端口号进行访问  
同样当Pod被删除时,它们将自动从Service的后端列表中删除,这样访问它们的请求就不会被发送到已经不存在的Pod上  
因此Pod和Service之间的关系是非常紧密的,Service为一组Pod提供了一个稳定的网络地址,并且自动更新它的后端列表以确保访问这些Pod时的高可用性和可靠性  

在Kubernetes中,Pod、Service和标签之间有着密切的关系。标签(Label)是Kubernetes中的一种机制,它允许你为对象添加任意的元数据,例如版本、环境、用途等等  

Pod可以使用标签进行分类和分组,通过给Pod打上特定的标签,可以方便地对它们进行选择和管理;  
同样地Service也可以使用标签选择器来选择具有特定标签的Pod作为后端;标签可以被应用于任何Kubernetes对象,包括Pod、Service、ReplicaSet等等  

示例：可以通过以下方式创建一个Service它将选择所有标有app=goweb-demo的Pod作为它的后端
<details>
  <summary>k8s-service</summary>
  <pre><code>
#xx.yaml
```
apiVersion: v1
kind: Service
metadata:
  name: goweb-demo
spec:
  ports:
  - port: 80
    protocol: TCP
    targetPort: 8090
  selector:
    app: goweb-demo
```
在这个例子中Service使用selector字段来选择具有app=goweb-demo标签的Pod作为它的后端;这意味着只有那些标记为app=goweb-demo的Pod才能被Service访问

  </code></pre>
</details>

Label标签是Kubernetes中非常重要的一个概念,它使得对Pod和Service的选择和管理变得更加灵活和高效。通过使用标签,可以轻松地对应用程序的不同版本、环境和用途进行分类和分组,并根据需要创建相应的Pod和Service来满足应用程序的需求

## 3. Service的访问类型
Kubernetes中的Service对象可以指定不同的访问类型,以便在集群内和集群外提供不同级别的访问; 下面是Kubernetes中Service的三种访问类型   
- ClusterIP 
  默认的访问类型,将创建一个虚拟IP地址,代表一组后端Pod。只能从集群内部访问该Service,外部无法访问  
- NodePort 
  将在每个Node上公开一个端口,并将该端口重定向到Service。可以通过Node的IP地址和该端口访问该Service。可以从集群外部访问该Service,但需要在防火墙中打开该端口  
- LoadBalancer  
  将在外部创建一个负载均衡器,并将流量路由到Service。负载均衡器可以将流量路由到多个后端Pod,以提高可用性和性能。需要使用外部负载均衡器的云平台支持,例如AWS ELB或GCP GCLB 

另外,还有一种名为ExternalName的访问类型,可以将Service映射到集群外部的DNS名称,而不是集群内部的Pod。该访问类型通常用于将Service映射到外部服务,例如数据库或API网关。

可以使用kubectl命令行或YAML文件来指定Service的访问类型和其他配置。例如,在YAML文件中,可以将Service的类型指定为type: ClusterIP、type: NodePort或type: LoadBalancer,具体取决于需要提供的访问级别  

示例:    
<details>
  <summary>k8s-service-nodePort</summary>
  <pre><code>
#Deployment,servce.yaml
```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: goweb-demo
spec:
  replicas: 3
  selector:
    matchLabels:
      app: goweb
  template:
    metadata:
      labels:
        app: goweb
    spec:
      containers:
      - name: goweb-container
        image: 192.168.11.247/web-demo/goweb-demo:20221229v3
#svc
apiVersion: v1
kind: Service
metadata:
  creationTimestamp: null
  labels:
    app: goweb
  name: goweb
spec:
  ports:
  - name: 80-8090
    nodePort: 30080
    port: 80
    protocol: TCP
    targetPort: 8090
  selector:
    app: goweb
  type: NodePort
status:
  loadBalancer: {}
```
  </code></pre>
</details>

## 4. K8S的Service总结
**Kubernetes(k8s) Service是一个抽象层,它为一组Pod提供了一个稳定的访问地址和DNS名称;在k8s中Service是通过控制器和负载均衡器来实现的;它可以将流量分发给后端Pod实例;并确保它们的可用性和可靠性**    

**Kubernetes Service的总结**  

Service是基于四层TCP和UDP协议转发的,而Ingress可以基于七层的HTTP和HTTPS协议转发,可以通过域名和路径做到更细粒度  

- 1、Service类型及场景
     * ExternalName 通过返回CNAME和对应值,可以将服务映射到externalName字段的内容(例如foo.bar.example.com)无需创建任何类型代理
     * ClusterIP  用于在集群内部互相访问的场景,通过ClusterIP访问Service  
       通过集群的内部IP暴露服务选择该值时服务只能够在集群内部访问。 这也是默认的ServiceType  
     * Headless Service 用于Pod间的互相发现,该类型的Service并不会分配单独的ClusterIP, 而且集群也不会为它们进行负载均衡和路由。您可通过指定spec.clusterIP字段的值为"None"来创建HeadlessService,详细介绍请参见HeadlessService
     * NodePort   用于从集群外部访问的场景,通过节点上的端口访问Service  
       通过每个节点上的IP和静态端口(NodePort)暴露服务。NodePort服务会路由到自动创建的ClusterIP服务;通过请求<节点 IP>:<节点端口>,你可以从集群的外部访问一个NodePort  
     * LoadBalancer 用于从集群外部访问的场景,其实是NodePort的扩展,通过一个特定的LoadBalancer访问Service,这个LoadBalanc
       使用云提供商的负载均衡器向外部暴露服务。 外部负载均衡器可以将流量路由到自动创建的NodePort服务和ClusterIP服务上  
     * Ingress

- 2、Service Selector是用来选择要将流量转发到哪个Pod的标签  
     每个Service都会指定一个或多个Selector用于确定应该选择哪些Pod;在创建Service时可以指定标签选择器以选择相关Pod  

- 3、端口Service的端口指的是该Service的监听端口  
     Service可以监听多个端口,每个端口都可以关联一个或多个后端Pod。端口也可以分为两个类型：端口和目标端口。端口是Service监听的端口,而目标端口是后端Pod的端口  

- 4、负载均衡k8s Service可以通过三种负载均衡算法来将流量分配到后端Pod中
     * Round Robin
       这是最常见的负载均衡算法。它按顺序分配流量到每个Pod,然后循环下去  
     * Session Affinity
       这种算法会将同一客户端的所有请求都发送到同一个后端Pod中。这有助于维护状态,并确保在会话期间一致性 
     * IPVS：这是一种高级的负载均衡算法,它使用Linux内核中的IPVS模块来实现流量分发  

- 5、DNS k8s Service通过DNS来提供一个稳定的访问地址  
     创建Service时,k8s会将其关联的Pod的IP地址注册到k8s集群的DNS中,并使用Service名称和Namespace作为DNS条目。这样客户端可以通过Service名称和命名空间来访问该Service; k8s DNS将解析这个名称并将其映射到Service关联的PodIP地址  


在k8s中每个Pod都有一个唯一的IP地址;但是这个IP地址在Pod重新调度或者Pod数量发生变化时可能会发生变化。这种变化可能会导致客户端连接中断,因此k8s Service提供了一个稳定的访问地址,使得客户端可以通过Service名称来访问Pod而不需要关心其IP地址的变化  
这种方式也使得k8s Service非常适合于微服务架构,因为它可以将多个Pod组合成一个逻辑单元,并通过一个稳定的访问地址对外提供服务  


***

# k8s向集群外部暴露服务
**Kubernetes向进群外暴露服务的方式有三种：Ingress、LoadBlancer类型的Service、NodePort类型的Service**  
## 1、Ingress  
   Ingress相当于service的service,可以将外部请求通过按照不同规则转发到对应的service  
   实际上,ingress相当于一个7层的负载均衡器,是k8s对反向代理的一个抽象,大概的工作原理类似于Nginx  
```mermaid
graph LR;
 client([客户端])-. Ingress 所管理的<br>负载均衡器 .->ingress[Ingress];
 ingress-->|路由规则|service[服务];
 subgraph cluster
 ingress;
 service-->pod1[Pod];
 service-->pod2[Pod];
 end
 classDef plain fill:#ddd,stroke:#fff,stroke-width:4px,color:#000;
 classDef k8s fill:#326ce5,stroke:#fff,stroke-width:4px,color:#fff;
 classDef cluster fill:#fff,stroke:#bbb,stroke-width:2px,color:#326ce5;
 class ingress,service,pod1,pod2 k8s;
 class client plain;
 class cluster cluster;
 ```
**Ingress工作原理(以Nginx Ingress为例)**  
```
Ingress-controller通过和Kubernetes APIServer交互,动态感知集群中Ingress规则的变化,感知到规则的变化后生成对应的Nginx配置,
将配置写到nginx-ingress-controller的pod里(ingress-controller的pod里运行着一个Nginx服务,ingress-controller会把生成的 nginx配置写入/etc/nginx.conf文件中),
然后执行reload使配置生效。
```
## 2、LoadBlancer类型的Service
创建service时,指定type类型为LoadBalancer,需要有外部负载均衡器的支持,绝大部分云厂商都支持创建外部负载均衡  

## 3、NodePort类型的Service
创建service时,指定type类型为NodePort,这样,服务就会暴露在集群节点ip的指定端口上

# 几种方式的优缺点
## NodePort方式缺点 
  - 当服务比较多的时候,会占用集群节点的大量端口,难以维护
  - 多了一层NAT,请求量比较大的时候会对性能产生影响  
## LoadBlancer方式缺点  
  - 每个service一个外部负载均衡器,麻烦又浪费
  - 需要有外部负载均衡器支持,有局限性   
## Ingress
  - 相比上面两种方式,只需要一个NodePort或者一个LoadBlancer就可以满足所有service对集群外暴露服务的需求,简单灵活

>notice:
1  https://segmentfault.com/a/1190000023125587
2  https://zhuanlan.zhihu.com/p/587531612 





