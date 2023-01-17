# Nginx 概述
Nginx是一个高性能HTTP和反向代理服务器、IMAP、POP3、SMTP服务器  
Nginx是开源、高性能、高可靠的Web和反向代理服务器，而且支持热部署，几乎可以做到7 * 24小时不间断运行，即使运行几个月也不需要重新启动，还能在不间断服务的情况下对软件版本进行热更新。性能是 Nginx最重要的考量，其占用内存少、并发能力强、能支持高达5w个并发连接数，最重要的是，Nginx是免费的并可以商业化，配置使用也比较简单。    

# Nginx特点  
1、高并发、高性能  
2、模块化架构使得它的扩展性非常好  
3、异步非阻塞的事件驱动模型这点和 Node.js 相似  
4、相对于其它服务器来说它可以连续几个月甚至更长而不需要重启服务器使得它具有高可靠性  
5、热部署、平滑升级  
6、完全开源，生态繁荣  

# Nginx作用(使用场景)
1、静态资源服务、通过本地文件系统提供服务  
2、反向代理服务、延伸出包括缓存、负载均衡等  
3、API服务、OpenResty  

# Nginx能做什么
1、反向代理  
2、负载均衡  
3、HTTP服务器（包含动静分离）  
4、正向代理  
5、限流、缓存、黑白名单  

# Nginx架构
Nginx是由一个master管理进程，多个worker进程处理工作的多进程模型。基础架构设计如下
![如下图所示](https://p3-sign.toutiaoimg.com/pgc-image/53619e18837c4c5fb96e9314dcae038b~noop.image?_iz=58558&from=article.pc_detail&x-expires=1674528628&x-signature=Ds4VpyEHj1R2LpX2Ct14PKVfcPw%3D)  
![2](https://image.z.itpub.net/zitpub.net/JPG/2021-06-15/E2BB82F07925A570101FDC4A9694062D.jpg)  
Master负责管理worker进程，worker进程负责处理网络事件。整个框架被设计为一种依赖事件驱动、异步、非阻塞的模式。  
优点：  
1、可以充分利用多核机器，增强并发处理能力。  
2、多worker间可以实现负载均衡。  
3、Master监控并统一管理worker行为。在worker异常后，可以主动拉起worker进程，从而提升了系统的可靠性。并且由Master进程控制服务运行中的程序升级、配置项修改等操作，从而增强了整体的动态可扩展与热更的能力。    

# Nginx原理

# 负载均衡方式



# Nginx核心配置Core

# 参考来源
[万字总结体系化带你全面认识 Nginx](https://juejin.cn/post/6942607113118023710)  
[Nginx架构](https://www.cnblogs.com/ludongguoa/p/15316464.html)  
