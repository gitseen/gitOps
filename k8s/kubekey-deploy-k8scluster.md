# [kubekey官方文档](https://kubesphere.io/zh/)

# [kubekey部署k8s高可用集群和kubesphere](https://zhuanlan.zhihu.com/p/4603021955)

**kubernetes v1.15以上更新证书的方法**  
```bash
更新/etc/kubernetes/pki目录下的所有证书（不包含ca证书）
#查看现有证书到期时间
$ kubeadm alpha certs check-expiration

# 使用二进制更新证书
$ kubeadm alpha certs renew all

# 每月的最后1天
crontab  -e

* * 1  * *  /usr/bin/kubeadm alpha certs renew all
```

>注意：需要在每一个节点上都更新  


