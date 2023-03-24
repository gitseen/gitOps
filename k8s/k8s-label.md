# kubernetes核心技术Label详解实例
## 什么是Kubernetes标签
Kubernetes标签是将标识元数据链接到Kubernetes对象的键值字符串对;Kubernetes为团队提供了集成支持,可以使用标签从Kubernetes API中检索和过滤数据,并对所选对象进行批量操作  
Label是kubernetes系统中的一个重要概念。它的作用就是在资源上添加标识,用来对它们进行区分和选择  

**创建新标签时,必须遵守Kubernetes对长度和允许值的限制;标签值必须**  
- 包含63个字符或更少(标签的值也可以为空)
- 以字母数字字符开始和结束(除非它是空的)
- 仅包含破折号(-)、下划线(_)、点(.)和字母数字    
#kubectl get xx -o json | jq .metadata.labels 


**Label的特点**  
- 一个Label会以key/value键值对的形式附加到各种对象上,如Node、Pod、Service等等
- 一个资源对象可以定义任意数量的Label ,同一个Label也可以被添加到任意数量的资源对象上去
- Label通常在资源对象定义时确定,当然也可以在对象创建后动态添加或者删除 


可以通过Label实现资源的多维度分组,以便灵活、方便地进行资源分配、调度、配置、部署等管理工作  

一些常用的Label示例如下：  
* 版本标签："version":"release", "version":"stable"......
* 环境标签："environment":"dev","environment":"test","environment":"pro"
* 架构标签："tier":"frontend","tier":"backend"  

标签定义完毕之后,还要考虑到标签的选择,这就要使用到Label Selector(标签选择器),即：   
Label用于给某个资源对象定义标识  
Label Selector用于查询和筛选拥有某些标签的资源对象  
当前有两种Label Selector：  
    * 基于等式的Label Selector  
         - name = slave: 选择所有包含Label中key="name"且value="slave"的对象
         - env != production: 选择所有包括Label中的key="env"且value不等于"production"的对象
    * 基于集合的Label Selector  
         - name in (master, slave): 选择所有包含Label中的key="name"且value="master"或"slave"的对象
         - name not in (frontend): 选择所有包含Label中的key="name"且value不等于"frontend"的对象  

标签的选择条件可以使用多个,此时将多个Label Selector进行组合,使用逗号","进行分隔即可。例如：  
name=slave,env!=production
name not in (frontend),env!=production

## 命令行操作Label实例
- 1、为deploy打标签  
```
#创建开发环境命名空间 dev
kubectl create ns dev

#在dev命名空间创建 deploy   mynginx
kubectl create deploy mynginx --image=nginx -n dev

#为mynginx 打标签  env=dev
kubectl label deploy mynginx env=dev -n dev
```
- 2、为deploy更新标签  
```
#为mynginx 打标签  version=1.0
kubectl label deploy mynginx version=1.0 -n dev

#为mynginx 更新标签 version=2.0
kubectl label deploy mynginx version=2.0 -n dev --overwrite
```
- 3、查看标签  
```
kubectl get deploy mynginx -n dev --show-labels
```
- 4、筛选标签  
现在有如下需求：我想知道哪些deploy有标签version=2.0？这个时候就需要用到筛选标签了   
```
#查看哪些deploy 被打上version=2.0 标签
kubectl get deploy -n dev -l version=2.0 --show-labels

#如果是需要通过多个标签筛选 标签之间以逗号分隔即可
kubectl get deploy -n dev -l version=2.0,app=mynginx --show-labels
```
- 5、删除标签  
```
#删除标签  在要删除的标签后面加"-"执行即可(key-)
kubectl label deploy mynginx version- -n dev
```
## Yaml操作Label实例

我们通过yaml实现2中创建deploy资源,名称为mynginx,增加标签 env=dev,version=2.0  
```
先通过命令生成yaml模板;#生成mynginx.yaml然后改造
kubectl create deploy mynginx --image=nginx -n dev -o yaml --dry-run=client > mynginx.yaml
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
在kubernetes中,Pod是最小的控制单元,但是kubernetes很少直接控制Pod,一般都是通过Pod控制器来完成的;Pod控制器用于pod的管理,确保pod资源符合预期的状态,当pod的资源出现故障时,会尝试进行重启或重建pod  

在kubernetes中Pod控制器的种类有很多,本章节只介绍一种：Deployment;Deployment控制器就是通过标签选择器控制Pod的  
![label](https://p3-sign.toutiaoimg.com/tos-cn-i-qvj2lq49k0/5a0d6972d37c4e57b45c0fd5101810e0~noop.image?_iz=58558&from=article.pc_detail&x-expires=1680224654&x-signature=WVQRkWK6IT68uxENSC%2F0%2Fr00TIw%3D)  

从上图可以看出,deployment控制器通过匹配标签env=dev 来控制Pod  
我们现在通过yaml创建deployment资源,并且控制pod副本也有3个;然后,将其中一个pod的标签 env=dev 删除,看看什么效果  
```
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





---
## 参考
[kubernetes核心技术Label详解实例](https://www.toutiao.com/article/7211480372813791782/)  

[Kubernetes标签10个最佳实践的专家指南](https://www.toutiao.com/article/7183134536300020264/)  
 
 
