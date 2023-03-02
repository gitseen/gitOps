# K8S之污点污点容忍
**什么是污点**  
>>
节点亲和性是Pod的一种属性,它使Pod被吸引到一类特定的节点(这可能出于一种偏好,也可能是硬性要求)  
污点(Taint)则相反——它使节点能够排斥一类特定的Pod,也就是说避免pod调度到特定node上,告诉默认的pod,我拒绝你的分配,是一种主动拒绝的行为  

**什么是污点容忍**
是应用于Pod上的。容忍度允许调度器调度带有对应污点的Pod  
容忍度允许调度但并不保证调度。也就是说,允许pod调度到持有Taint的node上,希望pod能够分配到带污点的节点,增加了污点容忍,那么就会认可这个污点,就「有可能」分配到带污点的节点（如果希望pod可以被分配到带有污点的节点上,要在pod配置中添加污点容忍字段）  

污点和容忍（Toleration）相互配合,可以用来避免Pod被分配到不合适的节点上,每个节点上都可以应用一个或多个污点,这表示对于那些不能容忍这些污点的Pod, 是不会被该节点接受的   

再用大白话理解一下,也就是说,基于节点标签的分配,是站在Pod的角度上,它是通过在pod上添加属性来确定pod是否要调度到指定的node上的。其实,也还可以站在Node的角度上,通过在node上添加污点属性,来避免pod被分配到不合适的节点上  

# 语法格式
## 节点添加污点的语法格式
```
kubectl taint node xxxx key=value:[effect]
```
**effect(效果)**  
  - NoSchedule：不能被调度
  - PreferNoSchedule：尽量不要调度
  - NoExecute：不但不会调度,还会驱逐Node上已有的pod  
## 删除污点的语法格式
```
kubectl taint node xxxx key=value:[effect]-
```
# 实例子

<details>
  <summary>k8s-taint-1</summary>
  <pre><code>
给test-b-k8s-node02节点打上污点,不干预调度到哪台节点,让k8s按自己的算法进行调度,看看这10个pod会不会分配到带有污点的节点上
#打污点
kubectl taint node test-b-k8s-node02 disktype=sas:NoSchedule
#查看node详情的Taints字段
tantianran@test-b-k8s-master:~$ kubectl describe node test-b-k8s-node02 | grep Taint
Taints:             disktype=sas:NoSchedule

```
apiVersion: v1
kind: Namespace
metadata:
  name: test-a
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: goweb-demo
  namespace: test-a
spec:
  replicas: 10
  selector:
    matchLabels:
      app: goweb-demo
  template:
    metadata:
      labels:
        app: goweb-demo
    spec:
      containers:
      - name: goweb-demo
        image: 192.168.11.247/web-demo/goweb-demo:20221229v3
---
apiVersion: v1
kind: Service
metadata:
  name: goweb-demo
  namespace: test-a
spec:
  ports:
  - port: 80
    protocol: TCP
    targetPort: 8090
  selector:
    app: goweb-demo
  type: NodePort
```
kubectl get pod -n test-a -o wide
NAME                         READY   STATUS    RESTARTS   AGE   IP              NODE                NOMINATED NODE   READINESS GATES
goweb-demo-b98869456-84p4b   1/1     Running   0          18s   10.244.240.50   test-b-k8s-node01   <none>           <none>
goweb-demo-b98869456-cjjj8   1/1     Running   0          18s   10.244.240.13   test-b-k8s-node01   <none>           <none>
goweb-demo-b98869456-fxgjf   1/1     Running   0          18s   10.244.240.12   test-b-k8s-node01   <none>           <none>
goweb-demo-b98869456-jfdvl   1/1     Running   0          18s   10.244.240.43   test-b-k8s-node01   <none>           <none>
goweb-demo-b98869456-k6krp   1/1     Running   0          18s   10.244.240.41   test-b-k8s-node01   <none>           <none>
goweb-demo-b98869456-kcpsz   1/1     Running   0          18s   10.244.240.6    test-b-k8s-node01   <none>           <none>
goweb-demo-b98869456-lrkzc   1/1     Running   0          18s   10.244.240.49   test-b-k8s-node01   <none>           <none>
goweb-demo-b98869456-nqr2j   1/1     Running   0          18s   10.244.240.33   test-b-k8s-node01   <none>           <none>
goweb-demo-b98869456-pt5zk   1/1     Running   0          18s   10.244.240.28   test-b-k8s-node01   <none>           <none>
goweb-demo-b98869456-s9rt5   1/1     Running   0          18s   10.244.240.42   test-b-k8s-node01   <none>           <none>

#发现全部都在test-b-k8s-node01节点,test-b-k8s-node02节点有污点,因此拒绝承载pod
  </code></pre>
</details>
