# [手写K8S的YAML](https://www.toutiao.com/article/7247048547579822627)
**三把利剑：help、dry-run、explain**  

# K8S集群中yaml文件说明
# 1、k8s常用指令
```
kubectl apply -f <文件名>   #根据yaml文件部署
kubectl delete -f <文件名>  #根据yaml文件删除
kubectl get node,pod,svc  #查看k8s个组件的状态
kubectl describe node <node名称>  #查看node详情
kubectl describe pod <pod名称> #查看pod详情
kubectl describe svc <svc名称> #查看service详情
kubectl delete svc <svc名称> -n <命名空间>  #删除svc 
kubectl exec -it <pod名称> -c <容器组空间> -n <命名空间> -- bash   #进入容器内部
kubectl cp -n <命名空间> <pod名称>:/文件src /本地文件  #容器拷贝文件到本地服务器
```
# 2、yaml文件配置说明
```
参考文档： Kubernetes中文文档
缩进标识层级关系
不支持制表符缩进,使用空格缩进
缩进的空格数目不重要,只要相同层级的元素左侧对齐即可
通常开头缩进两个空格
字符后缩进一个空格, 如冒号,逗号,- 等
“—”表示YAML格式,一个文件的开始,用于分隔文件间。
“#”表示注释,从这个字符一直到行尾,都会被解析器忽略　
在Kubernetes中,只需要知道两种结构类型即可：
Lists
Maps
```
   ## 2.1 yaml语法格式
   ### 2.1.1 YAML Maps
Map指的是字典,即一个Key:Value 的键值对信息。例如：
```
apiVersion: v1
kind: Pod
注：---为可选的分隔符 ,当需要在一个文件中定义多个结构的时候需要使用。上述内容表示有两个键apiVersion和kind,分别对应的值为v1和Pod。
```
Maps的value既能够对应字符串也能够对应一个Maps
```
       apiVersion: v1
       kind: Pod
       metadata:
         name: kube100-site
         labels:
           app: web
       注：上述的YAML文件中,metadata这个KEY对应的值为一个Maps,而嵌套的labels这个KEY的值又是一个Map。实际使用中可视情况进行多层嵌套。  
       YAML处理器根据行缩进来知道内容之间的关联。上述例子中,使用两个空格作为缩进,但空格的数据量并不重要,只是至少要求一个空格并且所有缩进保持一致的空格数 。  
       例如,name和labels是相同缩进级别,因此YAML处理器知道他们属于同一map；它知道app是lables的值因为app的缩进更大。  
```
   ### 2.1.2 YAML Lists
   List即列表,说白了就是数组,例如  
   ```
args
  - beijing
  - shanghai
  - shenzhen
  - guangzhou
   ```
$\color{red}{当然Lists的子项也可以是Maps,Maps的子项也可以是List}$  
```
apiVersion: v1
kind: Pod
metadata:
  name: kube100-site
  labels:
    app: web
spec:
  containers:
    - name: front-end
      image: nginx
      ports:
        - containerPort: 80
    - name: flaskapp-demo
      image: jcdemo/flaskapp
      ports: 8080

如上所示,定义一个containers的List对象,每个子项都由name、image、ports组成,每个ports都有一个KEY为containerPort的Map组成
   ```

   ## 2.2 yaml四个必须配置项
+ apiVersion：表示指定api版本,目前大部分都是写v1,此值不是写死的,此值可以在本机上执行kubectl api-versions命令查看。
+ kind：表示该yaml定义的资源类型,k8s中资源有很多种,包括Pod,Deployment,Job,Services等等。
+ metadata：表示创建的资源的一些元数据,这是个对象类型,里面包含名称、namespace、标签等信息。
+ spec：这也是对象类型,内容包括一些container,storage,volume等。  

这四个部分是k8s的yaml必须存在的配置项,如果没有,k8s是不允许执行的。  
   ## 2.3 示例说明
   ### 2.3.1 yaml格式的pod定义文件
