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
**NodePort方式缺点**   
- 当服务比较多的时候,会占用集群节点的大量端口,难以维护
- 多了一层NAT,请求量比较大的时候会对性能产生影响
**LoadBlancer方式缺点**  
- 每个service一个外部负载均衡器,麻烦又浪费
- 需要有外部负载均衡器支持,有局限性  
**Ingress**    
相比上面两种方式,只需要一个NodePort或者一个LoadBlancer就可以满足所有service对集群外暴露服务的需求,简单灵活


