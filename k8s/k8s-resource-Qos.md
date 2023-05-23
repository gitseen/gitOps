# [k8s资源限制和服务质量QoS](https://www.cnblogs.com/wangxu01/articles/11672212.html)
## [k8s资源限制](https://developer.aliyun.com/article/679887)
## [k8s服务质量QoS](https://blog.51cto.com/ghostwritten/5345902)
## [k8s-Pod资源控制器限制配置探针方式、重启策略](https://blog.csdn.net/weixin_47151643/article/details/109063601)
>kubernetes中的内存表示单位Mi和M的区别   
#https://kubernetes.io/zh/docs/tasks/configure-pod-container/assign-cpu-resource/  
#https://kubernetes.io/zh/docs/tasks/configure-pod-container/assign-memory-resource/     
#https://www.toutiao.com/article/7201867480929927680  
官网解释：Meaning of memory,Mi表示（1Mi=1024×1024）,M表示（1M=1000×1000）（其它单位类推, 如Ki/K Gi/G） 
                             1M=1024K=1024×1024字节,但在k8s中的M表示的意义是不同的,今天特意看了一下官方文档,并实验了一把,特此记录。  
kubernetes中的表示法    
  kubernetes为了防止这些问题的出现,采用了新标准,即使用M(Megabyte)表示1000*1000B,使用Mi(Mebibyte)表示1024*1024B    
  
# 资源限制
在K8S中可以对两类资源进行限制：cpu和内存。  
*CPU的单位有：*
  - 正实数,代表分配几颗CPU,可以是小数点,比如0.5代表0.5颗CPU,意思是一 颗CPU的一半时间。2代表两颗CPU。  
  - 正整数m,也代表1000m=1,所以500m等价于0.5。  

*内存的单位：*
  - 正整数,直接的数字代表Byte  
  - k、K、Ki,Kilobyte  
  - m、M、Mi,Megabyte  
  - g、G、Gi,Gigabyte  
  - t、T、Ti,Terabyte  
  - p、P、Pi,Petabyte  

**$\color{red}{limits是使用的集群资源上限}$**

**$\color{red}{requests是需要使用的集群资源的大小}$**  


# 资源限制方法一(pod中定义)
在K8S中,对于资源的设定是落在Pod里的Container上的,主要有两类,limits控制上限,requests控制下限。其位置在：  
  - spec.containers[].resources.limits.cpu
  - spec.containers[].resources.limits.memory
  - spec.containers[].resources.requests.cpu
  - spec.containers[].resources.requests.memory  
```
  eg:    
        resources:  
          limits:  
            cpu: 1000m  
            memory: 2000Mi  
          requests:  
            cpu: 100m  
            memory: 500Mi  
```
# [资源限制方法二（namespace中定义)](https://cloud.tencent.com/developer/article/1772253)
方法一虽然很好,但是其不是强制性的,因此很容易出现因忘记设定limits/request,导致Host资源使用过度的情形,因此我们需要一种全局性的资源限制设定,以防止这种情况发生。K8S通过在Namespace设定LimitRange来达成这一目的。  
## 配置默认request/limit  
如果配置里默认的request/limit,那么当Pod Spec没有设定request/limit的时候,会使用这个配置,有效避免无限使用资源的情况。  
配置位置在：  
  - spec.limits[].default.cpu,default limit
  - spec.limits[].default.memory,同上
  - spec.limits[].defaultRequest.cpu,default request
  - spec.limits[].defaultRequest.memory,同上 
```
eg:  
apiVersion: v1  
kind: LimitRange  
metadata:   
  name: <name>   
spec:   
  limits:   
    - default:   
        memory: 512Mi  
        cpu: 1   
      defaultRequest:   
        memory: 256Mi  
        cpu: 0.5  
      type: Container    
```
## 配置request/limit的约束
我们还可以在K8S里对request/limit进行以下限定：  
某资源的request必须>=某值  
某资源的limit必须<=某值  
这样的话就能有效避免Pod Spec中乱设limit导致资源耗尽的情况,或者乱设request导致Pod无法得到足够资源的情况。  

配置位置在：
  - spec.limits[].max.cpu,limit必须<=某值  
  - spec.limits[].max.memory,同上  
  - spec.limits[].min.cpu,request必须>=某值  
  - spec.limits[].min.memory,同上 
```
namespace中定义
eg：  
apiVersion: v1  
kind: LimitRange  
metadata:   
  name: <name>   
spec:  
  limits:   
    - max:   
        memory: 1Gi   
        cpu: 800m   
      min:   
        memory: 500Mi  
        cpu: 200m  
      type: Container    
```

ResourceQuota  
```
apiVersion: v1
kind: ResourceQuota
metadata:
  name: kservice
spec:
  hard:
    requests.cpu: "8"
    requests.memory: 16Gi
    limits.cpu: "16"
    limits.memory: 32Gi
    pods: "2"
    services: "2"
```