```bash
apiVersion: v1                          #必选 指定api版本,此值必须在kubectl apiversion中  
kind: Pod                               #必选,指定创建资源的角色/类型 
metadata:                               #必选,资源的元数据/属性
  name: string                          #必选,资源的名字,在同一个namespace中必须唯一  
  namespace: string                     #所属的命名空间,不填则为defualt
  labels:                               #自定义标签
    - name: string                      #自定义标签名字
  annotations:                          #自定义注释列表
    - name: string                      #自定义注解名字
spec:                                   #必选,设置该资源的内容  
  restartPolicy: Always/Never/OnFailure   #Pod的重启策略,Always表示一旦不管以何种方式终止运行,kubelet都将重启,OnFailure表示只有Pod以非0退出码退出才重启,Nerver表示不再重启该Pod
  nodeSelector:                           #选择node   
    key:value                             #表示将该Pod调度到包含这个label的node上,以key：value的格式指定
  containers:                           #必选,容器列表
  - name: string                        #必选,容器名称
    image: string                       #必选,容器的镜像名称
    imagePullPolicy: [Always | Never | IfNotPresent] #获取镜像的策略 Alawys表示下载镜像 IfnotPresent表示优先使用本地镜像,否则下载镜像,Nerver表示仅使用本地镜像
    command: ['sh']                 #容器的启动命令列表,如不指定,使用打包时使用的启动命令ENTRYPOINT 
    args: ["$(str)"]                #容器的启动命令参数列表,对应Dockerfile中CMD参数  
    env:                                #容器运行前需设置的环境变量列表
    - name: string            #环境变量名称
      value: string           #环境变量的值
    resources:                #资源限制和请求的设置
      limits:                 #资源限制的设置
        cpu: string           #Cpu的限制,单位为core数,将用于docker run --cpu-shares参数
                              #两种方式,浮点数或者是整数+m,0.1=100m,最少值为0.001核（1m）
        memory: string        #内存限制,单位可以为Mib/Gib,将用于docker run --memory参数
      requests:               #资源请求的设置
        cpu: string           #Cpu请求,容器启动的初始可用数量
        memory: string        #内存请求,容器启动的初始可用数量
    workingDir: string        #容器的工作目录
    ports:                    #需要暴露的端口库号列表
    - name: string            #端口号名称
      containerPort: int      #容器开发对外的端口
      hostPort: int           #容器所在主机需要监听的端口号,默认与Container相同
      protocol: string        #端口协议,支持TCP和UDP,默认TCP    
    livenessProbe:            #对Pod内个容器健康检查的设置,当探测无响应几次后将自动重启该容器,检查方法有exec、httpGet和tcpSocket,对一个容器只需设置其中一种方法即可
      exec:                   #对Pod容器内检查方式设置为exec方式
        command: [string]     #exec方式需要制定的命令或脚本
      httpGet:                #对Pod内个容器健康检查方法设置为HttpGet,需要制定Path、port
        path: string
        port: number
        host: string
        scheme: string
        HttpHeaders:
        - name: string
          value: string
    lifecycle:                #生命周期管理(钩子)  
      postStart:              #容器运行之前运行的任务  
        exec:                                    
          command:                               
            - 'sh'                               
            - 'yum upgrade -y'                   
      preStop:                #容器关闭之前运行的任务  
        exec:                                    
          command: ['service httpd stop']       
      tcpSocket:              #对Pod内个容器健康检查方式设置为tcpSocket方式
         port: number
      initialDelaySeconds: 0  #容器启动完成后首次探测的时间,单位为秒
      timeoutSeconds: 0       #对容器健康检查探测等待响应的超时时间,单位秒,默认1秒
      periodSeconds: 0        #对容器监控检查的定期探测时间设置,单位秒,默认10秒一次
      successThreshold: 0
      failureThreshold: 0
      securityContext:
         privileged: false    
    volumeMounts:             #挂载到容器内部的存储卷配置
    - name: string            #引用pod定义的共享存储卷的名称,需用volumes[]部分定义的的卷名
      mountPath: string       #存储卷在容器内mount的绝对路径,应少于512字符
      readOnly: boolean       #是否为只读模式     
    imagePullSecrets:         #Pull镜像时使用的secret名称,以key：secretkey格式指定
    - name: string
    hostNetwork: false        #是否使用主机网络模式,默认为false,如果设置为true,表示使用宿主机网络
volumes:                      #在该pod上定义共享存储卷列表
    - name: string            #共享存储卷名称 （volumes类型有很多种）
      emptyDir: {}            #类型为emtyDir的存储卷,与Pod同生命周期的一个临时目录。为空值
      hostPath:               #类型为hostPath的存储卷,表示挂载Pod所在宿主机的目录
        path: /opt            #挂载设备类型为hostPath,路径为宿主机下的/opt
      secret:                 #类型为secret的存储卷,挂载集群与定义的secre对象到容器内部
        scretname: string  
        items:     
        - key: string
          path: string
      configMap:              #类型为configMap的存储卷,挂载预定义的configMap对象到容器内部
        name: string
        items:
        - key: string
```
   ### 2.3.2 yaml格式的service定义文件
