# [k8s-kubectl查看和切换context](https://bbs.huaweicloud.com/blogs/369116)  
```bash
【摘要】 kubectl use-context配置多集群访问今天在rancher平台上进行日常维护。在多个集群切换时，鼠标一顿点点点还是有点不够顺畅。于是在"瑞斯拜"的chrome里面找到了k8s有关多集群访问配置的桥段，下面根据实践过程做简单描述使用 kubeconfig 文件组织集群访问通过 kubectl 连接k8s集群时，默认情况下，kubectl 会在 $HOME/.kube 目录下查找名...
```
# 使用 kubeconfig 文件组织集群访问
通过 kubectl 连接k8s集群时，默认情况下，kubectl 会在 $HOME/.kube 目录下查找名为 config 的文件，我直接root用户登录的、我的 config配置文件路径为 ~/.kube/config下面贴上具体的配置和简要注释


# kubectl config 命令见帮助信息

5. 或取全局上下文
kubectl config get-contexts




6. 获取当前K8S上下文
kubectl config current-context




7. 切换当前上下文
kubectl config use-context kubernetes-dev




8. kubectl config 命令见帮助信息
current-context 显示 current_context
delete-cluster 删除 kubeconfig 文件中指定的集群
delete-context 删除 kubeconfig 文件中指定的 context
get-clusters 显示 kubeconfig 文件中定义的集群
get-contexts 描述一个或多个 contexts
rename-context Renames a context from the kubeconfig file.
set 设置 kubeconfig 文件中的一个单个值
set-cluster 设置 kubeconfig 文件中的一个集群条目
set-context 设置 kubeconfig 文件中的一个 context 条目
set-credentials 设置 kubeconfig 文件中的一个用户条目
unset 取消设置 kubeconfig 文件中的一个单个值
use-context 设置 kubeconfig 文件中的当前上下文
view 显示合并的 kubeconfig 配置或一个指定的 kubeconfig 文件


