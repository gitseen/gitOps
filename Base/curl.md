# [Linux 系统curl命令使用详解](https://www.toutiao.com/article/7288601999577809464/)
# [curl使用正向代理的各种用法示例](https://www.toutiao.com/w/1780817358215244/)
# [curl](https://zhuanlan.zhihu.com/p/587700262?utm_id=0&wd=&eqid=cd779533000ac93200000006645b3494)

# [help](man curl;info curl)

```bash
curl是一个非常实用的、用来与服务器之间传输数据的工具；
支持的协议包括(DICT, FILE, FTP, FTPS, GOPHER, HTTP, HTTPS, IMAP, IMAPS, LDAP, LDAPS, POP3, POP3S, RTMP, RTSP, SCP, SFTP, SMTP, SMTPS, TELNET and TFTP)，curl设计为无用户交互下完成工作；
curl提供了很多非常有用的功能，包括代理访问、用户认证、ftp上传下载、HTTP POST、SSL连接、cookie支持、断点续传...。

curl cht.sh/curl


curl "https://oapi.dingtalk.com/rohot/send?access_token=3832743fefc17693e79144aad39f3f86a01d03844abh4721d02ac5ffbbb5cc8" \
-H 'Content-Type: application/json' \
-d '{ "msgtype": "text","text": {"content": "202308102214"}}'
```

# curl常用用法示例
```bash

curl -Ss --connect-timeout 3 -m 60 http://download.bt.cn/install/yumRepo_select.sh|bash
curl -sS --connect-timeout 10 -m 60 http://www.bt.cn/api/index/get_time


curl -fsSL http://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | sudo apt-key add -curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
curl -sSL https://get.daocloud.io/daotools/set_mirror.sh | sh -s http://f1361db2.m.daocloud.io
curl -usSf  http://10.160.3.11/ntp.sh|bash
curl -fsSL https://get.k8s.io | bash
curl -fsSL --retry 5 "https://dl.k8s.io/${1}.txt"
curl -fL --retry 5 --keepalive-time 2 "${kubernetes_tar_url}" -o "${file}"
curl ip.sb
curl 127.0.0.1:22
curl https://github.com/coreos/flannel/blob/master/Documentation/kube-flannel-rbac.yml -o
curl https://github.com/coreos/flannel/blob/master/Documentation/kube-flannel-rbac.yml -O
curl -# -O http://example.com/largefile.zip  #显示进度

curl -IS www.xx.com
curl -I -m 10 -o /dev/null -s -w %{http_code} http://192.168.1.70

curl -l -H "Content-type: application/json" -X POST -d "$json" "$uploadHostDailyCheckReportApi" 2>/dev/null
curl -i -H "Content-Type:application/json" -X POST -d '{"contractRoot":{"body":{"channelOrderId":"201806281112121200","uniChannelId":"1000000005320100034"},"head":{"apiId":"200051","channelCode":"970","reqTime":"20230727153948753","sign":"88aa72196e428f0791b6b2ee58dabb21","transactionId":"201806281112121200","version":"1.0"}}}' http://221.181.129.89:20137/right_composite/open/api/order/queryOrder

curl -k -v -XGET -H "Accept: application/json, */*" -H "User-Agent: kubectl/v1.21.3 (linux/amd64) kubernetes/ca643a4" 'http://localhost:8080/api?timeout=32s'
curl -XGET http://xxxx/xx

curl -T /root/a.txt ftp:sa:sa123@ip:port/tpm/a.txt
curl -F password=@/etc/passwd www.mypasswords.com


#代理usage:
curl -x http://xx:port url  #http代理
curl -x https://xx:port url  #https代理
curl --socks5 http://xx:port url  #socks代理

#env-proxy
echo "usage-proxy"
export http_proxy=htpp://localhost:8080/
curl http://www.google.com
unset http_proxy

#############################################
if "${need_download}"; then
  if [[ $(which curl) ]]; then
    curl -fL --retry 5 --keepalive-time 2 "${kubernetes_tar_url}" -o "${file}"
  elif [[ $(which wget) ]]; then
    wget "${kubernetes_tar_url}"
  else
    echo "Couldn't find curl or wget.  Bailing out."
    exit 1
  fi
fi

##############################################

curl_check (){
  echo "Checking for curl..."
  if command -v curl > /dev/null; then
    echo "Detected curl..."
  else
    echo "Installing curl..."
    yum install -d0 -e0 -y curl
  fi
}


##############################################
SendMsgToDingding (){
                 curl $webhook -H 'Content-Type: application/json' -d "
                 {
                     'msgtype': 'text',
                     'text': {
                         'content': 'lotus: ceph_ifo in: $url '
                     },
                     'at': {
                     'isAtAll': true
                     }
             }"
}



```


---


```bash
#!/bin/bash
#启用xtrace
set -x
echo "这是一个演示脚本。"
name="Alice"
age=30
echo "你好，$name！你的年龄是 $age 岁。"

#禁用xtrace（如果需要）
set +x
echo "脚本执行完毕。"
```