```bash
apiVersion: v1
kind: Service
metadata:                                   #元数据
  name: string                              #名称
  namespace: string                         #命名空间
  labels:                                   #标签信息
    k8s.kuboard.cn/layer: ''
    k8s.kuboard.cn/name: string   
  annotations:                              #注释信息
    k8s.kuboard.cn/workload: string   
spec:                                       #定义Service模板
  clusterIP: ip address                     #指定svcip地址 不指定则随机 

 =================================================================================================
  #NodePort类型：集群外网络
  type: NodePort                            #类型为NodePort  
  ports:
    - name: string
      nodePort: 30001                       #当type = NodePort时,指定映射到物理机的端口号
      port: 80                              #服务监听的端口号
      protocol: TCP                         #端口协议,支持TCP和UDP,默认TCP
      targetPort: 80                        #需要转发到后端Pod的端口号

  ==================================================================================================
  #ClusterIP类型： 集群内网络
  type: ClusterIP                           #
  ports:
    - name: string
      port: 80
      protocol: TCP
      targetPort: 80
    - name: string
      port: 22
      protocol: TCP
      targetPort: 22
  selector:                                 #label selector配置,将选择具有label标签的Pod作为管理 
    k8s.kuboard.cn/layer: ''
    k8s.kuboard.cn/name: string   
  sessionAffinity: None                     #是否支持session
```
   ### 2.3.3 yaml格式的deployment定义文件  
```
apiVersion: apps/v1                            
kind: Deployment                               
metadata:                                      #元数据
  name: string                                 #名称
  namespace: string                            #命名空间    
  labels:                                      #标签信息
    name: string                               
  annotations:                                 #注释信息
    deployment.kubernetes.io/revision: '1'     
    k8s.kuboard.cn/ingress: 'false'            
    k8s.kuboard.cn/service: NodePort           
    k8s.kuboard.cn/workload: string            

spec:                                          #定义容器模板,该模板可以包含多个容器  
  replicas: 3                                  #副本数量
  selector:                                    #标签选择器
    matchLabels:                               
      k8s.kuboard.cn/layer: ''                 
      k8s.kuboard.cn/name: string              
  strategy:                                    #滚动升级策略
    type: RollingUpdate                        #类型
    rollingUpdate:                             #由于replicas为3,则整个升级,pod个数在2-4个之间     
      maxSurge: 25%                            #滚动升级时会先启动25%pod 
      maxUnavailable: 25%                      #滚动升级时允许的最大Unavailable的pod个数
  template:                                                      #镜像模板                                      
    metadata:                                    #元数据
      labels:                                  #标签
        k8s.kuboard.cn/layer: ''               
        k8s.kuboard.cn/name: string            
    spec:                                      #定义容器模板,该模板可以包含多个容器
      containers:                              #容器信息
      - name: string                           #容器名称
        image: url:version                     #镜像名称:版本号
        imagePullPolicy: Always                #镜像下载策略  
        ports:                               
            - name: http                       
              containerPort: 80                
              protocol: TCP                    
        env: 
        - name: string                         #环境变量名称
          value: string                        #环境变量的值                                 
        resources:                             #CPU内存限制
          limits:                                #限制cpu内存                                           
              cpu: 200m                        
              memory: 200m                     
          requests:                            #请求cpu内存
              cpu: 100m                        
              memory: 100m                     
          securityContext:                     #安全设定
            privileged: true                   #开启享有特权
        volumeMounts:                            #挂载volumes中定义的磁盘
        - name: html                           #挂载容器1
          mountPath: /var/www/html         
        - name: session                        #挂载容器1
          mountPath: /var/lib/php/session     
      volumes:                                 #在该pod上定义共享存储卷列表
        - name: html                           #共享存储卷名称 （volumes类型有很多种）
          persistentVolumeClaim:               #volumes类型为pvc
            claimName: html                    #关联pvc名称
        - name: session                        
          persistentVolumeClaim:               
            claimName: session                 
      restartPolicy: Always                    #Pod的重启策略 
                                               #Always表示一旦不管以何种方式终止运行,
                                               #kubelet都将重启,
                                               #OnFailure表示只有Pod以非0退出码退出才重启,
                                               #Nerver表示不再重启该Pod
      schedulerName: default-scheduler         #指定pod调度到节点
```
---

