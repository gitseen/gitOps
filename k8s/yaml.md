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
   ### 2.1.2 YAML Lists
   ## 2.2 yaml四个必须配置项
   ## 2.3 示例说明
   ### 2.3.1 yaml格式的pod定义文件
   ### 2.3.2 yaml格式的service定义文件
   ### 2.3.3 yaml格式的deployment定义文件