# [服务质量等级](https://www.toutiao.com/article/7203310230536667707/)
[平凡人笔记](https://kubernetes.io/zh-cn/docs/tasks/configure-pod-container/quality-service-pod/)  
**K8s的三种服务质量等级**  
- Guaranteed可保证的
- Burstable突发的
- BestEffort尽力而为的(默认)
![Qos1](https://p3-sign.toutiaoimg.com/tos-cn-i-qvj2lq49k0/9f7a8831538d4820b19ce9e223941174~noop.image?_iz=58558&from=article.pc_detail&x-expires=1677809509&x-signature=tpnad%2FVQR4h3jeQgf2vfZd6Vr%2FY%3D)  

给容器配置申请资源(cpu或mem) request和最大使用资源limit的方式  

![pod](https://p3-sign.toutiaoimg.com/tos-cn-i-qvj2lq49k0/8d4f47d793104a83acef5a892d69ee82~noop.image?_iz=58558&from=article.pc_detail&x-expires=1677809509&x-signature=BNfmka1ctv00GS%2BEh2LbvMhgChA%3D)  
```
requests是需要使用的集群资源的大小，limits是使用的集群资源上限
Mi是M*1024byte，标准值是64M
k8s把cpu分成了1000份，250m为0.25cpu，也可以写1.0或0.5
requests和limits设定值的不同会影响到pod在集群中的生存周期和服务质量等级
```
# Guaranteed可保证的

![Guaranteed](https://p3-sign.toutiaoimg.com/tos-cn-i-qvj2lq49k0/c1a27fc390d04acca0f3e24e72add407~noop.image?_iz=58558&from=article.pc_detail&x-expires=1677809509&x-signature=vWGGtqyHIF6fYsZsfIJFIFpHJuc%3D)  

**requests和limits值一样是可保证的服务质量等级，等级是最高的，资源是可保证的；把pod下的所有的容器加起来requests=limits，才是这种pod等级** 
在实际使用中大部分情况是只使用一部分资源 ，大部分pod所申请的资源都是浪费的。  

# Burstable突发的
![Burstable](https://p3-sign.toutiaoimg.com/tos-cn-i-qvj2lq49k0/03ab567e31c341418f2956a1bb7a78da~noop.image?_iz=58558&from=article.pc_detail&x-expires=1677809509&x-signature=sceKhdQz1Ay40fBAdyq%2Fzp1vEu8%3D)  
requests小于limits或者只有requests没有limits，表示突发的服务质量等级，一般或默认的情况下使用requests设定的资源，极端的情况使用limit设定的资源  

先申请requests，大部分情况下都是使用这么多资源，极限的情况下，可能会使用更多的资源，但不会超过limits限制  
![free](https://p3-sign.toutiaoimg.com/tos-cn-i-qvj2lq49k0/ce28da174246452986abb227c6e1c0e7~noop.image?_iz=58558&from=article.pc_detail&x-expires=1677809509&x-signature=f2GWEELJ58nJFZF26ZPMQm4uCL4%3D)  
   
# BestEffort尽力而为的(默认)
![BestEffort](https://p3-sign.toutiaoimg.com/tos-cn-i-qvj2lq49k0/46dd42a4b0114a42a2ef48b6e8bcd7d6~noop.image?_iz=58558&from=article.pc_detail&x-expires=1677809509&x-signature=BVR5E2WsdoTXcthkpBfboyI0zSA%3D)  
这种情况是request和limit都不设定  

![2](https://p3-sign.toutiaoimg.com/tos-cn-i-qvj2lq49k0/0a6d9e542afd4cf7b3261cad642f53c3~noop.image?_iz=58558&from=article.pc_detail&x-expires=1677809509&x-signature=OvsVWduOZrjN3dKp6ies5WleS1M%3D) 
BestEffort是服务等级最低的情况，只要具备空闲cpu或空闲内存的节点上，pod都会被调度过去  
- 1、以低优先级获得cpu资源，在极端情况下无法获取cpu资源，其他的pod把cpu用完的时候，BestEffort这样的pod就获取不到任何的cpu资源；
- 2、当内存产生压力时最先被驱离  

# 总结
![end](https://p3-sign.toutiaoimg.com/tos-cn-i-qvj2lq49k0/401a779f6126489896410656768dd757~noop.image?_iz=58558&from=article.pc_detail&x-expires=1677809509&x-signature=hUuz%2F%2FdFdFqlbKbh400euzzboVQ%3D)  
三种不同的服务质量等级其实面向三种不同的应用场景  
**Guaranteed适合面向服务型应用**  
  ```
  集群需要保证申请的资源，pod只要调度到节点上，就不会因为系统资源问题被驱离或被终止这样的情况产生
  ```
**Burstable适合面向中型应用**  
  ```
  只有request的资源可以被保证;在节点内存吃紧时可能被驱离
  ```
**BestEffort适合面向任务型应用**  
  ```
  比如计算任务或日志分析类型，有资源就启动，没有资源被驱离
  以低优先级获取空闲cpu资源; 在极端的情况下会无cpu使用;  在节点内存吃紧时优先被驱离
  ```

**Guaranteed > Burstable > BestEffort**  


**查询QOS类型方式**
```
kubectl --namespace=default get pod nginx-7db9fccd9b-k8czd -o jsonpath='{ .status.qosClass}{"\n"}'
kubectl describe pod nginx-7db9fccd9b-k8czd |grep "QoS Class" 
```
# [Resource-Quotas](https://www.toutiao.com/article/7199078869490696715/)  
# [官方-policy](https://kubernetes.io/docs/concepts/policy/)
