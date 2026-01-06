```bash
cat > install_rsyslog.sh <<'EOF'
#!/bin/bash
#rpm -qa|grep rsyslog
rpm -qa rsyslog

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
#export PROMPT_COMMAND='{ msg=$(history 1 | { read x y; echo $y; });logger "[euid=$(whoami)]":$(who am i):[`pwd`]"$msg"; }'

or

#!/bin/bash
#rpm -qa|grep rsyslog

if [[ $EUID -ne 0 ]]; then
   echo "please use root "
   exit 1
fi

#cp /root/calico.yaml{,.bak-$time}
cp /etc/bashrc /etc/bashrc.bak 2>/dev/null || true
cat >> /etc/bashrc << 'EOF'
export PROMPT_COMMAND='{ msg=$(history 1 | { read x y; echo $y; }); logger "[euid=$(whoami)]":$(who am i):[`pwd`] "$msg"; }'
EOF

source /etc/bashrc

rpm -qa rsyslog

if [[ $? -eq 0 ]];then
        echo "Rsyslog was installed"
else
        yum -y install rsyslog && systemctl start rsyslog
fi
sed -i '/cron.*/ s/^/# /' /etc/rsyslog.conf

if ! grep "172.16.219.237" /etc/rsyslog.conf  &>/dev/null; then
        sed -i '$i\cron.* stop' /etc/rsyslog.conf
        sed -i '$i\daemon.=info stop' /etc/rsyslog.conf
        sed -i '$i\syslog.* stop' /etc/rsyslog.conf
        sed -i '$i\security.* stop' /etc/rsyslog.conf
                sed -i '$i\*.=info stop' /etc/rsyslog.conf
        sed -i '$i\*.=err;*.=crit;*.=alert;*.=emerg;*.=warning;*.=notice @@172.16.219.237:514' /etc/rsyslog.conf
        grep "172.16.219.237" /etc/rsyslog.conf

        systemctl restart rsyslog && systemctl status rsyslog

        if ! rpm -q nc &>/dev/null; then
        echo " Installing nc..."
        yum -y install netcat nc
        fi
        nc -vnz 172.16.219.237 514
```
