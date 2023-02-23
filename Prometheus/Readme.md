# 监控
**应用系统三维监控** 
- 业务指标(Metric)
  ```
  Metric是带统计量的事件,支持自定义业务监控指标，统计指定时间段的业务数据。开源解决方案有Prometheus+Grafana。 
  ```
- 分布式追踪(Trace)
  ```
  Trace是带请求追踪的事件,例如一次调用远程服务的RPC执行过程、一次实际的SQL查询语句、一次HTTP请求等等。开源解决方案有Skywalking、Pinpoint、Cat等等。 
  ```
- 日志(Log)  
  ```
  Log是离散的事件,记录debug或error信息。开源解决方案ELK和EFK。ELK生态提供了日志IDE记录、滚动和查询等等。
  ``` 
![架构关系](https://p3.toutiaoimg.com/large/tos-cn-i-jcdsk5yqko/a2362d25d8654f95976fc8820e3fd8d7)  
  

