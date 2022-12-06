# 如何通过kubectl 重启Pod (六种方法)
kubectl其实没有restart pod这个命令，这个主要是由于在k8s中pod的管理属于rs等控制器，并不需要运维手动维护，但有时候，我们修改了configmap的配置文件后，希望重启pod加载配置，此时就需要重启Pod。这里说的“重启”是加了引号的，准确地来说，是重建pod，给用户的感觉是重启。   
![pod-restart](https://p3-sign.toutiaoimg.com/tos-cn-i-qvj2lq49k0/4c8302c312c0466c85ddb4b268d7fc3c~noop.image?_iz=58558&from=article.pc_detail&x-expires=1670915173&x-signature=MrWnQRtorPR6hqYjjQvSGRteIwg%3D)
下面介绍六种k8s 里面重启pod的方式  

方法一：kubectl rollout restart  
```bash
kubectl rollout restart deployment <deployment_name> -n <namespace>
```
这个命令是比较推荐的，便可以重建这个deployment下的pod，和滚动升级类似，并不会一次性杀死Pod，比较平滑。  


方法二：kubectl scale  
这种方法相对来说，比较粗放，我们可以先将副本调成 0
```bash
kubectl scale deployment <deployment name> -n <namespace> --replicas=0
然后再改回目的副本数
kubectl scale deployment <deployment name> -n <namespace> --replicas=10
但这个会中断服务。但两条命令也能解决，下面介绍的就更直接了。
```

方法三： kubectl delete pod  
```bash
kubectl delete pod <pod_name> -n <namespace>
```
还是多说一句，此时优雅删除的效果还是有的。再多说一句，直接删 rs 效果也挺好。

方法四：kubectl replace  
```bash
kubectl get pod <pod_name> -n <namespace> -o yaml | kubectl replace --force -f -
```
这种方法是通过更新Pod ，从触发k8s pod 的更新

方法五：kubectl set env  
```bash
kubectl set env deployment <deployment name> -n <namespace> DEPLOY_DATE="$(date)"
```
通过设置环境变量，其实也是更新pod spec 从而触发滚动升级。只不过这里通过kubectl 命令行，当我们通过API 更新pod spec 后一样会触发滚动升级

方法六： kill 1  
```bash
kubectl exec -it <pod_name> -c <container_name> --/bin/sh -c "kill 1"
```
这种方法就是在容器里面 kill 1 号进程。但是但是但是，重要的话说三遍，它有个局限，必须要求你的 1 号进程要 捕获 TERM 信号，否则在容器里面是杀不死自己的.

