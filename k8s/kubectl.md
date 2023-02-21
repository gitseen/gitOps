# kubectl命令的使用技巧 
  https://www.toutiao.com/article/7172014453595210252/  
  #kubectl命令的使用技巧  
  kubectl是管理kubernetes的命令行工具，平时工作中使用很多，依赖kubectl可以做很多事情，比如下面：  
* 列出集群中运行异常的Pod
```bash
   kubectl get pods -A --field-selector=status.phase!=Running | grep -v Complete
```
* 打印出各个节点上运行的Pod数目
```bash
   kubectl get pod -o json -A |jq '.items | group_by(.spec.nodeName) | map({"nodeName": .[0].spec.nodeName, "count": length}) | sort_by(.count)'
```
* 打印节点IP和对应的内存大小（单位：KiB）
```bash
kubectl get no -o json | jq -r '.items | sort_by(.status.capacity.memory)[]|[.metadata.name,.status.capacity.memory]| @tsv'
```
* 各种排序Pod   
   1  按内存使用排序   
```bash
   kubectl top pods -A | sort --reverse --key 4 --numeric
```
   2 按CPU使用排序  
```bash
   kubectl top pods -A | sort --reverse --key 3 --numeric
```
   3 按重启次数排序（需选定命名空间）  
```bash
   kubectl get pods --sort-by=.status.containerStatuses[0].restartCount
```
* 自定义输出列(-o custom-columns=<header>:<jsonpath>...)  
```
kubectl get pods -o custom-columns='NAME:metadata.name' -n xx OR -A
kubectl get pods -o custom-columns='NAME:metadata.name,NODE:spec.nodeName' -n xx

#JSONPath表达式
1、选择一个列表中有所有元素
kubectl get pods -o custom-columns='DATA:spec.containers[*].image'
2、选择一个列表中一个指定元素
kubectl get pods -o custom-columns='DATA:spec.containers[0].image'
3、选择特定位置下的所有字段
kubectl get pods -o custom-columns='DATA:metadata.*'
4、选择所有具有特定名称的字段
kubectl get pods -o custom-columns='DATA:..image'
5、查询Pod中所有image
kubectl get pods -o custom-columns='NAME:metadata.name,IMAGES:spec.containers[*].image'
```
  
