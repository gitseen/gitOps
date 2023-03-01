# Dockerfile的命令
|  命令     |  作用  |
|  ----     | ----  |
| FROM  | 指明当前镜像是基于哪个基础镜像的，第一个指令必须是FROM |
| MAINTAINER | 镜像维护者的姓名和邮箱地址[废弃] |
| LABEL | 用于为镜像添加元数据，元数以键值对的形式指定 |
| RUN  | 构建镜像时需要运行的指令 |
| EXPOSE | 当前容器对外暴露出的端口号 | 
| WORKDIR | 指定在创建容器后，终端默认登录进来的工作目录，一个落脚点 | 
| ENV  | 用来在构建镜像过程中设置环境变量 | 
| ADD | 将宿主机目录下的文件拷贝进镜像且ADD命令会自动处理URL和解压tar包 | 
| COPY  | 类似于ADD，拷贝文件和目录到镜像中。将从构建上下文目录中<原路径>的文件/目录复制到新的一层的镜像内的<目标路径>位置 | 
| VOLUME | 容器数据卷，用于数据保存和持久化工作 | 
| CMD  | 指定一个容器启动时要运行的命令;Dockerfil中可以有多个CMD指令，但只有最后一个生效，CMD会被docker run之后的参数替换| 
| ENTRYPOINT | 指定一个容器启动时要运行的命令;ENTRYPOINT的目的和CMD-样,都是在指定容器启动程序及其参数 |


# Dockerfile编写说明
## 1.1 FROM 命令
+ 基于基础镜像进行构建新的境像。在构建时会自动从docker hub拉取base镜像。必须作为Dockerfile的第一个指令出现
+ 语法
```
FROM <image>
# 或
FROM <image> [:<tag>]     使用版本不写为latest
# 或
FROM <image>[@<digest>]  <digest>为校验码
```
## 1.2 MAINTAINER命令
- 镜像维护者的姓名和邮箱地址[废弃]，可用LABEL实现
- 语法：
```
MAINTAINER <name>
```
## 1.3 LABEL命令
* LABEL用于为镜像添加元数据，元数以键值对的形式指定
* 使用LABEL指定元数据时，一条LABEL指定可以指定一或多条元数据，指定多条元数据时不同元数据之间通过空格分隔。推荐将所有的元数据通过一条LABEL指令指定，以免生成过多的中间镜像
* 语法：
```
LABEL <key>=<value> <key>=<value> <key>=<value> ...
# eg
LABEL version="1.0" description="这是一个Web服务器" by="liu"
```
## 1.4 RUN命令
* RUN用于指定docker build过程中运行的指令，有个限定：一般为基础镜像可以运行的命令，如基础镜像为centos，安装软件命令为yum而不是ubuntu里的apt-get命令
* 语法：
```
# shell 格式： <命令行命令> 等同于，在终端操作的 shell 命令。
RUN <命令行命令>
# exec 格式：
RUN ["可执行文件", "参数1", "参数2"]
# 例如： RUN ["./test.php", "dev", "offline"] 等价于 RUN ./test.php dev offline
# 优化镜像层可以使用RUN && 实现一层镜像
```
## 1.5 EXPOSE命令
- 用来指定构建的镜像在运行为容器时对外暴露的端口
- 在运行时使用随机端口映射时，也就是docker run -P时，会自动随机映射EXPOSE的端口
- 语法：
```
EXPOSE <端口1> [<端口2>...]
EXPOSE 80/tcp 如果没有 显示指定则默认暴露都是tcp
EXPOSE 80/udp
```
## 1.6 CMD命令
#注意：如果 Dockerfile 中如果存在多个 CMD 指令，仅最后一个生效。
- 为启动的容器指定默认要运行的程序，程序运行结束，容器也就结束。CMD指令指定的程序可被 docker run命令行参数中指定要运行的程序所覆盖。
- 语法：
```
CMD <shell 命令> 
CMD ["<可执行文件或命令>","<param1>","<param2>",...] 
CMD ["<param1>","<param2>",...]  # 该写法是为 ENTRYPOINT 指令指定的程序提供默认参数
```
## 1.7 WORKDIR命令
- 用来为Dockefie中的任何RUN, CMD. ENTRYPOINT. COPYADD指令设置工作目录。如果WORKDIR不存在，即使它没有在任何后续Dockerfie指令中使用，它也将被创建。
- 语法：
```
WORKDIR <工作目录路径>
eg:
WOEKDIR /data    # 进入/data 目录
WORKDIR bb       # 进入/data/bb 目录
```
## 1.8 ENV命令
- 设置环境变量，定义了环境变量，那么在后续的指令中，就可以使用这个环境变量。
- 语法：
```
ENV <key> <value>
ENV <key1>=<value1> <key2>=<value2>...
```
## 1.9 COPY命令
- 复制指令，从上下文目录中复制文件或者目录到容器里指定路径
- 语法：
```
COPY [--chown=<user>:<group>] <源路径1>...  <目标路径>
COPY [--chown=<user>:<group>] ["<源路径1>",...  "<目标路径>"]
# [--chown=<user>:<group>]：可选参数，用户改变复制到容器内文件的拥有者和属组
# <源路径>：源文件或者源目录，这里可以是通配符表达式，其通配符规则要满足 Go 的 filepath.Match 规则。例如：
COPY hom* /mydir/
COPY hom?.txt /mydir/
# <目标路径>：容器内的指定路径，该路径不用事先建好，路径不存在的话，会自动创建。
```
## 1.10 ADD命令
- ADD指令和COPY的使用语法类似（同样需求下，官方推荐使用COPY）。功能也类似，不同之处如下
  * ADD的优点：在执行<源文件>为tar压缩文件的话，压缩格式为gzip, bzip2以及xz的情况下，会自动复制并解压到 <目标路径>。
  * ADD的缺点：在不解压的前提下，无法复制tar压缩文件。会令镜像构建缓存失效，从而可能会令镜像构建变得比较缓慢。具体是否使用，可以根据是否需要自动解压来决定。
  * eg 
  ```
  # 解压文件到 /data/bb
  ADD apache-tomcat-8.5.61.tar.gz /data/bb
  # 重命名
  RUN mv apache-tomcat-8.5.61 tomcat
  # 容器启动时，进入tomcat目录
  WORKDIR tomcat
  ```
