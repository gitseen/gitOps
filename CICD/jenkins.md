# Jenkins部署
**部署包：JDK11、Jenkins、Maven、Node等**  

https://www.oracle.com/java/technologies/downloads/archive/  
https://www.oracle.com/java/technologies/javase/jdk11-archive-downloads.html   

http://www.jenkins.io/download/ #war包  
https://mirrors.tuna.tsinghua.edu.cn/jenkins/war-stable/2.387.3/jenkins.war

https://maven.apache.org/download.cgi  

https://nodejs.org/download/release/  
https://nodejs.org/download/release/v14.17.5/  

# 一 部署包安装
将所有安装包上传到/data目录下  
```
tar zxf jdk-11.0.18_linux-x64_bin.tar.gz
tar zxf jdk-8u361-linux-x64.tar.gz
tar zxf node-v14.17.5-linux-x64.tar.gz
tar zxf apache-maven-3.8.8-bin.tar.gz
```
## 1.1 环境系统配置
```
#1、yumconfig
cat <<EOF > /etc/yum.repos.d/docker-ce.repo
[docker-ce-stable]
name=Docker CE Stable - \$basearch
baseurl=https://mirrors.aliyun.com/docker-ce/linux/centos/\$releasever/\$basearch/stable
enabled=1
gpgcheck=1
gpgkey=https://mirrors.aliyun.com/docker-ce/linux/centos/gpg
EOF


#2、优化内核参数
cat >> /etc/sysctl.conf <<EOF
vm.swappiness = 0
net.ipv4.ip_forward = 1
EOF

sysctl --system

#3、安装必要的软件包
yum install fontconfig git docker-ce gcc gcc-c++ python3 -y

#4、配置docker加速器
mkdir -p /etc/docker
tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": [
    "https://8e3pea7v.mirror.aliyuncs.com"
  ]
}
EOF

```

## 1.2 部署Jenkins
```
mkdir /data/jenkins
创建启动脚本 vi /usr/lib/systemd/system/jenkins.service
[Unit]
Description=Jenkins
After=network-online.target
[Service]
Environment="JAVA_HOME=/data/jdk1.8.0_361"
Environment="JENKINS_HOME=/data/jenkins"
Environment="PATH=$PATH:/bin:/usr/bin:$JAVA_HOME/bin:/data/apache-maven-3.8.8/bin:/data/node-v16.14.2-linux-x64/bin"
WorkingDirectory=/data/jenkins
User=root
Group=root
LimitMEMLOCK=infinity
LimitNOFILE=65536
LimitNPROC=65536
LimitAS=infinity
LimitFSIZE=infinity
TimeoutSec=0
RestartSec=2
Restart=always
ExecStart=/data/jdk-11.0.19/bin/java -jar /data/jenkins.war --logfile=/data/jenkins/jenkins.log --httpPort=8080 --httpListenAddress=0.0.0.0
ExecReload=/usr/bin/kill -HUP $MAINPID
ExecStop=/usr/bin/kill -SIGTERM $MAINPID
[Install]
WantedBy=multi-user.target

systemctl enable jenkins.service && systemctl start jenkins.service

```

## 1.3 Jenkins页面配置
浏览器访问打开Jenkins部署页面 http://x.x.x.x:8080  
```
cat /data/jenkins/secrets/initialAdminPassword
```
![入门](pic/jenkins-unlock.png)   
如果没有特殊要求，安装推荐的插件即可  

创建管理员用户  
![admin](pic/jenkins-admin.png)   

配置Jenkins访问地址  
![url](pic/jenkins-url.png)  

# 二 Jenkins管理
## 2.1 管理插件
![Manage](pic/manage.png)  
![Plugins](pic/plugins.png)   

安装以下插件  
```
Git Parameter
Build With Parameters
Config File Provider
```

## 2.2 管理Jenkins-Managed files
![file](pic/file.png)  
添加一个新的Config - Maven settings.xml  
![maveflie](pic/mave-xml.png)  
指定配置文件id  
![nexus](pic/nexus.png)  
配置Maven settings.xml的内容，需要指定nexus私有仓库地址的同时，配置公共仓库地址，以便maven为java项目打包时能够拉取到对应的依赖包。  
```
    <mirror>
      <id>nexus</id>
      <mirrorOf>*</mirrorOf>
      <name>私服内部Nexus</name>
      <url>http://172.16.0.217/repository/maven-public</url>
    </mirror>
    <mirror>
      <id>public</id>
      <mirrorOf>*</mirrorOf>
      <name>公共仓库</name>
      <url>http://maven.aliyun.com/nexus/content/groups/public/</url>
    </mirror>

```
![S-credentials](pic/nexus-credentials.png)  
还需要注意nexus默认情况下是需要认证的，配置认证信息。  
![Content](pic/content.png)  

########
