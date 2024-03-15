# [Kubernetes-Node-Not Ready问题排查](https://mp.weixin.qq.com/s/GxTtiqMpcrDWK9toaK5CMw) 
from-云原生运维圈
```bash
kubectl get nodes
kubectl describe node xx

/var/log/syslog
/var/log/messages
/var/log/kern.log
journalctl -u kubelet

systemctl restart kubelet 

df -Th;free -mh;top

ping node-ip
nc -zv master 6443

kubectl get componentstatuses=cs


```







# [K8S运维必备排查手册-dbaplus社群](https://www.toutiao.com/article/7278881534839669303)   


 


# [Kubernetes-排障方法](https://thenewstack.io/kubernetes-troubleshooting-primer/)


Kubernetes集群进行调试和故障排除对运维服务稳定至关重要。故障排除包括识别、诊断和解决Kubernetes集群、节点、Pod、容器和其他资源中的各类问题。   

由于Kubernetes是一个复杂的系统,因此解决问题可能具有挑战性。问题可能发生在单个容器、一个或多个pod、control、control plane 组件或这些组件的组合中。  
这使得即使在小型本地Kubernetes集群中诊断和修复错误也具有挑战性。如果在大规模生产设置中能见度有限且移动部件众多,问题就会变得更糟。

解决这些问题的成功方法,Kubernetes问题和解决方案包括  
- ImagePullBackOff  
- CrashLoopBackOff  
- out-of-memory(OOM)错误  
- BackOffLimitsExceeded
- liveness和readiness探针问题  

最常见的Kubernetes错误消息和问题、出现时用于识别它们的命令以及解决它们的提示。  

# 一、ImagePullBackOff
1、Kubernetes pod无法启动的原因之一是运行时无法从注册表中检索容器镜像。换句话说,pod不会启动,因为至少有一个在清单中指定的容器没有启动。  

2、当pod遇到此问题时,kubectl get pods命令会将pod的状态显示为ImagePullBackOff。当镜像名称或标签错误地输入到pod清单中时,可能会发生此错误。在这种情况下,从连接到Docker注册表的任何集群节点使用docker pull来确认正确的镜像名称。然后,在pod清单中更改它。  

3、当容器注册表的权限和身份验证问题阻止pod检索镜像时,也会出现ImagePullBackOff。这通常发生在秘密持有凭证(ImagePullSecret)出现问题或pod缺少所需的基于角色的访问控制(RBAC)角色时。要解决此问题,请确保pod和节点具有适当的权限和机密,然后使用docker pull命令手动尝试操作。  

4、通过为docker pull命令设置--v参数来更改日志详细程度。调高日志级别以获取有关错误发生原因的更多信息。  

5、如果不知道用于登录和拉取镜像的凭据或ImagePullSecret的内容,您可以按照以下步骤操作。 
``` 
#首先,使用kubectl get secret命令,将<SECRET_NAME>替换为您要检索的ImagePullSecret的名称。  

kubectl get secret <SECRET_NAME> -o json  #此命令将输出机密的JSON表示形式,其中包括包含base64编码凭据的数据字段
kubectl get secret <SECRET_NAME> -o json | jq -r '.data.".dockerconfigjson"' | base64 --decode  #要解码base64编码的凭据,您可以使用大多数类Unix操作系统(包括Linux和macOS)中提供的base64命令
                                                                             #此命令使用jq提取"dockerconfigjson"字段的值,其中包含base64编码的凭据,然后将输出通过管道传输到base64命令以对其进行解码。

#获得解码的凭据后,您可以将它们与docker login命令一起使用,以通过Docker注册表进行身份验证。例如：
docker login -u <USERNAME> -p <PASSWORD> <REGISTRY_URL>
#将<USERNAME>和<PASSWORD>替换为您从ImagePullSecret解码的凭据,并将<REGISTRY_URL>替换为您要用于身份验证的Docker注册表的URL。然后发出docker pull 命令来测试拉取镜像。
```

# 二、CrashLoopBackOff
1、Pod可能无法启动的另一个原因是无法在节点上调度指定的容器。当pod遇到此问题时,kubectl get pods命令会将pod的状态显示为CrashLoopBackOff。  

2、如果pod无法安装请求的卷或者节点没有运行pod所需的资源,则可能会发生此错误。要获取有关该错误的更多信息,请运行以下命令：
```
kubectl describe pod <pod name>
#输出的末尾将有助于确定根本原因。如果原因是pod无法安装请求的卷,请通过确保清单适当地指定其详细信息并确保pod可以使用这些定义访问存储卷来手动验证卷。 
或者,如果该节点没有足够的资源,则手动从该节点中删除pod,以便将pod调度到另一个节点上。否则,您可以扩展节点资源容量。
```
3、如果使用nodeSelector安排pod在Kubernetes集群中的特定节点上运行,就会发生这种情况。  

# 三、Out-of-Memory
1、当容器因OOM错误而终止时,通常会出现资源短缺或内存泄漏   
执行kubectl describe pod <pod name>命令来确定pod中的容器是否已达到资源限制。如果是这样,终止的原因将显示为OOMKilled。此错误表明Pod的容器已尝试使用超过配置限制的内存。  

