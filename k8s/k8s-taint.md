# K8S之污点污点容忍
**什么是污点**  
>>
节点亲和性是Pod的一种属性,它使Pod被吸引到一类特定的节点(这可能出于一种偏好,也可能是硬性要求)  
污点(Taint)则相反——它使节点能够排斥一类特定的Pod,也就是说避免pod调度到特定node上,告诉默认的pod,我拒绝你的分配,是一种主动拒绝的行为  

**什么是污点容忍**  
是应用于Pod上的。容忍度允许调度器调度带有对应污点的Pod  
容忍度允许调度但并不保证调度。也就是说,允许pod调度到持有Taint的node上,希望pod能够分配到带污点的节点,增加了污点容忍,那么就会认可这个污点,就「有可能」分配到带污点的节点（如果希望pod可以被分配到带有污点的节点上,要在pod配置中添加污点容忍字段）  

污点和容忍(Toleration)相互配合,可以用来避免Pod被分配到不合适的节点上,每个节点上都可以应用一个或多个污点,这表示对于那些不能容忍这些污点的Pod, 是不会被该节点接受的   

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
# 实例
**环境信息**  
```
test-b-k8s-master
test-b-k8s-node01
test-b-k8s-node02
```
eg1:测试给test-b-k8s-node02节点打上污点,不干预调度到哪台节点,让k8s按自己的算法进行调度,看看这10个pod会不会分配到带有污点的节点上  

<details>
  <summary>k8s-taint-1</summary>
  <pre><code>
#打污点
kubectl taint node test-b-k8s-node02 disktype=sas:NoSchedule
#查看node详情的Taints字段
kubectl describe node test-b-k8s-node02 | grep Taint
Taints:             disktype=sas:NoSchedule

