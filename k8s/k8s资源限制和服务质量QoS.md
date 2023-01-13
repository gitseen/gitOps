# k8s资源限制和服务质量QoS
## k8s资源限制
## k8s服务质量QoS

>kubernetes中的内存表示单位Mi和M的区别  
官网解释：Meaning of memory，Mi表示（1Mi=1024×1024）,M表示（1M=1000×1000）（其它单位类推， 如Ki/K Gi/G） 
                             1M=1024K=1024×1024字节，但在k8s中的M表示的意义是不同的，今天特意看了一下官方文档，并实验了一把，特此记录。  
# 资源类型
在K8S中可以对两类资源进行限制：cpu和内存。  
*CPU的单位有：*
  - 正实数，代表分配几颗CPU，可以是小数点，比如0.5代表0.5颗CPU，意思是一 颗CPU的一半时间。2代表两颗CPU。  
  - 正整数m，也代表1000m=1，所以500m等价于0.5。  

*内存的单位：*
  - 正整数，直接的数字代表Byte  
    k、K、Ki，Kilobyte  
    m、M、Mi，Megabyte  
    g、G、Gi，Gigabyte  
    t、T、Ti，Terabyte  
    p、P、Pi，Petabyte  