要解决OOMKilled,请增加容器的内存限制作为pod规范的一部分。如果pod仍然失败,检查应用是否存在内存泄漏,并通过在应用前端修复内存泄漏问题及时解决。  

为了最大限度地减少OOM错误的可能性并优化您的Kubernetes环境,您可以在指定pod时定义容器需要多少资源,  
例如CPU和内存。kube-scheduler根据对其容器的资源请求选择哪个节点来引导pod。然后,kubelet为该容器分配该节点资源的一部分。此外,kubelet对已定义的容器实施资源限制(limits),防止正在运行的容器使用超出预期的资源。

# 四、BackOffLimitsExceeded
BackoffLimitExceeded表示Kubernetes作业在多次重启失败后已达到其重试限制。  

Kubernetes中的作业可以控制pod的运行时、监视其状态并在pod出现故障时重新启动。    
backoffLimit是一个作业配置选项,它控制在作业最终被视为失败之前pod可以失败和重试的次数(此配置默认值为6),重试六次之后重试将停止    
执行kubectl descrippod <pod name>命令来确定作业是否因BackoffLimitExceeded错误而失败。    

Kubernetes作业的成功或失败状态取决于它管理的容器的最终退出代码。因此,如果作业的退出代码不是0,则视为失败。作业可能因多种原因而失败,包括指定路径不存在或作业无法找到要处理的输入文件。    
通过对作业定义执行故障分析来克服此作业故障。执行kubectl logs <pod name>命令来检查pod的日志,这通常会发现失败的原因。  

# 五、Probe Failures
为了监控和响应Pod的状态,Kubernetes提供了探针(健康检查)以确保只有健康的Pod才能为请求提供服务。 
 
每个探针(Startup、Liveness、Readiness)都有助于Kubernetes pod在不健康时进行自我修复。当探针处于挂起状态的时间过长或者未就绪或无法安排时,它可能会失败。  

Pod有四个阶段的生命周期
- Pending、
- Running、
- Succeeded 
- Failed  
它的当前阶段取决于其主要容器的终止状态。如果pod卡在Pending中,则无法将其调度到节点上。在大多数情况下,调度会因资源不足而受阻。 

查看kubectl describe命令的输出将使您更加清楚。如果pod保持挂起状态,则可能是一个问题,根本原因可能是节点中的资源不足。或者,如果您为不可用的容器指定主机端口,或者该端口已在Kubernetes集群的所有节点中使用,则pod可能未就绪。 

不管失败的原因是什么,都可以使用kubectl describe pod命令来找出pod失败的原因。下一步将根据失败的原因而有所不同。  

eg:如果在容器中运行的应用程序响应时间比配置的探测超时时间长,则Kubernetes中可能会发生探测失败。通过增加探测超时、监视日志和手动测试探测来排除故障。确定根本原因后,优化应用程序、扩展资源或调整探针配置。 

# 结论
在Kubernetes中进行故障排除似乎是一项艰巨的任务。但是,通过正确诊断问题并了解其背后的原因,您会发现故障排除过程更易于管理,也不会那么令人沮丧。



# [Kubernetes故障排查](https://en.rattibha.com/thread/1702303087929835977)   
## 1. Pod启动失败
- 检查YAML语法、镜像设置、资源限制
- 使用kubectl describe查看详情  
  kubectl describe pod <pod-name> for details.

## 2. CPU利用率高
- 用kubectl top识别资源密集型容器
- 调整资源请求和限制

## 3. 服务不可达
- 确认服务选择器与Pod标签匹配
- 检查防火墙规则和网络策略

## 4. CrashLoopBackOff
- 用kubectl logs分析Crash原因
- 修复代码或依赖问题

## 5. 内存不足
- 增加内存限制或优化容器内存使用

## 6. 节点不可达
- 使用kubectl get nodes调查节点状态
- 修复网络或节点问题

## 7. PersistentVolumeClaim挂起
- 检查存储类和容量
- 修正PV/PVC的YAML或存储后端

## 8. DNS解析失败
- 验证Pod中的DNS配置
- 检查CoreDNS或自定义DNS

## 9. 资源配额超限
- 用kubectl describe quota审查资源使用
- 调整资源请求或申请更多配额

## 10. 未授权访问
- 确保RBAC策略正确配置
- 用kubectl auth can-i测试权限

## 11. Pod终止状态异常
- 使用kubectl edit pod手动删除finalizers强制终止

## 12. Ingress未路由流量
- 检查Ingress YAML和后端服务
- 确认Ingress controller运行正常

## 13. 集群扩容问题
- 监控节点健康,升级组件,调整自动扩缩容设置

## 14. Pod驱逐
- 排查资源压力问题,调整资源请求/限制或启用抢占

## 15. Pod之间时间偏差
- 确保跨节点时间同步

## 16. Helm chart部署失败
- 检查chart配置和依赖
- 使用helm install --dry-run做预检

## 17. ConfigMap/Secret更新不生效
- 重启使用配置的Pod或启用自动重载

## 18. 节点磁盘使用过高
- 使用kubectl du识别使用过多磁盘的Pod

## 19. ImagePullBackOff
- 验证镜像可用性、凭证和网络连接

## 20. Pod无法访问外部服务
- 检查网络策略、出站规则和防火墙设置
