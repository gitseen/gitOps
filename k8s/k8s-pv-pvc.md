# K8S持久化存储方案
**Kubernetes(k8s)提供了多种存储方案,以便在不同的场景下满足不同的需求** 
- 1、空白存储卷(EmptyDir)  
     它是一种临时性的存储卷,容器重启或删除时,其中的数据会被清除。适用于需要在容器内部传递数据的场景  
- 2、主机路径存储卷(HostPath)  
     它将主机的目录挂载到容器中,可以用来存储一些应用程序的数据。但不适用于需要在多个节点上运行的应用程序  
- 3、持久化存储卷(PersistentVolume & Persistent Volume Claim)  
     它是一种动态持久性的存储卷类型,可以在容器重启或迁移时自动创建和销毁数据,以适应不同的存储需求。可以使用多种存储后端,如NFS、iSCSI、Ceph等  
- 4、动态存储卷(Dynamic Volume Provisioning)  
     它用存储插件动态创建存储卷,将存储资源与应用程序分离;可以根据需要自动创建和删除存储资源,节约资源

## 空白存储卷(EmptyDir)
空白存储卷(EmptyDir)它是一种临时性的存储卷,适用于需要在容器内部传递数据的场景。例如,当一个容器需要向另一个容器传递一些数据时,可以使用空白存储卷来实现  
<details>
  <summary>k8s-EmptyDir</summary>
  <pre><code>
pod.yaml
```
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
  containers:
  - name: container1
    image: my-image
    volumeMounts:
    - name: data
      mountPath: /data
  - name: container2
    image: my-image
    volumeMounts:
    - name: data
      mountPath: /data
  volumes:
  - name: data
    emptyDir: {}
```
在这个示例中,我们创建了一个Pod,其中包含两个容器：container1和container2 这两个容器都需要访问同一个数据目录/data  
我们使用了一个空白存储卷来存储这些数据。在 volumes 字段中,我们创建了一个名为data的空白存储卷。在容器的volumeMounts字段中,我们将这个存储卷挂载到了/data 目录下
这样,当container1向/data目录写入数据时,container2可以从同一个目录读取数据,实现了数据的传递。需要注意的是,当Pod被删除或重启时,存储在空白存储卷中的数据也会被清除
  </code></pre>
</details>

## 主机路径存储卷(HostPath)
主机路径存储卷(HostPath)将主机的目录挂载到容器中,可以用来存储一些应用程序的数据。例如,我们可以使用主机路径存储卷来存储应用程序的日志文件、配置文件等  
<details>
  <summary>k8s-HostPath</summary>
  <pre><code>
下面是一个使用主机路径存储卷存储日志文件的示例YAML文件
```
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
  containers:
  - name: container1
    image: my-image
    volumeMounts:
    - name: logs
      mountPath: /var/log/my-app
  volumes:
  - name: logs
    hostPath:
      path: /var/log/my-app
```
在这个示例中,我们创建了一个Pod,其中包含一个名为container1的容器。我们使用了一个主机路径存储卷来存储应用程序的日志文件  
在volumes字段中,我们创建了一个名为logs的主机路径存储卷,并将其挂载到了/var/log/my-app 目录下。这个目录在主机上已经存在,我们可以在主机上查看和管理存储的日志文件  
需要注意的是,主机路径存储卷会将主机上的目录直接挂载到容器中,因此可能会存在安全风险和数据共享的问题。在使用时需要注意权限控制和数据隔离 
  </code></pre>
</details>
下面是一个使用主机路径存储卷存储日志文件的示例YAML文件  
## 持久化存储卷(PersistentVolume & Persistent Volume Claim)
持久化存储卷(PersistentVolume)持久化存储卷。它用来描述或者说用来定义一个存储卷,代表一个独立的存储资源。PV 通常代表一个存储卷,PVC与PV是一一对应关系,通常一个PV必须被Bound到一个PVC上,才能被Pod访问和使用  
<details>
  <summary>k8s-pv-pvc</summary>
  <pre><code>
