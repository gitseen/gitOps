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
* 打印指定namespace里Pod包含容器的limits和requests
```bash
kubectl get pods -n x -o=custom-columns='NAME:spec.containers[*].name,MEMREQ:spec.containers[*].resources.requests.memory,MEMLIM:spec.containers[*].resources.limits.memory,CPUREQ:spec.containers[*].resources.requests.cpu,CPULIM:spec.containers[*].resources.limits.cpu'
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
# kubectl语法  
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



