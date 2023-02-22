# CRD
简介： 一个K8s集群是由分布式存储（etcd）、服务节点（Node）和控制节点（Master）构成的。所有的集群状态都保存在etcd中，Master节点上则运行集群的管理控制模块。Node节点是真正运行应用容器的主机节点，在每个服务节点上都会运行一个Kubelet代理，控制该节点上的容器、镜像和存储卷等。  

CRD（Custom Resource Define）客户自定义对象，是 Kubernetes（v1.7+）为提高可扩展性，让开发者去自定义资源的一种方式。CRD 资源可以动态注册到集群中，注册完毕后，用户可以通过 kubectl 来创建访问这个自定义的资源对象，类似于操作 Pod 一样。不过需要注意的是 CRD 仅仅是资源的定义而已，需要一个 Controller 去监听 CRD 的各种事件来添加自定义的业务逻辑。  

# 一、CRD定义
## 1、CRD是什么
CRD，CustomResourceDefinitions，也就是用户自定义K8S资源类型。内置的资源类型包含Deployment、Service、Node、Pod等等，可以通过CRD机制注册新的资源类型到K8S中。实际底层就是通过apiserver接口，在etcd中注册一种新的资源类型，此后就可以创建对应的资源对象了，就像我们为不同应用创建不同的Deployment对象一样。但是仅仅注册资源与创建资源对象通常是没有价值的，重要的是需要实现CRD背后的功能。比如，Deployment的功能是生成一定数量的POD并监控它们的状态。所以CRD需要配套实现Controller，相信也都听过Deployment Controller这些内置的Controller。Controller是需要CRD配套开发的程序，它通过apiserver监听相应类型的资源对象事件，例如：创建、删除、更新等等，然后做出相应的动作，比如Deployment创建/更新时需要对POD进行更新操作等。  

## 2、CRD实现
**Custom resources**  是K8S接口API的扩展，表示特定的kubetnetes的定制化安装。在一个运行中的集群中，自定义资源可以动态注册到集群中。注册完毕以后，用户可以通过kubelet创建和访问这个自定义的对象，类似于操作pod一样。  

**Custom controllers** Custom resources可以让用户存储和获取结构化数据。只有结合控制器才能变成一个真正的declarative API（被声明过的API）。控制器可以把资源更新成用户想要的状态，并且通过一系列操作和变更状态。定制化控制器是用户可以在运行中的集群内部署和更新的一个控制器，它独立于集群本身的生命周期。 定制化控制器可以和任何一种资源一起工作，当和定制化资源结合使用时尤其有效。  

**Operator** Operator是指将一个customer controllers和Custom resources结合的例子。它可以允许开发者将特殊应用编码至kubernetes的扩展API内。Operator其实就是两个部分: 控制器 + 用户自定义资源。  

# 如何在k8S集群中添加CRD
## 1、两种方式
   - Custom Resource Definitions (CRD)：更易用、不需要编码。但是缺乏灵活性。
   - API Aggregation：需要编码，允许通过聚合层的方式提供更加定制化的实  
## 2、使用实例
   - 查看CRD实例kubectl get crd查看
   - 查看所有的API资源kubectl api-resources查看集群中已定义的资源  
   ```
   NAME：CRD的复数名称
   SHORTNAMES：CLI中使用的资源简称
   APIGROUP：API所使用的组名称
   NAMESPACED：是否具有namespace属性
   KIND：资源文件需要，用以识别资源  
   ```
   - 查看某个API资源的详细信息
   ```
   kubectl get pods -o yaml|more查看pods资源详细信息
   ```  
# 如何在k8S集群中添加CRD
## 1、apiservice资源格式
```
执行指令# kubectl explain apiservice查看apiservice对象的信息
```
## 2、定义CRD扩展资源
```
kubectl explain customresourcedefinition查看CRD相关自定义字段
kubectl explain customresourcedefinition.spec 查看CRD相关进一步的字段信息
``` 
## 3、查看已经定义的CRD扩展资源
```
执行指令# kubectl get CustomResourceDefinition 
```
## 4、如何创建CRD扩展资源
```
写yaml
```  

[参考CRD](https://www.toutiao.com/article/7201056034784444962)
