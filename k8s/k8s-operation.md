# k8s-commands CLI
![cli1](pic/cli1.png) 
 
# k8s-commands
![cli2](pic/cli2.png)  
K8S所有的命令行操作本质是对资源的CRUD有一个对应关系,用YAML描述资源的关系,用cli对资源进行各种操作,因为K8S命令实在太多,很多各种各样的操作参数非常难以记忆   

# 基础操作
<details>
  <summary>基础操作举例</summary>
  <pre><code>
alias k=kubectl echo ‘alias k=kubectl’ >>~/.bashrc
kubectl get pods -o=json
kubectl get pods -o=yaml
kubectl get pods -o=wide
kubectl get pods -n=<namespace_name>
kubectl create -f ./
kubectl logs -l name=
  </code></pre>
</details>

# 资源相关
<details>
  <summary>resources</summary>
  <pre><code>
kubectl create -f        #– Create objects.
kubectl create -f        #– Create objects in all manifest files in a directory.
kubectl create -f <url>  #– Create objects from a URL.
kubectl delete -f        #– Delete an object.
  </code></pre>
</details>



# Kubernetes日常运维工作中常用的命令
```
#获取前一个容器的日志
kubectl -n my-namespace logs  xx OR kubectl logs xx -n my-namespace

#获取每个节点的Pod数量 
kubectl get po -o json --all-namespaces | jq '.items | group_by(.spec.nodeName) | map({"nodeName": .[0].spec.nodeName, "count": length}) | sort_by(.count)'

#根据pods的重启次数进行排序
kubectl get pods -A --sort-by='.status.containerStatuses[0].restartCount'

#根据启动时间降序（descending order）
kubectl get pods --sort-by=.metadata.creationTimestamp

#根据启动时间升序（ascending order）
kubectl get pods --sort-by=.metadata.creationTimestamp | awk 'NR == 1; NR > 1 {print $0 | "tac"}'
kubectl get pods --sort-by=.metadata.creationTimestamp | tail -n +2 | tac
kubectl get pods --sort-by={metadata.creationTimestamp} --no-headers | tac
kubectl get pods --sort-by=.metadata.creationTimestamp | tail -n +2 | tail -r

#查看集群內Pod的服务质量等级（QoS）
kubectl get pods --all-namespaces -o custom-columns=NAME:.metadata.name,NAMESPACE:.metadata.namespace,QOS-CLASS:.status.qosClass

#无缝重启deploy,daemonset,statfulset(zero downtime)
kubectl -n <namespace> rollout restart deployment <deployment-name>

#把Secret复制到其他namespace
kubectl get secrets -o json --namespace namespace-old | jq '.items[].metadata.namespace = "namespace-new"' |   kubectl create -f  -
kubectl get secret <SECRET-NAME> -n <SOURCE-NAMESPACE> -o yaml | sed "/namespace:/d" | kubectl apply --namespace=<TARGET-NAMESPACE> -f - #比如使用证书镜像凭证等

#获取K8s的token
kubectl -n kube-system describe $(kubectl -n kube-system get secret -n kube-system -o name | grep namespace) | grep token

#查找非running状态的Pod
kubectl get pods -A --field-selector=status.phase!=Running | grep -v Complete

#清理K8s异常pod
kubectl get pods --all-namespaces -o wide | grep Evicted   | awk '{print $1,$2}' | xargs -L1 kubectl delete pod -n  #clean Evicted
kubectl get pods --all-namespaces -o wide | grep Error     | awk '{print $1,$2}' | xargs -L1 kubectl delete pod -n  #clean error 
kubectl get pods --all-namespaces -o wide | grep Completed | awk '{print $1,$2}' | xargs -L1 kubectl delete pod -n  #clean compete
kubectl get pods --all-namespaces -o wide | grep -E "Evicted|Error|Completed" | awk '{print $1,$2}' | xargs -L1 kubectl delete pod -n

#强制删除指定namespace下Terminating状态的pod
kubectl get pod -n $namespace |grep Terminating|awk '{print $1}'|xargs kubectl delete pod --grace-period=0 --force

#批量强制删除集群内Terminating状态的pod
for ns in $(kubectl get ns --no-headers | cut -d ' ' -f1); do \
  for po in $(kubectl -n $ns get po --no-headers --ignore-not-found | grep Terminating | cut -d ' ' -f1); do \
    kubectl -n $ns delete po $po --force --grace-period 0; \
  done; \
done;

#导出干净的YAML(需要插件kubectl-neat支持https://github.com/itaysk/kubectl-neat)
kubectl get cm nginx-config -o yaml | kubectl neat -o yaml

#clean unused pv
kubectl describe -A pvc | grep -E "^Name:.*$|^Namespace:.*$|^Used By:.*$" | grep -B 2 "<none>" | grep -E "^Name:.*$|^Namespace:.*$" | cut -f2 -d: | paste -d " " - - | xargs -n2 bash -c 'kubectl -n ${1} delete pvc ${0}'

#清理没有被绑定的PVC
kubectl get pvc --all-namespaces | tail -n +2 | grep -v Bound | awk '{print $1,$2}' | xargs -L1 kubectl delete pvc -n

#清理没有被绑定的PV
kubectl get pv | tail -n +2 | grep -v Bound | awk '{print $1}' | xargs -L1 kubectl delete pv

#临时释放的指定namespace下的pod
方法一：通过patch模式      kubectl get deploy -o name -n <NAMESPACE>|xargs -I{} kubectl patch {} -p '{"spec":{"replicas":0}}'
方法二：通过资源伸缩副本数 kubectl get deploy -o name |xargs -I{} kubectl scale --replicas=0 {}

#临时关闭Daemonsets(如果需要临时将Daemonsets关闭，只需要将其调度到一个不存在的node上即可，调整下nodeSelector)
kubectl patch daemonsets nginx-ingress-controller -p '{"spec":{"template":{"spec":{"nodeSelector":{"project/xdp":"none"}}}}}'

#根据overlay2目录名找容器
docker ps -q | xargs docker inspect --format '{{.Name}}, {{.State.Pid}}, {{.Id}}, {{.GraphDriver.Data.WorkDir}}'

#通过变量组合展示容器绑定端口列表
docker inspect --format '{{/*通过变量组合展示容器绑定端口列表*/}}已绑定端口列表：{{println}}{{range $p,$conf := .NetworkSettings.Ports}}{{$p}} -> {{(index $conf 0).HostPort}}{{println}}{{end}}' Web_web_1

#查询指定网络下的容器名称，如果存在输出容器名称，如果没有，输出With No Containers
docker inspect --format '{{range .Containers}}{{.Name}}{{println}}{{else}}With No Containers{{end}}' bridge

#通过索引序号读取默认网关
docker inspect bridge --format '{{/*查看网络的默认网关*/}}{{(index .IPAM.Config 0).Gateway}}'

#查看容器是否配置了容器策略
docker ps -q | xargs docker inspect --format '{{if not .State.Restarting}}{{.Name}}容器没有配置重启策略{{end}}'

#查看容器当前的运行状态
docker inspect --format '{{or .State.Status .State.Restarting}}' configuration-center

#显示所有容器的IP
docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $(docker ps -q)

#显示所有容器的mac地址
docker inspect --format='{{range .NetworkSettings.Networks}}{{.MacAddress}}{{end}}' $(docker ps -a -q)

#显示所有容器的名称，并分离出反斜杠
docker inspect --format='{{.Name}}' $(docker ps -aq)|cut -d"/" -f2

#创建临时可调式POD
kubectl run ephemeral-busybox \
  --rm \
  --stdin \
  --tty \
  --restart=Never \
  --image=lqshow/busybox-curl:1.28 \
  -- sh
 
#获取容器的日志路径
docker inspect --format='{{.LogPath}}' docker-test1

#调试coredns
kubectl run -it --rm --restart=Never --image=infoblox/dnstools:latest dnstools

#查看资源使用情况
kubectl get nodes --no-headers | awk '{print $1}' | xargs -I {} sh -c "echo {} ; kubectl describe node {} | grep Allocated -A 5 | grep -ve Event -ve Allocated -ve percent -ve --;"

#查看资源总情况
kubectl get no -o=custom-columns="NODE:.metadata.name,ALLOCATABLE CPU:.status.allocatable.cpu,ALLOCATABLE MEMORY:.status.allocatable.memory"

#查看CPU分配情况
kubectl get nodes --no-headers | awk '{print $1}' | xargs -I {} sh -c 'echo -n "{}\t"|tr "\n" " " ; kubectl describe node {} | grep Allocated -A 5 | grep -ve Event -ve Allocated -ve percent -ve -- | grep cpu | awk '\''{print $2$3}'\'';'

#查看内存分配
kubectl get nodes --no-headers | awk '{print $1}' | xargs -I {} sh -c 'echo "{}\t"|tr "\n" " " ; kubectl describe node {} | grep Allocated -A 5 | grep -ve Event -ve Allocated -ve percent -ve -- | grep memory | awk '\''{print $2$3}'\'';'

#获取节点列表及其内存容量
kubectl get no -o json | jq -r '.items | sort_by(.status.capacity.memory)[]|[.metadata.name,.status.capacity.memory]| @tsv'


#查看所有镜像
kubectl get pods -o custom-columns='NAME:metadata.name,IMAGES:spec.containers[*].image'

#线程数统计
printf "    ThreadNUM  PID\t\tCOMMAND\n" && ps -eLf | awk '{$1=null;$3=null;$4=null;$5=null;$6=null;$7=null;$8=null;$9=null;print}' | sort |uniq -c |sort -rn | head -10

#设置环境变量
kubectl set env deploy <DEPLOYMENT_NAME> OC_XXX_HOST=bbb

#端口映射pod(将localhost:3000的请求转发到nginx-pod Pod的80端口)
kubectl port-forward nginx-po 3000:80
#端口映射svc将localhost:3201的请求转发到nginx-web service的3201端口
kubectl port-forward svc/nginx-web 3201

#配置默认storageclass
kubectl patch storageclass <your-class-name> -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

#在多个pod中运行命令
kubectl get pods -o name | xargs -I{} kubectl exec {} -- <command goes here>

#查看容器名
kubectl get po calibre-web-76b9bf4d8b-2kc5j -o json | jq -j ".spec.containers[].name"

#进入容器namespace
docker ps | grep APP_NAME
docker inspect CONTAINER_ID | grep Pid
nsenter -t PID -n

#使用交互shell访问匹配到标签的Pod
  案例1 kubectl exec -i -t $(kubectl get pod -l <KEY>=<VALUE> -o name |sed 's/pods\///') -- bash
  案例2 kubectl exec -i -t $(kubectl get pod -l <KEY>=<VALUE> -o jsonpath='{.items[0].metadata.name}') -- bash

#重置集群节点
kubectl describe node k8s-master |grep Taints  #Taints: node-role.kubernetes.io/master:NoSchedule   #k8s集群master的hostname
kubectl taint nodes k8s-master node-role.kubernetes.io/master-                                      #修改参数可以参与pod调度
kubectl taint nodes k8s-master node-role.kubernetes.io/master=:NoSchedule                           #让master不参与pod调度
1、将节点标记为不可调度，确保新的容器不会调度到该节点
kubectl cordon <NODE-NAME>
2、Master节点上将需要重置的节点驱逐, 除了deamonset
kubectl drain <NODE-NAME> --delete-local-data --force --ignore-daemonsets
3、删除节点
kubectl delete node <NODE-NAME>
4、在需要重置节点上执⾏重置脚本，注意，如果在Master主节点执⾏kubeadm reset，则需要重新初始化集群
kubeadm reset

```
[from](https://mp.weixin.qq.com/s/rXSoUwcyVRIDtvYf_69jyA) 
