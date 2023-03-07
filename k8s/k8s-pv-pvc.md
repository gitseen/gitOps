#K8S持久化存储方案
Kubernetes(k8s)提供了多种存储方案,以便在不同的场景下满足不同的需求  
- 1、空白存储卷(EmptyDir)  
     它是一种临时性的存储卷,不容器重启或删除时,其中的数据会被清除。适用于需要在容器内部传递数据的场景  
- 2、主机路径存储卷(HostPath)  
     它将主机的目录挂载到容器中,可以用来存储一些应用程序的数据。但不适用于需要在多个节点上运行的应用程序  
- 3、持久化存储卷(PersistentVolume & Persistent Volume Claim)  
     它是一种动态持久性的存储卷类型,可以在容器重启或迁移时自动创建和销毁数据,以适应不同的存储需求。可以使用多种存储后端,如NFS、iSCSI、Ceph等  
- 4、动态存储卷(Dynamic Volume Provisioning)  
     它用存储插件动态创建存储卷,将存储资源与应用程序分离;可以根据需要自动创建和删除存储资源,节约资源



# Kubernetes存储PV/PVC
持久卷PV是K8s集群中的一块存储,由集群的管理员配置和管理。它是一种将存储与需要它的实际吊舱分开的方式。PV就像一个网络驱动器,可以被多个pod共享  

持久卷要求PVC是对持久卷中特定数量的存储的请求。它是一种让pod要求访问它需要存储数据的一块存储的方式。Pod指定它所需要的存储量和类型,集群提供一个符合请求的持久化卷  

总而言之,PV就像K8s集群中的一个存储资源池,可以被多个pod访问,而PVC则是一个pod从PV中请求和要求访问特定数量的存储的方式  

PV和PVC可以确保你的应用程序的数据被持久性地存储,并能在pod重新启动或失败后存活。它们还使你能够更有效地管理你的存储资源,允许你在多个pod之间共享存储,并根据需要动态地配置存储  
![pv-pvc](https://p3-sign.toutiaoimg.com/tos-cn-i-qvj2lq49k0/115fc2fc8b904e0ea1c8b99a39aa3788~noop.image?_iz=58558&from=article.pc_detail&x-expires=1678243543&x-signature=cjlwSWMwp2AnC20zmROgvWC5N8U%3D)  

持久卷PVC可以有不同的访问模式,它定义了PVC如何被使用它的pod访问。可用的访问模式是  
- 1、一次性读写(RWO)
     这是默认的访问模式。它允许PVC被集群中的一个节点挂载为读写。这意味着PVC可以被运行在该节点上的单个pod使用,而对集群中的其他节点不可用
- 2、ReadOnlyMany(ROX)
     这种访问模式允许PVC被集群中的许多节点挂载为只读。这意味着PVC可以被运行在不同节点上的多个pod使用,但它们只能从中读取,不能写入
- 3、ReadWriteMany(RWX) 
     这种访问模式允许集群中的许多节点将PVC挂载为读写器。这意味着PVC可以被运行在不同节点上的多个pod使用,它们既可以从中读取也可以写入
- 4、ReadWriteOncePod  
     ReadWriteOncePod存储类是一个预定义的存储类,可以用来创建一个具有ReadWriteOnce访问模式的持久卷,该持久卷打算由一个pod使用  
     Kubernetes确保该pod是整个集群中唯一可以读取该PVC或向其写入的pod  
当创建一个PVC时,你可以指定适合你使用情况的访问模式。根据你的应用程序的需求和你使用的存储类,选择正确的访问模式是很重要的。选择错误的访问模式会导致你的应用程序出现意外的行为或错误  

**PV-PVC-example**  
```
kubectl get pv,pvc
kubectl create -f pv_ReadWriteOnce.yaml
kubectl create -f pv_ReadOnlyMany.yaml
kubectl create -f pv_ReadWriteMany.yaml
kubectl get pvc 
#检查状态 STATUS是可用的   CLAIM栏是空白 PV没有与任何PVC绑定
```

