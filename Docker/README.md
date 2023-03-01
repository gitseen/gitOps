# [docker官网](https://www.docker.com/)
## Dockerfile文件的格式
一是：# comment。二是：INSTRUCTION arguments 指令和参数,其中约定俗成是指令使用大写,参数小写,但是dockerfile文件本身不区分大小写。  

dockerfile文件内的指令是自上而下一次顺序执行,通常是一行一个指令,如果指令有相互依赖关系一定要注意指令的先后顺序  

dockerfile文件内的第一个非注释行都是以'FROM'指令,它用来指定做当前镜像是基于那个基础镜像来实现,所以我们的镜像制作都是建立在某个已存在的基础镜像上（如果没有指定基础镜像默认情况下docker build会在docker主机上查找指定的镜像文件,在其不存在时,则会从Docker Hub Registry上拉取所需的镜像文件,如果仓库中也没有那么dockerfile也无法制作,那就比较麻烦。),dockerfile文件内的指令也都是基于当前基础镜像的指令,基础镜像没有或不支持的指令也将是无法执行的,所以dockerfile的制作环境都是底层基础镜像启动的容器提供的环境   

## Dockerfile配置文件
必须有一个专门的目录文件放置Dockerfile文件,而Dockerfile的文件的首字母必须是大写,且如果Dockerfile文件中需要安装的安装包或引用的文件也必须和Dockerfile文件在同一个目录文件内,不能是这个目录文件外的内容,但可以是这个文件内的子目录的内容  

dockeringore文件又是另外的一个文件,所有写在dockeringore文件中的路径文件,在Dockerfile配置文件中打包时那个路径文件都不会被打包进去,一般一行一个文件,当然也可以使用通配符  

docker build通过读取Dockerfile文件来制作镜像,打上标签推到仓库就可以使用了  

## Dockerfile编写规则
- 1、指令大小写不敏感,为了区分习惯上用大写
- 2、Dockerfile非注释行第一行必须是FROM
- 3、文件名必须是Dockerfile
- 4、Dockerfile指定一个专门的目录为工作空间
- 5、所有引入映射的文件必须在这个工作空间目录下
- 6、Dockerfile工作空间目录下支持隐藏文件(.dockeringore)
- 7、(.dockeringore)作用是用于存放不需要打包导入镜像的文件,根目录就是工作空间目录
- 8、每一条指令都会生成一个镜像层,镜像层多了执行效率就慢,能写成一条指定的就写成一条  
## Dockerfile文件中的环境变量
变量赋值：变量名=赋值  
变量引用：$variable_name or ${variable_name}  
给变量默认值：  
   ${变量名:-字符串}:如果parameter没被赋值或其值为空,就以string作为默认值,它不会赋值给变量  
   ${变量名:=字符串}:如果parameter没被赋值或其值为空,就以string作为默认值,它会赋值给变量(用户没有传递值)  
   ${变量名:+字符串}:如果parameter没被赋值或其值为空,就什么都不做,否则用string替换变量内容  
[运维技术站-Dockerfile详解](https://www.toutiao.com/article/7205007091323748921)  

