[Helm官网](https://v3.helm.sh/zh/docs/)  

[Helm官方的chart站点](https://hub.kubeapps.com/)  

[Helm文档](https://www.qikqiak.com/k8s-book/docs/42.Helm%E5%AE%89%E8%A3%85.html)  

[Helm项目地址](https://github.com/helm/helm/releases)



# 什么是Helm?
Helm是Kubernetes的一个包管理器，可以让你轻松管理和部署复杂的应用程序。它提供了一种方法，通过被称为 "图表 "的可重复使用的包来简化Kubernetes资源的安装和管理。Helm的创建是为了简化部署和管理容器化应用程序的过程。  

# 为什么你应该考虑使用Heln
Helm通过将应用程序和服务打包成可重复使用和版本控制的图表，简化了Kubernetes部署管理。Helm图表是可定制的，易于分享，使你能够用一个命令部署复杂的应用程序。

# 在Kubernetes中使用Helm的优势
在与Kubernetes一起工作时，Helm有几个优势。
## 1 简化部署管理
Helm使你能够通过可重复使用的包来管理部署。你可以为一个特定的部署创建一个图表，并在不同的环境中使用它，而不必担心底层基础设施。
## 2 版本控制
图表是受版本控制的，因此很容易跟踪变化，并在必要时回滚到以前的版本
## 3 模块化
Helm图表是模块化的，意味着它们可以由多个子图表组成。这使你可以轻松地管理由多个微服务组成的复杂应用
## 4 可重用性
图表可以被共享和重复使用，无论是公开的还是在你的组织内部。这确保了一致性并减少了部署所需的时间  
## 使用Helm的命令示例
这里有一些Helm命令的例子，可以帮助你入门
```
helm install mychart ./mychart  #安装图表
helm upgrade mychart ./mychart  #更新
helm rollback mychart 1         #回滚
```
# Helm与Kubernetes有什么不同？
Kubernetes是一个用于容器化应用的协调平台，而Helm则是Kubernetes的一个软件包管理器。Helm简化了Kubernetes资源的部署和管理。

# 重要的舵手命令
```
helm install- 安装图表
helm upgrade - 升级一个版本
helm rollback- 回滚到以前的版本
helm delete--删除一个版本
helm fetch - 下载图表
helm repo add- 添加一个图表库
helm repo update - 更新一个图表存储库
helm dependency - 管理图表的依赖性
```
