# [Linux 系统curl命令使用详解](https://www.toutiao.com/article/7288601999577809464/)  

# [curl](https://zhuanlan.zhihu.com/p/587700262?utm_id=0&wd=&eqid=cd779533000ac93200000006645b3494)   

```bash
curl是一个非常实用的、用来与服务器之间传输数据的工具； 
支持的协议包括(DICT, FILE, FTP, FTPS, GOPHER, HTTP, HTTPS, IMAP, IMAPS, LDAP, LDAPS, POP3, POP3S, RTMP, RTSP, SCP, SFTP, SMTP, SMTPS, TELNET and TFTP)，curl设计为无用户交互下完成工作； 
curl提供了很多非常有用的功能，包括代理访问、用户认证、ftp上传下载、HTTP POST、SSL连接、cookie支持、断点续传...。  

curl cht.sh/curl


#curl "https://oapi.dingtalk.com/rohot/send?access_token=3832743fefc17693e79144aad39f3f86a01d03844abh4721d02ac5ffbbb5cc8" \
#-H 'Content-Type: application/json' \
#-d '{ "msgtype": "text","text": {"content": "202308102214"}}'
#!/bin/bash

# 启用xtrace
set -x

echo "这是一个演示脚本。"
name="Alice"
age=30
echo "你好，$name！你的年龄是 $age 岁。"

# 禁用xtrace（如果需要）
set +x

echo "脚本执行完毕。"
```

