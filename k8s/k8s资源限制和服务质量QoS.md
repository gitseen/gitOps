# k8s资源限制和服务质量QoS
## [k8s资源限制](https://developer.aliyun.com/article/679887)
## k8s服务质量QoS

>kubernetes中的内存表示单位Mi和M的区别 
#https://kubernetes.io/zh/docs/tasks/configure-pod-container/assign-cpu-resource/  
#https://kubernetes.io/zh/docs/tasks/configure-pod-container/assign-memory-resource/   
官网解释：Meaning of memory，Mi表示（1Mi=1024×1024）,M表示（1M=1000×1000）（其它单位类推， 如Ki/K Gi/G） 
                             1M=1024K=1024×1024字节，但在k8s中的M表示的意义是不同的，今天特意看了一下官方文档，并实验了一把，特此记录。  
# 资源限制
在K8S中可以对两类资源进行限制：cpu和内存。  
*CPU的单位有：*
  - 正实数，代表分配几颗CPU，可以是小数点，比如0.5代表0.5颗CPU，意思是一 颗CPU的一半时间。2代表两颗CPU。  
  - 正整数m，也代表1000m=1，所以500m等价于0.5。  

*内存的单位：*
  - 正整数，直接的数字代表Byte  
  - k、K、Ki，Kilobyte  
  - m、M、Mi，Megabyte  
  - g、G、Gi，Gigabyte  
  - t、T、Ti，Terabyte  
  - p、P、Pi，Petabyte  

# 资源限制方法一(pod中定义)
在K8S中，对于资源的设定是落在Pod里的Container上的，主要有两类，limits控制上限，requests控制下限。其位置在：  
  - spec.containers[].resources.limits.cpu
  - spec.containers[].resources.limits.memory
  - spec.containers[].resources.requests.cpu
  - spec.containers[].resources.requests.memory
  eg:  
        resources:  
          limits:  
            cpu: 1000m  
            memory: 2000Mi  
          requests:  
            cpu: 100m  
            memory: 500Mi  

# [资源限制方法二（namespace中定义)](https://cloud.tencent.com/developer/article/1772253)
方法一虽然很好，但是其不是强制性的，因此很容易出现因忘记设定limits/request，导致Host资源使用过度的情形，因此我们需要一种全局性的资源限制设定，以防止这种情况发生。K8S通过在Namespace设定LimitRange来达成这一目的。  
## 配置默认request/limit  
如果配置里默认的request/limit，那么当Pod Spec没有设定request/limit的时候，会使用这个配置，有效避免无限使用资源的情况。  
配置位置在：  
  - spec.limits[].default.cpu，default limit
  - spec.limits[].default.memory，同上
  - spec.limits[].defaultRequest.cpu，default request
  - spec.limits[].defaultRequest.memory，同上
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

## 配置request/limit的约束
我们还可以在K8S里对request/limit进行以下限定：  
某资源的request必须>=某值  
某资源的limit必须<=某值  
这样的话就能有效避免Pod Spec中乱设limit导致资源耗尽的情况，或者乱设request导致Pod无法得到足够资源的情况。  

配置位置在：
  - spec.limits[].max.cpu，limit必须<=某值  
  - spec.limits[].max.memory，同上  
  - spec.limits[].min.cpu，request必须>=某值  
  - spec.limits[].min.memory，同上 
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

namespace中定义  


