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
## 1.7 WORKDIR命令
## 1.8 ENV命令
## 1.9 COPY命令
## 1.10 ADD命令
## 1.11 VOLUME命令
## 1.12 ENTRYPOINT命令
