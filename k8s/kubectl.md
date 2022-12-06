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


