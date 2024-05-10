# [k8s-storage](https://kubernetes.io/zh-cn/docs/concepts/storage)  

# k8s-Volume卷
1. 概念
  Kubernetes的卷是pod的一个组成部分,因此像容器一样在pod的规范中就定义了。它们不是独立的Kubernetes对象,也不能单独创建或删除。pod中的所有容器都可以使用卷,但必须先将它挂载在每个需要访问它的容器中。在每个容器中,都可以在其文件系统的任意位置挂载卷。

2. 为什么需要Volume
  容器磁盘上的文件的生命周期是短暂的,这就使得在容器中运行重要应用时会出现一些问题。首先,当容器崩溃时,kubelet会重启它,但是容器中的文件将丢失——容器以干净的状态（镜像最初的状态）重新启动。其次,在Pod中同时运行多个容器时,这些容器之间通常需要共享文件。Kubernetes中的Volume抽象就很好的解决了这些问题。

3. Volume类型
![Kubernetes支持以下Volume 类型](https://ask.qcloudimg.com/http-save/yehe-6211241/icx05vjlba.png)
![k8s-storage](pic/k8s-storage.png)
