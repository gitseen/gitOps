# kubernetes核心技术Label详解实例
## 什么是Kubernetes标签
在k8s的世界里**标签Label和选择器Selector**并不是最炫酷的技术,却是贯穿整个集群管理与运维流程的核心机制;  
正是它们让复杂的资源调度、查询、自动化运维变得井然有序、游刃有余  
k8s标签是将标识元数据链接到K8s对象的键值字符串对,可以使用标签从K8sAPI中检索和过滤数据,并对所选对象进行批量操作     
Label是k8s系统中的一个重要概念。它的作用就是在资源上添加标识,用来对它们进行区分和选择    
Label是一种用于标识和组织资源对象的键值对(key-value pair),可添加、修改和删除,不影响资源本身的运行状态,但却是组织、筛选、定位资源的利器    
Label可以附加到大多数K8s对象上(如Pod、Service、Deployment、Node...)   


## Label的基本语法
```yaml
labels:
  key: value
```
- Key ：通常由可选前缀和名称组成,例如app.kubernetes.io/name或简写为app
- Value ：任意非空字符串

**命名规则：创建新标签时,必须遵守k8s对长度和允许值的限制;标签值必须**  
- 包含63个字符或更少(标签的值也可以为空) 
- 以字母数字字符开始和结束(除非它是空的) 
- 仅包含破折号(-)、下划线(_)、点(.)和字母数字    
```bash 
kubectl get xx -o json | jq .metadata.labels 
```

## Label的用途
| 功能场景    | 说明 |
| --------- | :-------: |
|  服务发现  | Service通过标签selector来关联后端Pod   |
|  配置绑定  | ConfigMap、Secret可按标签挂载到对应Pod  |
|  资源选择(Selector)  | 通过Label Selector来筛选资源   |
|  调度控制 | 结合Node Label控制Pod调度到特定节点   |
|  滚动更新与回滚  |  Deployment、sts、ds等根据label管理Pod副本  |
|  组织资源  |  按环境、应用、版本等分类管理  |
|  运维查询  | kubectl get pod -l app=nginx 快速筛选资源 |  

可以通过Label实现资源的多维度分组,以便灵活、方便地进行资源分配、调度、配置、部署等管理工作  
一些常用的Label示例如下：  
* 版本标签："version":"release", "version":"stable"......
* 环境标签："environment":"dev","environment":"test","environment":"pro"
* 架构标签："tier":"frontend","tier":"backend"  

## 标签命名规范(Kubernetes官方建议)
| 标签键   | 说明 |
| --------- | :-------: |
| app.kubernetes.io/name   |  应用名称: 如mysql  |
| app.kubernetes.io/instance   |  部署实例名: mysql,nginx-prod   |
| app.kubernetes.io/version   | 版本: 如8.0.13   |
| app.kubernetes.io/component   | backend,frontend,database  |
| app.kubernetes.io/part-of   |  所属项目系统: 如shopping-app,ecommerce-system  |
| app.kubernetes.io/managed-by   | 管理工具: 如helm   |
|  env  | dev、test、prod  |
```yaml
apiVersion: v1
kind: Service
metadata:
  labels:
    app.kubernetes.io/name: wordpress
    app.kubernetes.io/instance: wordpress-abcxyz
    app.kubernetes.io/version: "4.9.4"
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/component: server
    app.kubernetes.io/part-of: wordpress
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app.kubernetes.io/name: wordpress
    app.kubernetes.io/instance: wordpress-abcxyz
    app.kubernetes.io/version: "4.9.4"
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/component: server
    app.kubernetes.io/part-of: wordpress
```

## 什么是选择器Selector
选择器是用于筛选资源的条件表达式,标签定义完毕之后,还要考虑到标签的选择;  
这就要使用到Label Selector(标签选择器),即Label用于给某个资源对象定义标识,Label Selector用于查询和筛选拥有某些标签的资源对象   
K8s支持两种类型的选择器  
- 1、等值选择器(Equality-based Selector)基于等式的Label Selector即 **=、==、!=**  
     - name = slave  
       选择所有包含Label中key="name"且value="slave"的对象 
     - env != production 
       选择所有包括Label中的key="env"且value不等于"production"的对象     
```yaml
#kubectl get pod -l name=slave,env!=prod  #等值选择器,name=slave,env!=production  
selector:
  matchLabels:
    app: nginx
    environment: production 
#kubectl get pods -l app=nginx
#kubectl get pods -l app!=nginx
#kubectl get pods -l app=nginx,environment=production
```

- 2、集合选择器(Set-based Selector)基于集合的Label Selector即 **in、notin、exists**    
     - name in (master, slave)  
       选择所有包含Label中的key="name"且value="master"或"slave"的对象  
     - name not in (frontend)
       选择所有包含Label中的key="name"且value不等于"frontend"的对象    
