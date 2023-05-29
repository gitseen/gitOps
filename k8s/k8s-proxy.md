# kube-proxy
kube-proxy运行在所有节点上,它监听apiserver中service和endpoint的变化情况,创建路由规则以提供服务IP和负载均衡功能。   
简单理解此进程是Service的透明代理兼负载均衡器,其核心功能是将到某个Service的访问请求转发到后端的多个Pod实例上   

当在kubernetes集群中创建一个service对象后,controller-manager组件会自动创建一个和service名称相同的endpoints对象。  
endpoints对象中的IP就是该service通过labelSelector关联的且已就绪pod IP,controller-manager里的endpoints controller会监听pod的状态,实时维护endpoints对象中的数据。  

kube-proxy在kubernetes集群中以daemonSet形式启动,也就每个节点上都会启动一个kube-proxy服务的pod。  
kube-proxy的pod通过监听集群中service和endpoints资源的变化,刷新节点上的iptables/ipvs规则,从而实现访问service VIP代理到后端pod的功能。  

三种模式  
- kube-proxy先后出现了三种模式：userspace、iptables、ipvs,其中userspace模式是通过用户态程序实现转发,因性能问题基本被弃用,当前主流的模式是iptables和ipvs。  
- kube-proxy默认配置是iptables模式,可以通过修改kube-system命名空间下名称为kube-proxy的configMap资源的mode字段来选择kube-proxy的模式。  
- kube-proxy iptables模式实现的普通clusterIP类型的service原理,其它类型的service原理大家可以参考本文和其它资料自行分析。  
如无特殊场景,下文不再对kube-proxy模式和service类型做特别说明。  
原文链接：https://blog.csdn.net/summer_fish/article/details/124267851  
kubectl get pod -n kube-system | grep kube-proxy |awk '{system("kubectl delete pod "$1" -n kube-system")}'  
https://www.cnblogs.com/houchaoying/p/14185477.html  


# ipvs VS iptables
## ipvs安装
```
yum install -y ipvsadm
#查看configMap配置文件
kubectl get pod -n kube-system
kubectl logs kube-proxy-9b5bn -n kube-system
kubectl edit configmaps kube-proxy -n kube-system #"mode="" or mode=ipvs"
kubectl get pod -n kube-system|grep "proxy"|awk '{system(kubectl delete pod "$1" -n kube-system)}'
ipvadmin -Ln
```
# iptables与IPVS如何选择  
kube-proxy是Kubernetes集群的关键组件,负责Service和其后端容器Pod之间进行负载均衡转发。  

CCE当前支持iptables和IPVS两种转发模式,各有优缺点。
- IPVS: 吞吐更高,速度更快的转发模式。适用于集群规模较大或Service数量较多的场景。  
- iptables: 社区传统的kube-proxy模式。适用于Service数量较少或客户端会出现大量并发短链接的场景。  


# 约束与限制
IPVS模式下,ingress和service使用相同ELB实例时,无法在集群内的节点和容器中访问ingress。  

# iptables
iptables是一个Linux内核功能,提供了大量的数据包处理和过滤方面的能力。它可以在核心数据包处理管线上用Hook挂接一系列的规则。  
iptables模式中kube-proxy在NAT pre-routing Hook中实现它的NAT和负载均衡功能。  
kube-proxy的用法是一种O(n)算法,其中的n随集群规模同步增长,这里的集群规模,更明确的说就是服务和后端Pod的数量。  

IPVS
IPVS(IP Virtual Server)是在Netfilter上层构建的,并作为Linux内核的一部分,实现传输层负载均衡。  
IPVS可以将基于TCP和UDP服务的请求定向到真实服务器,并使真实服务器的服务在单个IP地址上显示为虚拟服务。    
IPVS模式下,kube-proxy使用IPVS负载均衡代替了iptable。这种模式同样有效,IPVS的设计就是用来为大量服务进行负载均衡的,它有一套优化过的API,使用优化的查找算法,而不是简单的从列表中查找规则。  
kube-proxy在IPVS模式下,其连接过程的复杂度为O(1)。换句话说,多数情况下,他的连接处理效率是和集群规模无关的。  
IPVS包含了多种不同的负载均衡算法,例如轮询、最短期望延迟、最少连接以及各种哈希方法等。而iptables就只有一种随机平等的选择算法。  

# IPVS相较于iptables的优势
- 为大型集群提供了更好的可扩展性和性能
- 支持比iptables更好的负载均衡算法
- 支持服务器健康检查和连接重试等功能


