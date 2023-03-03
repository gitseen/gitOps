# k8s调度之初探nodeSelector和nodeAffinity
**k8s的调度中类型** 
  - 有强制性的nodeSelector
  - 节点亲和性nodeAffinity
  - Pod亲和性podAffinity
  - pod反亲和性podAntiAffinity  

进入主题之前,先看看创建pod的大概过程  
![创建pod流程](https://p3-sign.toutiaoimg.com/tos-cn-i-qvj2lq49k0/01235649687f49ab9c753705c94ec72c~noop.image?_iz=58558&from=article.pc_detail&x-expires=1678325352&x-signature=UV6Rxxr5pBaRgksqFDMfeddJI34%3D)  
```
1、kubectl向apiserver发起创建pod请求,apiserver将创建pod配置写入etcd
2、scheduler收到apiserver有新pod的事件,scheduler根据自身调度算法选择一个合适的节点,并打标记pod=test-b-k8s-node01
3、kubelet收到分配到自己节点的pod,调用docker api创建容器,并获取容器状态汇报给apiserver
4、执行kubectl get查看,apiserver会再次从etcd查询pod信息
k8s的各个组件是基于list-watch机制进行交互的,了解了list-watch机制,以及结合上述pod的创建流程,就可以很好的理解各个组件之间的交互。
```

# 何为调度
>>  
说白了就是将Pod指派到合适的节点上,以便对应节点上的Kubelet能够运行这些Pod  
在k8s中,承担调度工作的组件是kube-scheduler,它也是k8s集群的默认调度器,它在设计上就允许编写一个自定义的调度组件并替换原有的kube-scheduler。所以,如果你足够牛逼,就可以自己开发一个调度器来替换默认的了   
调度器通过K8S的监测(Watch)机制来发现集群中新创建且尚未被调度到节点上的Pod,调度器会将所发现的每一个未调度的Pod调度到一个合适的节点上来运行  



[不背锅运维-k8s调度之初探](https://www.google.com/)