```yaml
#标签的选择条件可以使用多个,此时将多个LabelSelector进行组合,使用逗号","进行分隔即可。例如:
selector:
  matchExpressions:
    - key: app
      operator: In
      values: [nginx, redis]
    - key: version
      operator: Exists
#kubectl get pods -l 'app in (nginx, redis)'  #app在{nginx, redis}中
#kubectl get pods -l '!version'  #version不存在
#kubectl get pods -l environment #environment存在,无论值是什么
#kubectl get pods -l 'environment notin (dev, test)'  # environment notin (dev, test)
#kubectl get pod -l 'name not in frontend,env!=production'  #集合选择器,name not in (frontend),env!=production
#kubectl get pod -l 'env in (prod, staging),tier'           #表示查找env是prod或staging,且存在tier标签的Pod  
```

## 命令行操作Label实例
- 1、为deploy打标签  
```bash
#创建开发环境命名空间 dev
kubectl create ns dev

#在dev命名空间创建 deploy   mynginx
kubectl create deploy mynginx --image=nginx -n dev

#为mynginx 打标签  env=dev
kubectl label deploy mynginx env=dev -n dev
```
- 2、为deploy更新标签  
```bash
#为mynginx 打标签  version=1.0
kubectl label deploy mynginx version=1.0 -n dev

#为mynginx 更新标签 version=2.0
kubectl label deploy mynginx version=2.0 -n dev --overwrite
```
- 3、查看标签  
```bash
kubectl get deploy mynginx -n dev --show-labels
```
- 4、筛选标签  
现在有如下需求：我想知道哪些deploy有标签version=2.0？这个时候就需要用到筛选标签了   
```bash
#查看哪些deploy 被打上version=2.0 标签
kubectl get deploy -n dev -l version=2.0 --show-labels

#如果是需要通过多个标签筛选 标签之间以逗号分隔即可
kubectl get deploy -n dev -l version=2.0,app=mynginx --show-labels
```
- 5、删除标签  
```bash
#删除标签  在要删除的标签后面加"-"执行即可(key-)
kubectl label deploy mynginx version- -n dev
```
- 6、标签常用命令
```bash
kubectl get pods --show-labels  #查看资源的label
kubectl get pods -l app=nginx   #以label列出资源
kubectl label pods <pod-name> version=v1  #添加label
kubectl label pods <pod-name> version=v2 --overwrite #修改label(覆盖)
kubectl label pods <pod-name> version-   #删除 label
kubectl label nodes node-1 zone=beijing  #给节点打label
```
## Yaml操作Label实例
```yaml
先通过命令生成yaml模板;#生成mynginx.yaml然后改造
#kubectl create deploy mynginx --image=nginx -n dev -o yaml --dry-run=client > mynginx.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  creationTimestamp: null
  #在此下增加deploy的标签
  labels:
    app: mynginx
    evn: dev
    versioin: "2.0"
  name: mynginx
  namespace: dev
spec:
  replicas: 1
  selector:
    matchLabels:
      app: mynginx
  strategy: {}
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: mynginx
    spec:
      containers:
      - image: nginx
        name: nginx
        resources: {}
status: {}


#执行 
kubectl apply -f mynginx.yaml

#查看
kubectl get deploy -n dev --show-labels
```

## Label选择器使用
在kubernetes中,Pod是最小的控制单元,但是kubernetes很少直接控制Pod,一般都是通过Pod控制器来完成的;  
Pod控制器用于pod的管理,确保pod资源符合预期的状态,当pod的资源出现故障时,会尝试进行重启或重建pod  

在k8s中Pod控制器的种类有很多,本章节只介绍一种：Deployment;Deployment控制器就是通过标签选择器控制Pod的    
我们现在通过yaml创建deployment资源,并且控制pod副本也有3个;然后,将其中一个pod的标签 env=dev 删除,看看什么效果   
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  creationTimestamp: null
  labels:
    app: mynginx
  name: mynginx
  namespace: dev
spec:
  #控制pod 副本数量为3个
  replicas: 3
  selector:
    #deplyment通过标签选择器,控制拥有此标签的pod
    matchLabels:
      app: mynginx
      env: dev
  strategy: {}
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: mynginx
        env: dev
    spec:
      containers:
      - image: nginx
        name: nginx
        resources: {}
status: {}
```

>Q、k8s中资源清单yaml中spec.template.metadata.label功能是什么?  
>>kubectl get po -l pod-template为什么是hash值？  
pod-template-hash是k8s自动为控制器(Deployment、RS等)生成的一个标签用于**确保控制器只管理"自己模板创建的Pod",防止不同版本的Pod混淆**  
这个label的值是一个基于Pod模板(spec.template)内容计算出的哈希值   
kubectl get po --show-labels   
kubectl get po -L pod-template-hash   
#查看不同版本的Pod数量  
kubectl get pods -l app=nginx -o jsonpath='{range .items[*]}{.metadata.labels.pod-template-hash}{"\n"}{end}' | sort | uniq -c    

## 参考
[Recommended Labels](https://kubernetes.io/zh-cn/docs/concepts/overview/working-with-objects/common-labels/)   
[Labels and Selectors](https://kubernetes.io/zh-cn/docs/concepts/overview/working-with-objects/labels/)  



 
