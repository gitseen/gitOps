```bash
cat > install_rsyslog.sh <<'EOF'
#!/bin/bash
rpm -qa|grep rsyslog

if [[ $? -eq 0 ]];then
        echo "Rsyslog was installed"
else
        yum -y install rsyslog && systemctl start rsyslog
fi

if ! grep "172.16.219.235" /etc/rsyslog.conf  &>/dev/null; then
        sed -i '$i\*.* @@172.16.219.235:514' /etc/rsyslog.conf
        grep "172.16.219.235" /etc/rsyslog.conf
        systemctl restart rsyslog && systemctl status rsyslog
        
        if ! rpm -q nc &>/dev/null; then
        echo " Installing nc..."
        yum -y install netcat 
        fi
        nc -vnz 172.16.219.235 514
fi
EOF


sh   install_rsyslog.sh  #执行即可
#https://www.cnblogs.com/littlecc/p/17690890.html
#https://www.srebro.cn/archives/1735894737958   #记录系统操作命令变量
```