* 打印指定namespace里Pod包含容器的limits和requests
```bash
kubectl get pods -A -o=custom-columns='NAME:spec.containers[*].name,MEMREQ:spec.containers[*].resources.requests.memory,MEMLIM:spec.containers[*].resources.limits.memory,CPUREQ:spec.containers[*].resources.requests.cpu,CPULIM:spec.containers[*].resources.limits.cpu'
```
* 打印集群的节点IP
```bash
kubectl get nodes -o json | jq -r '.items[].status.addresses[]? | select (.type == "InternalIP") | .address' | paste -sd "\n" -
```
* 列出集群中所有service和对应的nodePort（如果有）
```bash
kubectl get --all-namespaces svc -o json |jq -r '.items[] | [.metadata.name,([.spec.ports[].nodePort | tostring ] | join("|"))]| @tsv'
```
* 打印每个节点Pod分配的IP地址段，这个命令在排查路由问题时可能会用到
```bash
kubectl get nodes -o jsonpath='{.items[*].spec.podCIDR}' | tr " " "\n"
```
* 快速生成自签名证书，用于测试
```bash
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout tls.key -out tls.crt -subj "/CN=grafana.mysite.ru/O=MyOrganization" 
kubectl -n myapp create secret tls selfsecret --key tls.key --cert tls.crt
```
# 5个冷门Kubectl使用技巧
## 1、打印当前使用的API
```
# kubectl的主要作用就是与ApiServer进行交互, 而交互的过程, 我们可以通过下面的方式来打印, 
# 这个命令尤其适合调试自己的api接口时使用.
$ kubectl get ns -v=9
```
## 2、按状态筛选容器以及删除
这是我在这里学到的命令：Force Delete Evicted / Terminated Pods in Kubernetes  
```
kubectl get pods --all-namespaces --field-selector status.phase=Pending -o json | \
 jq '.items[] | "kubectl delete pods \(.metadata.name) -n \(.metadata.namespace)"' | \
 xargs -n 1 bash -c

# 这个命令要拆开来看
# 首先, 获取所有ns中状态为Pending的pods, 并以json形式输出
# 这个语句其实由很多变体, 比如,我想查找Failed的状态, 或是某个deployment
kubectl get pods --all-namespaces --field-selector status.phase=Pending -o json 

# 针对json变量进行处理, 生成可用的脚本
# 这里是我想介绍的重点, 利用jq以及kubectl的输出, 构建出可用的命令
jq '.items[] | "kubectl delete pods \(.metadata.name) -n \(.metadata.namespace)"'

# 执行每一条命令
# 注意, 这种命令一定要好好调试, 删掉预期之外的pod就不好了.
xargs -n 1 bash -c

# 例如, 下面的语句可以找到所有的Pods并打印可以执行的语句
kubectl get pods --all-namespaces --field-selector status.phase=Running -o json | \
 jq '.items[] | "kubectl get pods \(.metadata.name) -o wide -n \(.metadata.namespace)"'

"kubectl get pods metrics-server-6d684c7b5-gtd6q -o wide -n kube-system"
"kubectl get pods local-path-provisioner-58fb86bdfd-98frc -o wide -n kube-system"
"kubectl get pods nginx-deployment-574b87c764-xppmx -o wide -n default"

# 当然, 如果只是删除单个NS下面的一些pods, 我会选择下面的方法, 但是它操作多个NS就很不方便了.
kubectl -n default get pods | grep Completed | awk '{print $1}' | xargs kubectl -n default delete pods
```
## 3、统计具体某台机器上运行的所有pod
kubectl可以使用两种选择器, 一种是label, 一种是field, 可以看官网的介绍:  
Labels and Selectors  
Field Selectors  
```
# 它是一种选择器, 可以与上面的awk或者xargs配合使用.
# 我个人平时都不喜欢用这个, 直接get全部pods, 然后grep查找感觉更快
kubectl get pods --all-namespaces -o wide --field-selector spec.nodeName=pve-node1
```
## 4、统计 Pod 在不同机器的具体数量分布
[基于kubernetes的PaaS平台中细力度控制pods方案的实现](https://corvo.myseu.cn/2021/04/30/2021-04-30-%E5%9F%BA%E4%BA%8Ekubernetes%E7%9A%84PaaS%E5%B9%B3%E5%8F%B0%E4%B8%AD%E7%BB%86%E5%8A%9B%E5%BA%A6%E6%8E%A7%E5%88%B6pod/)  
均衡分布的工作前提是得知pod在各个机器的分布情况。最好的办法就是我们得到pod信息之后进行简单的统计，这个工作可以使用awk实现。  
```
kubectl -n default get pods -o wide -l app="nginx" | awk '{print $7}'|\
 awk '{ count[$0]++ } 
 END { 
 printf("%-35s: %s\n","Word","Count");
 for(ind in count){
 printf("%-35s: %d\n",ind,count[ind]);
 }
 }'

# 执行结果如下
Word : Count
NODE : 1
pve-node1 : 1
pve-node2 : 1
# awk的语法我没深入了解, 有兴趣的读者可以研究看看, 这里我就不求甚解了.
```
## 5、kubectl proxy的使用
你可以理解为这个命令为K8s的ApiServer做了一层代理，使用该代理，你可以直接调用API而不需要经过鉴权。启动之后，甚至可以实现kubectl套娃，下面是一个例子：  
```
# 当你没有设置kubeconfig而直接调用kubectl时
kubectl get ns -v=9
# 可以打印出下面类似的错误
curl -k -v -XGET -H "Accept: application/json, */*" -H "User-Agent: kubectl/v1.21.3 (linux/amd64) kubernetes/ca643a4" 'http://localhost:8080/api?timeout=32s'
skipped caching discovery info due to Get "http://localhost:8080/api?timeout=32s": dial tcp 127.0.0.1:8080: connect: connection refused 
# 也就是说当你不指定kubeconfig文件时, kubectl会默认访问本机的8080端口
# 那么我们先启动一个kubectl proxy, 然后指定监听8080, 再使用kubectl直接访问, 是不是就可行了呢, 
# 事实证明, 安全与预想一致.
KUBECONFIG=~/.kube/config-symv3 kubectl proxy -p 8080
kubectl get ns
NAME STATUS AGE
default Active 127d
```
默认启动的proxy是屏蔽了某些api的，并且有一些限制，例如无法使用exec进入pod之中可以使用kubectl proxy —help 来看，例如  
```
# 仅允许本机访问
--accept-hosts='^localhost$,^127\.0\.0\.1$,^\[::1\]$': Regular expression for hosts that the proxy should accept.
# 不允许访问下面的api, 也就是说默认没法exec进入容器
--reject-paths='^/api/.*/pods/.*/exec,^/api/.*/pods/.*/attach': Regular expression for paths that the proxy should reject. Paths specified here will be rejected even accepted by --accept-paths.

# 想跳过exec的限制也很简单, 把reject-paths去掉就可以了
kubectl proxy -p 8080 --keepalive 3600s --reject-paths='' -v=9
```
有人说kubectl proxy可能没什么作用，那可能仅仅是你还没有实际的应用场景。例如当我想要调试K8s dashboard代码的时候。  
如果直接使用kubeconfig文件，我没法看到具体的请求过程，如果你加上一层proxy转发，并且设置-v=9的时候，你就自动获得了一个日志记录工具，在调试时相当有用。


# kubectl语法  
from [原文](https://www.toutiao.com/article/7190147160682267140/)  
```bash
kubectl [command] [Type] [NAME] [flags]
command: 子命令，用于操作kubernetes集群资源对象的命令，例如：create, delete, describe, get, apply等等
TYPE: 资源对象的类型，区分大小写，能以单数，复数或者简写形式表示。例如以下3中TYPE是等价的。
kubectl get pod pod1
kubectl get pods pod1
kubectl get po pod1
NAME：资源对象的名称，区分大小写。如果不指定名称，系统则将返回属于TYPE的全部对象的列表，例如：kubectl get pods 将返回所有pod的列表
flags: kubectl 子命令的可选参数，例如使用 -s 指定api server的url地址而不用默认值。
```
[kubectl可操作的资源对象类型以及缩写](https://p3-sign.toutiaoimg.com/tos-cn-i-tjoges91tu/TTL6hPnIEzvwbh~noop.image?_iz=58558&from=article.pc_detail&x-expires=1676272227&x-signature=I33bvWr4TzjAy%2BJ%2F%2BbWMErYFmfc%3D)  

## kubectl 子命令详解
kebectl的子命令非常丰富，涵盖了对kubernetes集群的主要操作，包括资源对象的创建、删除、查看、修改、配置、运行等  
[详细的子命令](https://p3-sign.toutiaoimg.com/tos-cn-i-tjoges91tu/TTL6hQKQcQmvz~noop.image?_iz=58558&from=article.pc_detail&x-expires=1676272227&x-signature=AUfWesyvDdOLDlbmN8da%2BWAokpw%3D)  

## kubectl参数列表
[Kubectl命令行的公共启动参数](https://p3-sign.toutiaoimg.com/tos-cn-i-tjoges91tu/TTL6hQzFlp05vm~noop.image?_iz=58558&from=article.pc_detail&x-expires=1676272227&x-signature=NqtsHt6snI9UZoX3IUp5ljxySP4%3D)   

## Kubectl输出格式
kubectl命令可以用多种格式对结果进行显示，[输出的格式通过-o参数指定](https://p3-sign.toutiaoimg.com/tos-cn-i-tjoges91tu/TTL6iHFF62qpk4~noop.image?_iz=58558&from=article.pc_detail&x-expires=1676272227&x-signature=Ri4mzFxIMaPuuByZ1GJurPFgjvI%3D) 

## kubectl操作示例
```
1、根据yaml配置文件一次性创建service和rc
kubectl create -f my-service.yaml -f my-rc.yaml

2、根据目录下所有.yaml、.yml、.json文件的定义进行创建操作
kubectl create -f <directory>

3、查看所有Pod列表
kubectl get pods

4、查看rc和service列表
kubectl get rc,service

5、显示Node的详细信息
kubectl describe nodes <node-name>

6、显示Pod的详细信息
kubectl describe pods/<pod-name>

7、显示由RC管理的Pod信息
kubectl describe pods <rc-name>

8、删除基于pod.yaml文件定义的Pod
kubectl delete -f pod.yaml

9、删除所有包含某个label的Pod和Service
kubectl delete pods,services -l name=<label-name>

10、删除所有Pod
kubectl delete pods --all

11、在Pod的容器里执行date命令，默认使用Pod中的第1个容器执行
kubectl exec <pod-name> date

12、指定Pod中某个容器执行date命令
kubectl exec <pod-name> -c <container-name> date

13、以bash方式登陆到Pod中的某个容器里
kubectl exec -it <pod-name> -c <container-name> /bin/bash

14、查看容器输出到stdout的日志
kubectl logs <pod-name>

15、跟踪查看容器的日志，相当于tail -f命令的结果
kubectl logs -f <pod-name> -c <container-name>
```