```
#yaml-file
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



eg2: test-b-k8s-node02节点已经有污点了,再通过nodeSelector强行指派到该节点,看看会不会分配到带有污点的节点上   

<details>
  <summary>k8s-taint-2</summary>
  <pre><code>
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
      nodeSelector:
        disktype: sas
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
kubectl get pod -n test-a
NAME                          READY   STATUS    RESTARTS   AGE
goweb-demo-54bc765fff-2gb98   0/1     Pending   0          20s
goweb-demo-54bc765fff-67c56   0/1     Pending   0          20s
goweb-demo-54bc765fff-6fdvx   0/1     Pending   0          20s
goweb-demo-54bc765fff-c2bgd   0/1     Pending   0          20s
goweb-demo-54bc765fff-d55mw   0/1     Pending   0          20s
goweb-demo-54bc765fff-dl4x4   0/1     Pending   0          20s
goweb-demo-54bc765fff-g4vb2   0/1     Pending   0          20s
goweb-demo-54bc765fff-htjkp   0/1     Pending   0          20s
goweb-demo-54bc765fff-s76rh   0/1     Pending   0          20s
goweb-demo-54bc765fff-vg6dn   0/1     Pending   0          20s
#该节点明明存在污点,又非得往上面指派,因此让所有Pod处于在了Pending的状态,也就是待分配的状态,那如果非要往带有污点的Node上指派pod,怎么办？看例子k8s-taint-3
  </code></pre>
</details>

eg3: 非要往带有污点的Node上指派pod，保留nodeSelector，直接增加污点容忍，pod是不是肯定会分配到带有污点的节点上？测试下便知  

<details>
  <summary>k8s-taint-3</summary>
  <pre><code>
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
      nodeSelector:
        disktype: sas
      tolerations:
      - key: "disktype"
        operator: "Equal"
        value: "sas"
        effect: "NoSchedule"
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
kubectl get pod -n test-a
NAME                          READY   STATUS    RESTARTS   AGE
goweb-demo-68cf558b74-6qddp   0/1     Pending   0          109s
goweb-demo-68cf558b74-7g6cm   0/1     Pending   0          109s
goweb-demo-68cf558b74-f7g6t   0/1     Pending   0          109s
goweb-demo-68cf558b74-kcs9j   0/1     Pending   0          109s
goweb-demo-68cf558b74-kxssv   0/1     Pending   0          109s
goweb-demo-68cf558b74-pgrvb   0/1     Pending   0          109s
goweb-demo-68cf558b74-ps5dn   0/1     Pending   0          109s
goweb-demo-68cf558b74-rb2w5   0/1     Pending   0          109s
goweb-demo-68cf558b74-tcnj4   0/1     Pending   0          109s
goweb-demo-68cf558b74-txqfs   0/1     Pending   0          109s
#在上面的yaml中，tolerations字段为污点容忍，经过测试就可以回答刚才的问题：保留nodeSelector，直接增加污点容忍，pod是不是肯定会分配到带有污点的节点上？
经过测试后，给出的答案是：不是  例子4(去掉nodeSelector)

  </code></pre>
</details>

eg4:现在把nodeSelector去掉，只留下污点容忍，看看pod会不会有可能分配到打了污点的节点上  

<details>
  <summary>k8s-taint-4</summary>
  <pre><code>
现在把nodeSelector去掉，只留下污点容忍，看看pod会不会有可能分配到打了污点的节点上
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
      tolerations:
      - key: "disktype"
        operator: "Equal"
        value: "sas"
        effect: "NoSchedule"
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
NAME                          READY   STATUS    RESTARTS   AGE    IP              NODE                NOMINATED NODE   READINESS GATES
goweb-demo-55ff5cd68c-287vw   1/1     Running   0          110s   10.244.222.57   test-b-k8s-node02   <none>           <none>
goweb-demo-55ff5cd68c-7s7zb   1/1     Running   0          110s   10.244.222.24   test-b-k8s-node02   <none>           <none>
goweb-demo-55ff5cd68c-84jww   1/1     Running   0          110s   10.244.240.24   test-b-k8s-node01   <none>           <none>
goweb-demo-55ff5cd68c-b5l9m   1/1     Running   0          110s   10.244.240.15   test-b-k8s-node01   <none>           <none>
goweb-demo-55ff5cd68c-c2gfp   1/1     Running   0          110s   10.244.222.3    test-b-k8s-node02   <none>           <none>
goweb-demo-55ff5cd68c-hpjn4   1/1     Running   0          110s   10.244.240.62   test-b-k8s-node01   <none>           <none>
goweb-demo-55ff5cd68c-j5bvc   1/1     Running   0          110s   10.244.222.43   test-b-k8s-node02   <none>           <none>
goweb-demo-55ff5cd68c-r95f6   1/1     Running   0          110s   10.244.240.16   test-b-k8s-node01   <none>           <none>
goweb-demo-55ff5cd68c-rhvmw   1/1     Running   0          110s   10.244.240.60   test-b-k8s-node01   <none>           <none>
goweb-demo-55ff5cd68c-rl8nh   1/1     Running   0          110s   10.244.222.8    test-b-k8s-node02   <none>           <none>
#从上面的分配结果可以看出，有些Pod分配到了打了污点容忍的test-b-k8s-node02节点上
  </code></pre>
</details>

eg5: 再玩个小例子，让它容忍任何带污点的节点，master默认也是有污点的（二进制搭建的除外），那pod会不会有可能跑master去哦？测试一下便知  

<details>
  <summary>k8s-taint-5</summary>
  <pre><code>
先看看master的污点情况
```
kubectl describe node test-b-k8s-master | grep Taint
Taints:             node-role.kubernetes.io/control-plane:NoSchedule
```
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
      tolerations:
        - effect: "NoSchedule"
          operator: "Exists"
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
NAME                          READY   STATUS             RESTARTS   AGE   IP              NODE                NOMINATED NODE   READINESS GATES
goweb-demo-65bbd7b49c-5qb5m   0/1     ImagePullBackOff   0          20s   10.244.82.55    test-b-k8s-master   <none>           <none>
goweb-demo-65bbd7b49c-7qqw8   1/1     Running            0          20s   10.244.222.13   test-b-k8s-node02   <none>           <none>
goweb-demo-65bbd7b49c-9tflk   1/1     Running            0          20s   10.244.240.27   test-b-k8s-node01   <none>           <none>
goweb-demo-65bbd7b49c-dgxhx   1/1     Running            0          20s   10.244.222.44   test-b-k8s-node02   <none>           <none>
goweb-demo-65bbd7b49c-fbmn5   1/1     Running            0          20s   10.244.240.1    test-b-k8s-node01   <none>           <none>
goweb-demo-65bbd7b49c-h2nnz   1/1     Running            0          20s   10.244.240.39   test-b-k8s-node01   <none>           <none>
goweb-demo-65bbd7b49c-kczsp   1/1     Running            0          20s   10.244.240.40   test-b-k8s-node01   <none>           <none>
goweb-demo-65bbd7b49c-ms768   1/1     Running            0          20s   10.244.222.45   test-b-k8s-node02   <none>           <none>
goweb-demo-65bbd7b49c-pbwht   0/1     ErrImagePull       0          20s   10.244.82.56    test-b-k8s-master   <none>           <none>
goweb-demo-65bbd7b49c-zqxlt   1/1     Running            0          20s   10.244.222.18   test-b-k8s-node02   <none>           <none>

#两个pod调度到了master上;
#警告：要注意了，master之所以默认会打上污点，是因为master是管理节点、考虑到安全的问题，所以master节点是不建议跑常规的pod(或者说是不建议跑业务pod)

  </code></pre>
</details>


eg6: 打了污点的节点，到底有没有办法可以强行分配到该节点上？我们试试  

<details>
  <summary>k8s-taint-6</summary>
  <pre><code>
```
kubectl describe node test-b-k8s-node02 | grep Taint
Taints:             disktype=sas:NoSchedule
```
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
      nodeName: test-b-k8s-node02
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
在上面的配置中，注意nodeName字段，nodeName指定节点名称，用于将Pod调度到指定的Node上，它的机制是[不经过调度器]
kubectl get pod -n test-a -o wide
NAME                         READY   STATUS    RESTARTS   AGE   IP              NODE                NOMINATED NODE   READINESS GATES
goweb-demo-dd446d4b9-2zdnx   1/1     Running   0          13s   10.244.222.39   test-b-k8s-node02   <none>           <none>
goweb-demo-dd446d4b9-4qbg9   1/1     Running   0          13s   10.244.222.6    test-b-k8s-node02   <none>           <none>
goweb-demo-dd446d4b9-67cpl   1/1     Running   0          13s   10.244.222.63   test-b-k8s-node02   <none>           <none>
goweb-demo-dd446d4b9-fhsgf   1/1     Running   0          13s   10.244.222.53   test-b-k8s-node02   <none>           <none>
goweb-demo-dd446d4b9-gp9gj   1/1     Running   0          13s   10.244.222.49   test-b-k8s-node02   <none>           <none>
goweb-demo-dd446d4b9-hzvs2   1/1     Running   0          13s   10.244.222.9    test-b-k8s-node02   <none>           <none>
goweb-demo-dd446d4b9-px598   1/1     Running   0          13s   10.244.222.22   test-b-k8s-node02   <none>           <none>
goweb-demo-dd446d4b9-rkbm4   1/1     Running   0          13s   10.244.222.40   test-b-k8s-node02   <none>           <none>
goweb-demo-dd446d4b9-vr9mq   1/1     Running   0          13s   10.244.222.17   test-b-k8s-node02   <none>           <none>
goweb-demo-dd446d4b9-wnfqc   1/1     Running   0          13s   10.244.222.16   test-b-k8s-node02   <none>           <none>
#发现，所有Pod都分配到了test-b-k8s-node02节点，怎么不会分一些到test-b-k8s-node01节点？原因就是，它的机制是不经过调度器的  
nodeName这个字段建议在生产环境中还是少用，所有Pod都在一个节点上，这就存在单点故障了。其实，测试环境下还是可以用的嘛
  </code></pre>
</details>

[不背锅运维-K8S之污点、污点容忍](https://www.google.com/)


# k8s的token默认是24小时的可以在master节点创建一个永不过期的token
```
1、列出现在的24小时的token：
kubeadm token list
2、删除掉快过期的token：
kubeadm token delete 查出的token值
3、创建一个永不过期的token：
kubeadm token create --ttl 0
4、打印node节点加入集群的命令：
kubeadm token create  --print-join-command
```
https://m.toutiao.com/is/i8AkG1n/

