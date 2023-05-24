# k8s工作负载控制器
# [k8s原来不是直接创建Pod-小心程序猿QAQ](https://www.toutiao.com/article/7235184706738962948/)  
## Deployment
**1、Deployment主要功能**    
- 管理Pod和ReplicaSet
- 具有上线部署、副本设定、滚动升级、回滚等功能  
- 提供声明式更新,例如只更新一个新的Images 
- 使用场景：网站、API、微服务  
 
Pod与控制器的关系图  
![https://www.cnblogs.com/yypc/articles/17166489.html](https://img2023.cnblogs.com/blog/1283445/202302/1283445-20230228232534364-1236199343.png)  

**2、Deployment应用生命周期管理流程**  
![https://www.cnblogs.com/yypc/articles/17166489.html](https://img2023.cnblogs.com/blog/1283445/202302/1283445-20230228232534286-869392573.png) 

**3、Deployment生命周期管理流程操作**  


## StatefulSet
## DaemonSet

