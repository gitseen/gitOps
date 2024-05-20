# 监控体系  
**打造一个高可用、高稳定的系统、监控体系是其中非常关键的一个环节**  
- 1、资源监控
  ```
  包括CPU、MEM、Disk等等。开源的软件有Zabbix
  ``` 
- 2、系统监控
  ```
  有一些通用的监控指标:如响应时间、失败率、慢SQL、JVM(Yong-GC、Full-GC)等等。
  常用的开源软件有Apache SkyWalking、CAT、PinPoint等等
  ```
- 3、业务监控
  ```
  要监控哪些指标,需要根据具体业务进行分析,比如订单支付成功率、下单量、注册客户数等等
  ```
# 日志报警
- 日志的作用之一是针对线上问题,通过查找日志快速定位问题,这是一个被动解决问题的过程
- 日志更重要的作用是主动报警、主动解决。通过对日志等级进行分类,发现有ERROR,进行监控并主动报警
- 一个日志到底是WARNING还是ERROR,需要根据自己的业务决定,并且可以调整
>注意：日志不是摆设,而是专门用来解决问题



# 监控
**应用系统三维监控**
- 业务指标(Metric)
  ```
  Metric是带统计量的事件,支持自定义业务监控指标，统计指定时间段的业务数据。开源解决方案有Prometheus+Grafana
  ```
- 分布式追踪(Trace)
  ```
  Trace是带请求追踪的事件,例如一次调用远程服务的RPC执行过程、一次实际的SQL查询语句、一次HTTP请求等等。开源解决方案有Skywalking、Pinpoint、Cat等等
  ```
- 日志(Log)
  ```
  Log是离散的事件,记录debug或error信息。开源解决方案ELK和EFK。ELK生态提供了日志IDE记录、滚动和查询等等
  ```
![架构关系](https://p3.toutiaoimg.com/large/tos-cn-i-jcdsk5yqko/a2362d25d8654f95976fc8820e3fd8d7)  



# CPU_usagerate_total
```bash
https://www.cnblogs.com/Hackerman/p/16084360.html  #常规
https://www.cnblogs.com/t-road/p/15604040.html  
https://wu.run/posts/promql-calculate-cpu-utilization/   #公式计算
https://zhuanlan.zhihu.com/p/511620387
https://blog.csdn.net/qing_dan_mo_cai/article/details/123938464 
```