## 1.11 VOLUME命令
- 定义匿名数据卷。在启动容器时忘记挂载数据卷，会自动挂载到匿名卷
- 在启动容器docker run的时候，我们可以通过 -v 参数修改挂载点
- 作用
  * 避免重要的数据，因容器重启而丢失，这是非常致命的
  * 避免容器不断变大
- 语法：
```
VOLUME ["<路径1>", "<路径2>"...]
VOLUME <路径>
```
## 1.12 ENTRYPOINT命令
- 类似于CMD指令，但其不会被docker run的命令行参数指定的指令所覆盖，而且这些命令行参数会被当作参数送给ENTRYPOINT指令指定的程序
- 如果运行docker run时使用--entrypoint 选项，将覆盖ENTRYPOINT 指令指定的程序
- 优点：在执行docker run的时候可以指定ENTRYPOINT运行所需的参数
- 注意：如果Dockerfile中如果存在多个ENTRYPOINT指令，仅最后一个生效
- 语法：
```
ENTRYPOINT ["<executeable>","<param1>","<param2>",...]
```
- 可以搭配CMD命令使用：一般是变参才会使用CMD，这里的CMD等于是在给ENTRYPOINT传参，例如：
```
FROM nginx
ENTRYPOINT ["nginx", "-c"] # 定参
CMD ["/etc/nginx/nginx.conf"] # 变参

#不传参运行: docker run  nginx:test 容器内会默认启动主进程nginx -c /etc/nginx/nginx.conf
#传参运行  : docker run  nginx:test -c /etc/nginx/new.conf 容器内会默认启动主进程nginx -c /etc/nginx/new.conf


