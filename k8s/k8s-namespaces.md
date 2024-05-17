# Namesapces概念
kubernetes-namespaces有助于不同的项目、团队或客户去共享Kubernetes集群;namespace通过以下方式实现项目和应用的隔离  
- 设置作用域(命名空间的限制;使用命名空间隔离不同的使用者)  
  + 不同命名空间没有共同的所有权概念  
    即使它们属于同一个团队,如某个团队控制了多个命名空间,K8s不仅没有任何关于这些命名空间的共同所有者的记录,而且针对命名空间范围内的策略也无法跨多个命名空间生效  
  + 能够自主运作,团队协作效率会更高  
    创建命名空间是需要高级权限的,所以开发团队的任何成员都不可能有权限创建命名空间  
    这就意味着,每当某个团队想要创建新的命名空间时,就必须向集群管理员提出申请,这种方式对小规模组织还可以接受,但随着组织的发展壮大,势必需要寻求更佳的方案  
- 为集群中的部分资源关联鉴权和策略的机制
  + 策略继承  
    如果一个命名空间是另一个命名空间的子空间,那么权限策略(如RBAC RoleBindings)将会从父空间直接复制到子空间
  + 继承创建权限  
    通常情况下,需要管理员权限才能创建命名空间,但层级命名空间提供了一个新方案：子命名空间(subnamespaces),只需要使用父命名空间中的部分权限即可操作子命名空间 

Kubernetes在默认情况下集群上有三个命名空间：
  - default  
    向集群中添加对象而不提供命名空间,这样它会被放入默认的命名空间中,在创建替代的命名空间之前,该命名空间会充当用户新添加资源的主要目的地,无法删除  
  - kube-public
    目的是让所有具有或不具有身份验证的用户都能全局可读;这对于公开bootstrap组件所需的集群信息非常有用;它主要是由k8s自己管理  
  - kube-system
    用于k8s管理的k8s组件,避免向该命名空间添加普通的工作负载;它一般由系统直接管理,因此具有相对宽松的策略
>虽然这些命名空间有效地将用户工作负载与系统管理的工作负载隔离,但它们并不强制使用任何额外的结构对应用程序进行分类和管理

# Operater
## namespaces查询
Namesapce-cli
```bash
kubectl get namespaces 
kubectl get namespaces --show-labwls
kubectl describe ns default
```
namespace有两种常见的状态
- Active  
- Terminating
>对应的命名空间还存在运行的资源,但该命名空间被删除时才会出现Terminating状态,这种情况下只要等待K8s本身将命名空间下的资源回收后,该命名空间将会被系统自动删除

## namespaces创建
- CLI
```bash
  kubectl create namespace production
```
- yaml
```bash
apiVersion: v1
kind: Namespace
metadata:
  name: production
  labels:
    name: production
#kubectl create -f namespace-production.yaml
#kubectl apply -f namespace-production.yaml
```

##  namespaces选择Context
```bash
kubectl config view
kubectl config get-contexts
kubectl config current-context
kubectl config set-context $(kubectl config current-context) --namespaces=production #production设成为默认namespaces
kubectl config set-context $(kubectl config current-context) --namespaces=          #还原成默认default
kubectl api-resources -o name --verbs=list --namespaced 
kubectl api-resources -o name --verbs=list --namespaced | xargs -n 1 kubectl get --show-kind --ignore-not-found -n easyv

#示例
kubectl config set-context dev --namespace=development \
  --cluster=lithe-cocoa-92103_kubernetes \
  --user=lithe-cocoa-92103_kubernetes
#示例
kubectl config set-context prod --namespace=production \
  --cluster=lithe-cocoa-92103_kubernetes \
  --user=lithe-cocoa-92103_kubernetes
```

## namespaces删除
```bash
  kubectl delete namespace production
  kubectl delete -f namespace-production.yaml
  kubectl delete ns ns_name
  kubectl delete ns ns_name --force --grace-period=0
```


# k8s-不受命名空间约束的对象
  - StorageClass  
    用于定义动态存储卷的存储类别;它允许管理员定义不同类型的存储类别,为不同的PV提供动态分配;  
    StorageClass也是全局对象,不与特定的命名空间相关联
  - PersistentVolumes   
    PV是独立于命名空间的存储资源;PV表示集群中的存储卷,它们可以被Pod使用  
    PV通常由集群管理员创建,并且它们不属于特定的命名空间;Pod可以通过PersistentVolumeClaim(PVC)来请求PV,并将其挂载到Pod中  
    >PersistentVolumeClaims区分命名空间
  - PriorityClass  
    用于定义Pod优先级的对象;它允许您为Pod分配优先级,以确保重要的Pod在资源有限时获得更多的资源;  
    PriorityClass也是全局对象,不受命名空间约束
  - ClusterRole和ClusterRoleBinding  
    用于定义集群级别的角色和角色绑定;允许定义对整个集群范围内资源的访问权限,而不是针对特定命名空间的资源
  - CustomResourceDefinition(CRD)  
    允许用户定义自定义资源类型;这些自定义资源类型可以是全局性质的,不受命名空间的限制
  - namespaces  


