# POD状态
  - Pending
    - ContainerCreating
      - 正常状态
        - 正常终止
          - Succeeded
        - 正常运行
          - Running
        - 任务完成
          - Completed
        - 初始化中
          - init
        - 短时间
          - 创建中
            - ContainerCreating
      - 错误状态
        - 异常终止
          - Failed
        - 无法判断
          - Unknown
        - 崩溃循环
          - CrashLoopBackOff
        - 被驱除
          - Evicted
        - 节点丢失
          - NodeLost
        - 过程错误
          - ERR开头
        - 长时间
          - 网络问题
            - ContainerCreating

# Pending
```bash
Pod已经被创建，但还没有完成调度，或者说有一个或多个镜像正处于从远程仓库下载的过程。
处在这个阶段的Pod可能正在写数据到etcd中、调度、pull镜像或启动容器。
```

# Running
```bash
该 Pod 已经绑定到了一个节点上，Pod 中所有的容器都已被创建。至少有一个容器正在运行，或者正处于启动或重启状态。
```

# Succeeded
```bash
Pod中的所有的容器已经正常的执行后退出，并且不会自动重启，一般会是在部署job的时候会出现。
```

# Failed
```bash
Pod 中的所有容器都已终止了，并且至少有一个容器是因为失败终止。也就是说，容器以非0状态退出或者被系统终止。
```
 
# Unkonwn
```bash
API Server无法正常获取到Pod对象的状态信息，通常是由于其无法与所在工作节点的kubelet通信所致。
```



 # Pod详细的状态说明       
| 状态    | 描述 | 
| :-------- | :----- |
| CrashLoopBackOff  | 容器退出,kubelet正在将它重启  |
| CreateContainerConfigError  | 不能创建kubelet使用的容器配置  |
| CreateContainerError  |  创建容器失败 |
| CreateContainerConfigError | 不能创建kubelet使用的容器配置  |
| ContainersNotInitialized  | 容器没有初始化完毕  |
| ContainersNotRead	  | 容器没有准备完毕  |
| ContainerCreating	  | 容器创建中  |
| ContainersReady | 表示Pod中的所有容器是否已经准备就绪  |
| DockerDaemonNotReady   | docker还没有完全启动  |
| Evicte  | pod被驱赶 |
| ErrImageNeverPull  | 策略禁止拉取镜像  |
| ErrImagePull	  |  通用的拉取镜像出错 |	
| m.internalLifecycle.PreStartContainer  | 执行hook报错  |
| NetworkPluginNotReady  | 网络插件还没有完全启动  |
| ImageInspectError  | 无法校验镜像  |
| ImagePullBackOff	  |  正在重试拉取 |
| Initialized | 表示Pod中的所有容器是否已经初始化  |
| InvalidImageName | 无法解析镜像名称  |
| PostStartHookError  | 执行hook报错  |
| PodScheduled  | 表示Pod是否已经被调度到了节点上  |
| PodInitializing  | pod初始化中  |
| RunContainerError   | 启动容器失败  |
| Ready   | Pod是否已经准备就绪,即所有容器都已经启动并且可以接收流量|
| RegistryUnavailable | 连接不到镜像中心  |

