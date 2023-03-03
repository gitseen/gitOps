# ansible学习笔记-playbook快速入门
# playbook
ansible命令适合执行简单的操作。如果要完成一个复杂的部署,需要很多ansible操作,写起来会很乱。

所以有了ansible-playbook

把一件事切分成很多任务,有序的组织起来
## 目录结构解读
**官方给的playbook工程的最佳实践**  
```
production                # 生产环境的服务器清单
stage                     # stage环境的服务器清单

group_vars/
   group1                 # 这里我们给特定的组赋值
   group2                 # ""
host_vars/
   hostname1              # 主机变量
   hostname2              # ""

library/                  # 如果有自定义的模块,放在这里(可选)
filter_plugins/           # 如果有自定义的过滤插件,放在这里(可选)

site.yml                  # 主 playbook文件
webservers.yml            # Web 服务器的 playbook
dbservers.yml             # 数据库服务器的 playbook

roles/
    common/               # 这个目录代表了一个名为common的 "role"
        tasks/            #
            main.yml      #  <-- tasks file can include smaller files if wanted
        handlers/         #
            main.yml      #  <-- handlers file
        templates/        #  <-- files for use with the template resource
            ntp.conf.j2   #  <------- templates end in .j2
        files/            #
            bar.txt       #  <-- files for use with the copy resource
            foo.sh        #  <-- script files for use with the script resource
        vars/             #
            main.yml      #  <-- variables associated with this role
        defaults/         #
            main.yml      #  <-- default lower priority variables for this role
        meta/             #
            main.yml      #  <-- role dependencies

    webserver/              # 像上面的common一样,这个目录代表了一个名为webserver的 "role"
    monitoring/           # ""
    fooapp/               # ""
```
# 服务器清单文件
```
[prod]
redis1 ansible_ssh_host=10.178.151.211
[prod]是组名,用中括号括起
下面是在组内的服务器地址。
服务器地址这部分可以使用域名、主机名、IP地址表示。但是使用域名或主机名时,需要ansible主机能够反解析到相应的IP地址,所以一般此类配置中多使用IP地址；
```
# 主机变量
```
在主机条目上可以加变量,以便后面的playbook执行时使用,比如
[prod]
redis1 ansible_ssh_host=10.178.151.211 password=UYSbdyf
```
# 组变量
```
就是给整个组加变量
[prod]
redis1 ansible_ssh_host=10.178.151.211
[prod:vars]
password=UYSbdyf
```
# inventory参数
```
通过参数指定ssh的交互;有以下参数
ansible_ssh_host 
ansible_ssh_port
ansible_ssh_user
ansible_ssh_pass
ansible_sudo_pass
ansible_connection
ansible_ssh_private_key_file
ansible_shell_type
ansible_python_interpreter
eg:
[prod]
redis1 ansible_ssh_host=10.178.151.211 ansible_ssh_port=50022 ansible_ssh_user=root
```
# group_vars
```
用于存放group相关的变量
在上面的inventory 文件中，我们定义过组变量
如果组变量可以抽取出来多个组公用，就可以放在group_vars下。
比如上面我给名叫prod的组定义过变量。现在要抽取出来，就要在group_vars目录下创建一个名为prod的文件
把变量放进去。
所以，文件名和组名是对应的。
文件内容格式如下：
---
password=UYSbdyf
```
# playbook主文件
```
ansible-playbook site.yml
这个主文件不是一定要叫site.yml。随便起名。根据你自己的业务来起名即可。比如后面的webservers.yml和dbservers.yml。
我们这里写一个redis.yml,用来部署redis
sts: redis
  remote_user: root
  gather_facts: True
  roles:
  - redis
主文件的内容就是指定哪些主机进行什么操作。用什么用户等等。
```
# roles
```
roles是整个playbook的重点。role可以理解为做一件事的一个角色。
roles目录下面根据你自己的业务，可以定义多个role子目录，对应完成某件工作。
为了做成这件事的一些列操作都写到这个role子目录下。比如这里的common,webserver,monitoring,fooapp等
```
# tasks
```
tasks下的文件就是完成工作的一个个具体动作，
至少要包含main.yml,playbook执行时默认就找这个main.yml。可以定义其他的yml文件，在main.yml引入
eg:
- name: System Add group {{ redisgroup }}
  group: gid={{ usergid }} name={{ redisgroup }} state=present system=yes

- name: System Add user {{ redisuser }}
  user:
    name: '{{ redisuser }}'
    ...省略

- name: create redis database directory
  file: path='/data/redis_data' state=directory mode='0755' owner={{ redisuser }} group={{ redisgroup }}

- name: create logs directory
  file: path='/data/logs/redis' state=directory mode='0755' owner={{ redisuser }} group={{ redisgroup }}

- name: yum install {{ pkgname }}
  yum: name={{ pkgname }} state=present

- name: Template Set {{ pkgname }} Config Files
  template:  src='redis.conf.j2' dest='/etc/redis.conf' owner={{ redisuser }} group={{ redisgroup }} mode='0755'
  notify:
    - restart redis service
通过-name来说明这个动作的作用
可以看到里面使用了变量。用{{xx}}包围的。这些变量放在vars文件夹下。
其中的动作Action，group，user，file，yum等就是我们上一篇中说的ansible的内置模块
playbook对task的执行时从上到下按顺序一个一个执行的。执行的结果是幂等的。这个特性非常使用。
对一台客户机多次执行playbook是安全的。
为什么是幂等的呢？
仔细观察task的动作，会发现其对动作的描述都是声明式的。
比如 yum: name={{ pkgname }} state=present
有一个state值是present，表明我们期望达到的效果是安装了这个包。所以ansible会采取的操作是先检查有没有安装，没有安装才进行安装。
在这个例子中，还用到了template模块。它会去找templates目录下的模板文件，进行变量替换后，放到客户机指定的目录下。
还有一个notify，这个特性和下面要讲到的handler有关
```
# handlers
```
应当包含一个main.yml文件，用于定义此角色用到的各handlers，
在handler中可以使用inclnude引入其它的handlers文件；
handler是干嘛的？
handler是用来描述当关注的资源的状态发生变化时要采取的操作。
比如main.yml中这样写
- name: restart redis service
  service: name={{ pkgname }} state=restarted
这里的name要注意，它的值必须和上面task文件中norify的值一致！！，不是随便写的。
也就是说，当task中的redis.conf文件修改了之后，会触发notify这个名叫restart redis service的handler
这个handler执行的操作就是调用service模块，对某个service进行restart
```
# templates
```
存放模板文件;playbook使用jinja2模板文件
比如我们讲redis.conf作为一个模板配置文件redis.conf.j2
bind {{ bindip }}
protected-mode yes
port 6379
tcp-backlog 511
timeout 0
tcp-keepalive 300
daemonize {{ mode }}
...
模板文件中的变量从vars目录下取
```
# 执行
```
执行就简单了，通过ansible-playbook redis.yaml 命令运行即可
#ansible-playbook -h
#ansible-playbook常用选项：
--check  or -C    #只检测可能会发生的改变，但不真正执行操作
--list-hosts      #列出运行任务的主机
--list-tags       #列出playbook文件中定义所有的tags
--list-tasks      #列出playbook文件中定义的所以任务集
--limit           #主机列表 只针对主机列表中的某个主机或者某个组执行
-f                #指定并发数，默认为5个
-t                #指定tags运行，运行某一个或者多个tags。（前提playbook中有定义tags）
-v                #显示过程  -vv  -vvv更详细
```
[IT技术圈](https://www.toutiao.com/article/7205882195892847116)  


*** 
# 示例
<details>
  <summary>playbook-example</summary>
  <pre><code> 
```
#dockervars.yml
---
  username: "enter your dockerhub username"
password: "enter your dockerhub password"
#git.yml
---
  - name: "deploying docker from git"
  hosts: build
    become: true
  vars_files:
    - dockervars.yml
  vars:
    pkg:
      - docker
      - git
      - pip
    url: "https://github.com/antony-a-n/devops-flask.git"
    clone: "/var/flaskapp"
    img: "antonyanlinux/flask"

  tasks:
    - name: "installing packages"
      yum:
        name: "{{pkg}}"
        state: present
        
            - name: "adding user to docker group"
      user:
        name: "ec2-user"
        groups:
          - docker
        append: true

    - name: "installing python module"
      pip:
        name: docker-py

    - name: "restarting service"
      service:
        name: docker
                state: restarted
                        enabled: true

    - name: "creating document-root"
      file:
        path: "{{clone}}"
        state: "directory"

    - name: "cloning-repo"
      git:
        repo: "{{url}}"
        dest: "{{clone}}"
      register: clone_state
          - name: "login"
      when: clone_state.changed
      docker_login:
        username: "{{username}}"
        password: "{{password}}"
        state: present
        
            - name: "image building"
      when: clone_state.changed
      docker_image:
        source: build
                build:
          path: "{{clone}}"
          pull: true
        name: "{{img}}"
        tag: "{{item}}"
        push: true
        force_tag: true
        force_source: true
      with_items:
        - latest
        - "{{clone_state.after}}"

    - name: "removing local image"
      when: clone_state.changed
      docker_image:
        state: absent
                name: "{{img}}"
        tag: "{{item}}"
      with_items:
        - latest
        - "{{clone_state.after}}"

    - name: "logout"
      when: clone_state.changed
      docker_login:
        username: "{{username}}"
        password: "{{password}}"
        state: absent
        
        - name: "testing image"
  hosts: test
    become: true
  vars:
    test_img: "antonyanlinux/flask"
    test_pkg:
      - docker
      - pip

  tasks:
    - name: "package installation"
      yum:
        name: "{{test_pkg}}"
        state: "present"
    - name: "attaching user"
      user:
        name: "ec2-user"
        groups:
          - docker
        append: true

    - name: "installing module"
      pip:
        name: docker-py
    - name: "restarting service"
      service:
        name: docker
                state: started
                        enabled: true
    - name: "pulling image"
      docker_image:
        name: "{{test_img}}"
        source: pull
                force_source: true
      register: image_stat
      
          - name: "creating docker container"
      when: image_stat.changed
      docker_container:
        name: flaskdemo
                image: "{{test_img}}:latest"
        recreate: yes
                pull : yes
                        published_ports:
          - "80:5000"
```
ansible-playbook -i inventory git.yml  
  </code></pre>
</details>