下面举例说明如何使用PV;首先,需要在K8S中创建一个PV对象,可以使用yaml格式的配置文件如下
```
apiVersion: v1
kind: PersistentVolume
metadata:
  name: my-pv
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: my-storage-class
  nfs:
    path: /data/my-pv
    server: nfs-server.my-domain.com
```
这个配置文件定义了一个名为my-pv的PV对象,使用NFS存储后端,在服务器nfs-server.my-domain.com上,挂载在/data/my-pv路径下,容量为1GB 
它的访问模式为ReadWriteOnce,即只能被一个Pod挂载为读写模式。另外,它的持久化存储策略为Retain,即在PV对象被删除时,保留其存储内容。最后,它的存储类别为my-storage-class 
接下来,可以在K8S中创建一个Persistent Volume Claim(PVC)对象,例如：
```
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 500Mi
  storageClassName: my-storage-class
```
这个配置文件定义了一个名为my-pvc的PVC对象,请求500MB的存储空间,访问模式为ReadWriteOnce,存储类别为my-storage-class。 
最后,在Pod的配置文件中,可以使用volumeMounts和volumes字段,将PVC挂载为一个持久化存储卷,例如：
```
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
  containers:
  - name: my-container
    image: my-image
    volumeMounts:
    - mountPath: /data
      name: my-pv-volume
  volumes:
  - name: my-pv-volume
    persistentVolumeClaim:
      claimName: my-pvc
```
这个配置文件定义了一个名为my-pod的Pod对象,使用名为my-pv-volume的持久化存储卷,将PVC my-pvc挂载到/data路径下;这样Pod中的应用程序就可以使用/data路径下的持久化存储了
  </code></pre>
</details>


## 动态存储卷(Dynamic Volume Provisioning)
一个大规模的Kubernetes集群里很可能有成千上万个PVC,这就意味着运维人员必须得事先创建出成千上万个PV;更麻烦的是,随着新的PVC不断被提交,运维人员就不得不继续添加新的、能满足条件的PV,否则新的Pod就会因为PVC绑定不到PV而失败   
在实际操作中,这几乎没办法靠人工做到  

所以,Kubernetes为我们提供了一套可以自动创建PV的机制,即：Dynamic Provisioning。相比之下,前面人工管理PV的方式就叫作Static Provisioning。Dynamic Provisioning机制工作的核心,在于一个名叫StorageClass的API资源对象 

StorageClass是Kubernetes中一种动态存储类型,它可以根据不同的存储需求,自动选择不同的存储方案  
<details>
  <summary>k8s-StorageClass</summary>
  <pre><code>
面举个例子说明如何使用StorageClass;首先,需要在Kubernetes中创建一个StorageClass对象,可以使用yaml格式的配置文件,例如：
```
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: my-storage-class
provisioner: kubernetes.io/aws-ebs
parameters:
  type: gp2
```
这个配置文件定义了一个名为my-storage-class的StorageClass对象,使用AWS EBS存储后端,并使用gp2类型的存储。provisioner字段指定了存储后端的名称,parameters字段指定了存储参数  
接下来,可以在Kubernetes中创建一个PersistentVolumeClaim(PVC)对象,例如：
```
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
  storageClassName: my-storage-class
```
这个配置文件定义了一个名为my-pvc的PVC对象,请求1GB的存储空间,访问模式为ReadWriteOnce,存储类别为my-storage-class。
最后,在Pod的配置文件中,可以使用volumeMounts和volumes字段,将PVC挂载为一个持久化存储卷,例如：
```
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
  containers:
  - name: my-container
    image: my-image
    volumeMounts:
    - mountPath: /data
      name: my-pv-volume
  volumes:
  - name: my-pv-volume
    persistentVolumeClaim:
      claimName: my-pvc
```
这个配置文件定义了一个名为my-pod的Pod对象,使用名为my-pv-volume的持久化存储卷,将PVC my-pvc挂载到/data路径下 
这样Pod中的应用程序就可以使用/data路径下的持久化存储了;使用StorageClass和PVC,可以方便地管理和使用Kubernetes中的持久化存储
  </code></pre>
</details>

# 总结 
Storage Class是一种抽象的存储层,用于定义动态存储的策略和属性。它可以方便地管理和分配存储资源,支持多种存储类型和配置选项,提高了存储的灵活性和可靠性  
同时Storage Class也可以与Pod的声明式存储卷进行绑定,实现自动化的存储管理和调度  
动态存储可以通过统一的接口和控制器进行管理和监控,避免了手动管理的繁琐和复杂性;同时也可以通过自动化的方式实现存储资源的自愈和优化,降低了管理成本和风险  

***

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

