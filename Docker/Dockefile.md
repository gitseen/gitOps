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
## 1.3 LABEL命令
## 1.4 RUN命令
## 1.5 EXPOSE命令
## 1.6 CMD命令
## 1.7 WORKDIR命令
## 1.8 ENV命令
## 1.9 COPY命令
## 1.10 ADD命令
## 1.11 VOLUME命令
## 1.12 ENTRYPOINT命令
