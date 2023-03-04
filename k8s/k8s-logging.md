# kubernetes日志4种通用采集方案
- DaemonSet采集
- sidecar采集
- 同容器采集
- 独立存储采集  

# 一、DaemonSet采集方式
DaemonSet采集方式,利用k8s的DaemonSet控制器在每一个节点上部署一个收集日志容器用于该节点上所有容器的日志收集  
这种部署方式通过与节点上的docker.socket或containerd.sock与容器运行时通信以发现节点上所有容器,从返回的容器信息中获取容器的标准输出路径和存储路径,并挂载主机路径以采集数据  
![t-1](https://p3-sign.toutiaoimg.com/tos-cn-i-qvj2lq49k0/0b667556ca7a4ef38b901dc37df7b2a0~noop.image?_iz=58558&from=article.pc_detail&x-expires=1678525191&x-signature=O1p4CBX%2BAf7FMFZkMyF9YSusIGk%3D)  

**优点**  
  - 每个节点上只需要部署一个采集容器,与应用容器数量无关,节省资源,可以完整获取容器的meta信息,并且应用对采集容器不感知,完全没有侵入  

**缺点**  
- 发现容器的机制依赖与docker.sock或containerd.sock通信,docker有自己的EventListener机制可以实时获取容器的创建销毁事件;
  而containerd则没有,只能通过轮询机制了解容器的创建销毁,在最新版本中轮询间隔为1秒,因此可以认为发现容器的延迟为1s  
- 从发现容器到开始数据采集还有3~6秒左右的延迟,其中采集stdout的延迟来自stdout采集插件内部的轮询间隔,再加上一些处理耗时,DaemonSet方式预期的容器日志开始采集延迟在 5-8秒左右  


# 二、sidecar采集方式
sidecar采集方式,利用k8s同一个pod内的容器可以共享存储卷的特性,在一个业务pod内同时部署业务和采集容器以达到业务数据的目的。这种采集方式要求业务容器将采集的目录挂载出来与采集容器共享,采集容器则采用采集本地文件的方式采集业务容器日志  
![t-2](https://p3-sign.toutiaoimg.com/tos-cn-i-qvj2lq49k0/270d06c042b941d6be364ffc36f008ef~noop.image?_iz=58558&from=article.pc_detail&x-expires=1678525191&x-signature=FdHAio3XWiSFWwnJC860iuOf4Ag%3D)  

**优点**  
  - 无需关心容器发生问题,只要采集容器没有退出,Pod就处于Running状态,共享存储卷上的文件也不会删除因此也就无需担心采集延时导致数据丢失的问题
  - 随业务容器pod部署,支持各种弹性扩缩容方案  

**缺点**
  - 资源消耗大,每个pod都需要一个sidecar采集容器,其资源开销和业务pod数量成正比
  - 容器meta信息无法自动采集,需要通过环境变量等方式暴露到采集容器中
  - 每个业务pod都需要为目标数据配置共享存储,并且要考虑通知采集容器退出机制,存在一定侵入性
  
# 三、同容器采集
将采集进程和业务进程同容器部署,相当于将容器视为一个虚拟机的部署方式,因此采集的原理完全同主机  
![t-3](https://p3-sign.toutiaoimg.com/tos-cn-i-qvj2lq49k0/359565f0b7fd46848271e92d7382bffc~noop.image?_iz=58558&from=article.pc_detail&x-expires=1678525191&x-signature=lUmiws0emxAQWRUfJ0diwStoYF8%3D)  
```
虽然这种方式看上去非常笨重,侵入性高,但是在老业务容器化过程中十分常见

由于采集进程和业务进程工作在同一容器中,因此这种采集方式不存在容器发现和开始采集的延迟,也完全支持各类弹性方案

在资源开销方面,每个业务容器均额外消耗采集进程开销,资源消耗较大。而要采集容器的meta信息,则需要通过环境变量等方式暴露在业务容器中,不能进行自动标注
``` 
# 四、独立存储采集
独立存储采集方式是指容器将要采集的数据都打印到共享的pv或hostpath挂载的路径上，而采集容器只需关心将pv或hostpath是哪个的数据采集上来的采集方案  

使用共享pv上时，所有采集数据只需要1个采集容器。使用hostpath时，需要使用DaemonSet部署采集容器，使每个节点上都恰好有一个采集容器  
![t-4](https://p3-sign.toutiaoimg.com/tos-cn-i-qvj2lq49k0/6ae7af41dc034870866899ad09ed4836~noop.image?_iz=58558&from=article.pc_detail&x-expires=1678525191&x-signature=LFQFCE6GT3rQqZUkZyX%2FY2pWThg%3D)  

使用独立存储后，数据的生命周期和容器的生命周期分离，采集容器仅需根据路径采集存储上的数据即可，因此没有发现容器和开始采集延时的问题  

**优势** 
- 采集容器不随业务容器增长
- 资源占用非常节省
- 对业务容器无入侵  

**缺点**  
- 性能不佳，容易成为采集瓶颈
- 如果使用hostpath则无法支持弹性容器

# 小结
[日志通用采集方案-渊在kube](https://www.toutiao.com/article/7174313065696100899/)  

