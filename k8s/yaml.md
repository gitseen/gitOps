from https://www.toutiao.com/article/7196554496028246565  
# K8S集群中yaml文件说明
# 1、k8s常用指令
```
kubectl apply -f <文件名>   #根据yaml文件部署
kubectl delete -f <文件名>  #根据yaml文件删除
kubectl get node,pod,svc  #查看k8s个组件的状态
kubectl describe node <node名称>  #查看node详情
kubectl describe pod <pod名称> #查看pod详情
kubectl describe svc <svc名称> #查看service详情
kubectl delete svc <svc名称> -n <命名空间>  #删除svc 
kubectl exec -it <pod名称> -c <容器组空间> -n <命名空间> -- bash   #进入容器内部
kubectl cp -n <命名空间> <pod名称>:/文件src /本地文件  #容器拷贝文件到本地服务器
```
# 2、yaml文件配置说明
```
参考文档： Kubernetes中文文档
缩进标识层级关系
不支持制表符缩进，使用空格缩进
缩进的空格数目不重要，只要相同层级的元素左侧对齐即可
通常开头缩进两个空格
字符后缩进一个空格， 如冒号，逗号，- 等
“—”表示YAML格式，一个文件的开始，用于分隔文件间。
“#”表示注释，从这个字符一直到行尾，都会被解析器忽略　
在Kubernetes中，只需要知道两种结构类型即可：
Lists
Maps
```
   ## 2.1 yaml语法格式
   ### 2.1.1 YAML Maps
       Map指的是字典，即一个Key:Value 的键值对信息。例如：
       ```
       apiVersion: v1
       kind: Pod
　　   注：---为可选的分隔符 ，当需要在一个文件中定义多个结构的时候需要使用。上述内容表示有两个键apiVersion和kind，分别对应的值为v1和Pod。
       ```
       Maps的value既能够对应字符串也能够对应一个Maps
       ```
       apiVersion: v1
       kind: Pod
       metadata:
         name: kube100-site
         labels:
           app: web
 注：上述的YAML文件中，metadata这个KEY对应的值为一个Maps，而嵌套的labels这个KEY的值又是一个Map。实际使用中可视情况进行多层嵌套。  
 YAML处理器根据行缩进来知道内容之间的关联。上述例子中，使用两个空格作为缩进，但空格的数据量并不重要，只是至少要求一个空格并且所有缩进保持一致的空格数 。例如，name和labels是相同缩进级别，因此YAML处理器知道他们属于同一map；它知道app是lables的值因为app的缩进更大。
       ```
   ### 2.1.2 YAML Lists
   ## 2.2 yaml四个必须配置项
   ## 2.3 示例说明
   ### 2.3.1 yaml格式的pod定义文件
   ### 2.3.2 yaml格式的service定义文件
   ### 2.3.3 yaml格式的deployment定义文件
