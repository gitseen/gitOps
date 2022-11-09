# MySQL和MySQL8版本区别
Oracle发布新版本的MySQL时，直接从5.7.x 跳到了8.0可谓是一个大的版本跳跃,当然也可以从侧面反映，这里面的功能会有不少的变化，新版本的MySQL增加了不少的亮点。

# MySQL8中值得关注的新特性和改进
  1、 性能提升级。官方表示MySQL8.0 的速度要比MySQL 5.7快2 倍。MySQL 8.0在读/写工作负载、IO密集型工作负载、以及高竞争工作负载时相比MySQL5.7有更好的性能  
  2、 更强的NoSQL文档支持  
  3、 重构BLOB  
  4、 持久化设置。MySQL8.0新增SET PERSIST的命令 #SET PERSIST max_connections = 400  
  5、 事务性数据字典  
  6、 SQL角色。可以创建角色，给用户设置或去除角色，大大方便权限的管理    
  7、 隐藏索引 
  8、 UTF-8编码。从MySQL8.0开始，使用utf8mb4作来MySQL的默认字符集  

##1、druid数据源的driver-class-name配置
MySQL5： driver-class-name: com.mysql.jdbc.Driver
MySQL8： driver-class-name: com.mysql.cj.jdbc.Driver

##2、url配置
MySQL5：url: jdbc:mysql://localhost:3306/数据库名

MySQL8：url: jdbc:mysql://localhost:3306/数据库名**?&serverTimezone=UTC**

