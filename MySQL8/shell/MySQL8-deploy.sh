#   See https://www.toutiao.com/article/7172725103506276877/  for details.
```bash
安装依赖
sudo yum install -y ncurses-compat-libs-6.1-9.20180224.el8.x86_64  libaio-devel
## Ubuntu
sudo  apt install  libaio-dev libtinfo5

#download
cd  /usr/local
sudo curl -O https://cdn.mysql.com/Downloads/MySQL-8.0/mysql-8.0.30-linux-glibc2.12-x86_64.tar.xz

sudo tar Jxf mysql-8.0.30-linux-glibc2.12-x86_64.tar.xz
sudo ln -s mysql-8.0.30-linux-glibc2.12-x86_64 mysql

sudo useradd -s /sbin/nologin  mysql
sudo mkdir -p /data/mysql
sudo chown -R mysql:mysql /data/mysql

定义配置文件
sudo vi  /etc/my.cnf  #写入如下内容
[mysql]
port = 3306
socket = /tmp/mysql.sock
[mysqld]
user = mysql
port = 3306
basedir = /usr/local/mysql
datadir = /data/mysql
socket = /tmp/mysql.sock
pid-file = /data/mysql/mysqld.pid
log-error = /data/mysql/mysql.err

7）初始化

/usr/local/mysql/bin/mysqld --console --initialize-insecure --user=mysql   ## initialize-insecure使用空密码


8）启动

sudo vi /usr/lib/systemd/system/mysqld.service  #写如下内容
[Unit]
Description=MYSQL server
After=network.target
[Install]
WantedBy=multi-user.target
[Service]
Type=forking
TimeoutSec=0
PermissionsStartOnly=true
ExecStart=/usr/local/mysql/bin/mysqld --defaults-file=/etc/my.cnf --daemonize $OPTIONS
ExecReload=/bin/kill -HUP -$MAINPID     #这里-HUP可以是改成-s HUP，就变成强制杀进程，有需要可以改，下面也一样
ExecStop=/bin/kill -QUIT $MAINPID        #-s QUIT是强制杀进程
KillMode=process
LimitNOFILE=65535
Restart=on-failure
RestartSec=10
RestartPreventExitStatus=1
PrivateTmp=false
### end

sudo systemctl daemon-reload
sudo systemctl enable mysqld
sudo systemctl start mysqld


9）配置环境变量

sudo vi  /etc/profile  #最后面增加下面一行内容
export PATH=$PATH:/usr/local/mysql/bin
## 然后执行下面命令，使其生效
sudo source  /etc/profile
10）设置密码

mysqladmin -uroot  password  'your_new_passwd'


将上面步骤写成脚本：

#!/bin/bash

### 设置变量 ###
mysql_url="https://cdn.mysql.com//Downloads/MySQL-8.0/mysql-8.0.30-linux-glibc2.12-x86_64.tar.xz"

mysql_base_dir="/usr/local/mysql"
mysql_data_dir="/data/mysql"

mysql_root_pwd="aminglinux.Com"
mysql_rep_pwd="Aminglinux123"

##########################
ck_ok()
{
        if [ $? -ne 0 ]
        then
                echo "$1 error."
                exit 1
        fi
}
download_mysql()
{
        ##下载前，先判断当前目录下是否已经下载过
        cd /usr/local
        if [ -f mysql-8.0.30-linux-glibc2.12-x86_64.tar.xz ]
        then
                echo "当前目录已经存在mysql-8.0.30-linux-glibc2.12-x86_64.tar.xz"
                echo "检测md5"
                mysql_md5=`md5sum mysql-8.0.30-linux-glibc2.12-x86_64.tar.xz|awk '{print $1}'`
                if [ ${mysql_md5} == "2469b1ae79e98110277d9b5bee301135" ]
                then
                        return 0
                else
                        sudo /bin/mv mysql-8.0.30-linux-glibc2.12-x86_64.tar.xz mysql-8.0.30-linux-glibc2.12-x86_64.tar.xz.old
                fi
        fi
        sudo wget ${mysql_url}
        ck_ok "下载mysql"
}

install_mysql()
{
        cd /usr/local
        echo "解压mysql"
        sudo tar Jxf mysql-8.0.30-linux-glibc2.12-x86_64.tar.xz
        ck_ok "解压mysql"
        if [ -d ${mysql_base_dir} ]
        then
                echo "${mysql_base_dir}已经存在，挪走"
                sudo /bin/mv ${mysql_base_dir} ${mysql_master_base_dir}-`date +%s`
        fi
        sudo mv mysql-8.0.30-linux-glibc2.12-x86_64 mysql
        if id mysql &>/dev/null
        then
                echo "系统已经存在mysql用户，跳过创建"
        else
                echo "创建mysql用户"
                sudo useradd -s /sbin/nologin  mysql
        fi

        if [ -d ${mysql_data_dir} ]
        then
                echo "${mysql_data_dir}已经存在，挪走"
                sudo /bin/mv ${mysql_data_dir} ${mysql_data_dir}-`date +%s`
        fi
        echo "创建mysql datadir"
        sudo mkdir -p ${mysql_data_dir}
        sudo chown -R mysql ${mysql_data_dir}


        if [ -f ${mysql_base_dir}/my.cnf ]
        then
                echo "master配置文件已经存在,删除"
                sudo rm -f ${mysql_base_dir}/my.cnf
        fi
        echo "创建master配置文件my.cnf"
        cat > /tmp/my.cnf <<EOF
[mysqld]
user = mysql
port = 3306
server_id = 1
basedir = ${mysql_base_dir}
datadir = ${mysql_data_dir}
socket = /tmp/mysql.sock
pid-file = ${mysql_data_dir}/mysqld.pid
log-error = ${mysql_data_dir}/mysql.err
EOF
        sudo /bin/mv /tmp/my.cnf  ${mysql_base_dir}/my.cnf

        echo "安装依赖"
        sudo  yum install -y  ncurses-compat-libs-6.1-9.20180224.el8.x86_64  libaio-devel

        echo "初始化"
        sudo ${mysql_base_dir}/bin/mysqld --console  --datadir=${mysql_data_dir} --initialize-insecure --user=mysql
        ck_ok "初始化"

        if [ -f /usr/lib/systemd/system/mysqld.service ]
        then
                echo "mysql服务管理脚本已经存在，挪走"
                sudo /bin/mv  /usr/lib/systemd/system/mysqld.service /usr/lib/systemd/system/mysqld.service-`date +%s`
        fi
        echo "创建服务启动脚本"
        cat > /tmp/mysqld.service <<EOF
[Unit]
Description=MYSQL server
After=network.target
[Install]
WantedBy=multi-user.target
[Service]
Type=forking
TimeoutSec=0
PermissionsStartOnly=true
ExecStart=${mysql_base_dir}/bin/mysqld --defaults-file=${mysql_base_dir}/my.cnf --daemonize $OPTIONS
ExecReload=/bin/kill -HUP -$MAINPID
ExecStop=/bin/kill -QUIT $MAINPID
KillMode=process
LimitNOFILE=65535
Restart=on-failure
RestartSec=10
RestartPreventExitStatus=1
PrivateTmp=false
EOF

        sudo /bin/mv /tmp/mysqld.service /usr/lib/systemd/system/mysqld.service
        sudo systemctl unmask mysqld
        sudo systemctl daemon-reload
        sudo systemctl enable mysqld
        echo "启动mysql"
        sudo systemctl start mysqld
        ck_ok "启动mysql"


        echo "设置mysql密码"
        ${mysql_base_dir}/bin/mysqladmin -S/tmp/mysql.sock -uroot  password "${mysql_root_pwd}"
        ck_ok "设置mysql密码"
}

main()
{
        download_mysql
        install_mysql
}

main


```