# yaml资源清单详解

[yaml资源清单详解-全栈行动派](https://www.toutiao.com/article/7214293775106032188)  

## 概述
kubectl提供了各种命令,来管理集群中的pod,但是这些命令都是为了方便运维测试,实际生产部署还得用yaml文件来部署,所以弄清楚各类资源的字段是非常重要的  

资源清单就是k8s当中用来定义pod的文件,语法格式遵循yaml语法,在yaml当中可以定义控制器类型,元数据,容器端口号等等等....,也可以针对于清单对pod进行删除等操作  

## yaml资源清单各个字段中文详解
以Deployment为例 ,详解常用字段  

>>小提示：
在这里,可通过一个命令来查看每种资源的可配置项  
kubectl explain 资源类型 查看某种资源可以配置的一级属性  
kubectl explain 资源类型.属性 查看属性的子属性  

<details>
  <summary>Deployment-yaml-list</summary>
  <pre><code>
apiVersion: apps/v1             #必填,版本号
kind: Deployment                #必填,资源类型
metadata:                       #必填,元数据
  labels:                       #自定义标签列表
    app: mynginx
  name: mynginx                 #Deployment名称
  namespace: dev                #Deployment命名空间
spec:                           #必填,Deployment管理的pod信息
  replicas: 1                   #管理pod副本个数
  selector:                     #选择器
    matchLabels:                #匹配标签选择器
      app: mynginx              #匹配标签,本例意思：Deployment控制器管理拥有app=mynginx标签的pod
  template:                     #模板
    metadata:                   #模板元数据
      labels:                   #模板标签,意思是此模板下所有容器均增加此标签
        app: mynginx
    spec:                       #必填,Pod中容器的详细定义
      containers:               #模板下拥有的容器,最少1个
        - image: nginx          #容器使用的镜像
          name: nginx           #容器名称
          imagePullPolicy: [ Always|Never|IfNotPresent ]  #获取镜像的策略
          command: [string]     #容器的启动命令列表,如不指定,使用打包时使用的启动命令
          args: [string]        #容器的启动命令参数列表
          workingDir: string    #容器的工作目录
          volumeMounts:         #挂载到容器内部的存储卷配置
            - name: string      #引用pod定义的共享存储卷的名称,需用volumes[]部分定义的的卷名
              mountPath: string #存储卷在容器内mount的绝对路径,应少于512字符
              readOnly: boolean #是否为只读模式
          ports:                #需要暴露的端口库号列表
            - name: string        #端口的名称
              containerPort: int  #容器需要监听的端口号
              hostPort: int       #容器所在主机需要监听的端口号,默认与Container相同
              protocol: string    #端口协议,支持TCP和UDP,默认TCP
          env:                    #容器运行前需设置的环境变量列表
            - name: string        #环境变量名称
              value: string       #环境变量的值
          resources:              #资源限制和请求的设置
            limits:               #资源限制的设置
              cpu: string         #Cpu的限制,单位为core数,将用于docker run --cpu-shares参数
              memory: string      #内存限制,单位可以为Mib/Gib,将用于docker run --memory参数
            requests:             #资源请求的设置
              cpu: string         #Cpu请求,容器启动的初始可用数量
              memory: string      #内存请求,容器启动的初始可用数量
          lifecycle:              #生命周期钩子
            postStart:            #容器启动后立即执行此钩子,如果执行失败,会根据重启策略进行重启
            preStop:              #容器终止前执行此钩子,无论结果如何,容器都会终止
          livenessProbe:          #对Pod内各容器健康检查的设置,当探测无响应几次后将自动重启该容器
            exec:       　        #对Pod容器内检查方式设置为exec方式
              command: [string]   #exec方式需要制定的命令或脚本
            httpGet:              #对Pod内个容器健康检查方法设置为HttpGet,需要制定Path、port
              path: string
              port: number
              host: string
              scheme: string
              HttpHeaders:
                - name: string
                  value: string
            tcpSocket:            #对Pod内的容器健康检查方式设置为tcpSocket方式
              port: number
              initialDelaySeconds: 0       #容器启动完成后首次探测的时间,单位为秒
              timeoutSeconds: 0    　　     #对容器健康检查探测等待响应的超时时间,单位秒,默认1秒
              periodSeconds: 0     　　     #对容器监控检查的定期探测时间设置,单位秒,默认10秒一次
              successThreshold: 0
              failureThreshold: 0
              securityContext:
                privileged: false
      restartPolicy: [Always | Never | OnFailure]  #Pod的重启策略
      nodeName: <string>          #设置NodeName表示将该Pod调度到指定到名称的node节点上
      nodeSelector: obeject       #设置NodeSelector表示将该Pod调度到包含这个label的node上
      imagePullSecrets:           #Pull镜像时使用的secret名称,以key：secretkey格式指定
        - name: string
      hostNetwork: false          #是否使用主机网络模式,默认为false,如果设置为true,表示使用宿主机网络
      volumes:                    #在该pod上定义共享存储卷列表
        - name: string            #共享存储卷名称 （volumes类型有很多种）
          emptyDir: {}            #类型为emtyDir的存储卷,与Pod同生命周期的一个临时目录。为空值
          hostPath: string        #类型为hostPath的存储卷,表示挂载Pod所在宿主机的目录
            path: string      　　        #Pod所在宿主机的目录,将被用于同期中mount的目录
          secret:       　　　     #类型为secret的存储卷,挂载集群与定义的secret对象到容器内部
            scretname: string
            items:
              - key: string
                path: string
          configMap:               #类型为configMap的存储卷,挂载预定义的configMap对象到容器内部
            name: string
            items:
              - key: string
                path: string
status: {}
  </code></pre>
</details>

**Deployment重要详解**
- apiversion  
    用来指定api的版本,定义的语法格式为group/version,比如我们要定义deployment控制器,那么我们的apiVersion：apps/v1,如果我们要定义自主式pod,那么需要定义apiVersion：v1,如果要获取有哪些apiVersion可以用如下命令  
- kind  
    kind字段主要用于定义控制器类型,指的是yml文件定义的资源类型和角色,比如：我们想定义一个自助式pod,那么我们就应该定义kind：Pod,如果我们要定义一个deployment控制器管理的pod,那么我们就应该定义kind：Deployment  
- metadate  
    对于metadata字段为元数据,我们已经知道k8s是通过标签选择器的方式管理pod,因此,在metadata当中最重要的就是标签,我们可以在metadata当中定义名称空间,标签等,我们如果想查看metadata下可以定义哪些元数据可以使用kubectl explain pod.metadata命令来查看  
- labels  
    标签选择器,labels的值决定service控制器关联pod的重要选项  
- name  
    这里是自主式[pod|services|deployment|...]名称,如果是控制器[pod|services|deployment|...],这里是控制器名称  
- namespace  
    名称空间,默认为default名称空间  
- annotations  
    资源注解,这里跟labels很像,都是键值对,但是不同点是,不能用于挑选资源对象,仅用于"元数据"  
- spec字段  
    spec字段用来定义期望容器达到的状态,在spec字段当中可以定义多个容器,容器的名称,容器的镜像,拖取容器镜像的方式,暴露的端口号,存储卷,容器个数等,也就是说真正定义pod是在spec字段当中定义的  

**查看spec详细用法命令**  
```
kubectl explain [pod|services|deployment|...].spec
```  

from https://www.toutiao.com/article/7196554496028246565  



