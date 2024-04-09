# 为什么需要Ingress
Service基于TCP和UDP协议进行访问转发，为集群提供了四层负载均衡的能力;  

但是在实际场景中,Service无法满足应用层中存在着大量的HTTP/HTTPS访问需求。  

因此K8s集群提供了另一种基于HTTP协议的访问方式——Ingress。  

Ingress是Kubernetes集群中一种独立的资源，制定了集群外部访问流量的转发规则;用户可根据域名和路径对转发规则进行自定义，完成对访问流量的细粒度划分;如图1所示用户可根据域名和路径对转发规则进行自定义，完成对访问流量的细粒度划分  

图1 Ingress示意图  

![图1](https://support.huaweicloud.com/usermanual-cce/zh-cn_image_0000001243981115.png)

# Ingress
Ingress是Kubernetes中实现外部访问管理的重要机制,Ingress控制器的选择和配置对于实现期望的路由行为至关重要。  
  - Ingress是Kubernetes中的一个资源对象,它管理外部用户访问集群内服务的HTTP和HTTPS路由
  - Ingress可以提供负载均衡、SSL终端和基于名称的虚拟托管
  - Ingress允许你通过定义规则集来控制如何将外部请求路由到集群内的不同服务
    >> 常见的Ingress控制器(NGINX Ingress Controller、Traefik、HAProxy）
# 关键特性
  - 1、路由规则：Ingress允许你定义基于URL路径、主机名、其他HTTP头部信息的路由规则,从而将流量导向不同的后端服务
  - 2、负载均衡：Ingress控制器通常会实现负载均衡机制,将进入的流量分配到后端的多个Pod上
  - 3、SSL/TLS终端：Ingress可以管理SSL/TLS证书,为通过它路由的流量提供加密
  - 4、虚拟托管：基于名称的虚拟托管允许你通过一个单一的IP地址来托管多个域名
    >> 注解：Ingress资源可以包含注解,这些注解可以被Ingress控制器用来扩展或自定义行为
# Ingress的工作原理
  - 1、Ingress资源：你创建一个Ingress资源,并定义一组规则,这些规则指定了哪些外部请求应该被路由到集群中的哪些服务
  - 2、Ingress控制器：Ingress控制器是一个Pod或一组Pod,它运行在你的K8s集群中,并监听Ingress资源的变化。当Ingress规则更新时,Ingress控制器会相应地更新其内部的负载均衡器配置
  - 3、流量路由：当外部请求到达集群时,Ingress控制器会根据Ingress规则将请求路由到正确的服务

