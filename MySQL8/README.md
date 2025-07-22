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

## 1、druid数据源的driver-class-name配置
MySQL5： driver-class-name: com.mysql.jdbc.Driver

MySQL8： driver-class-name: com.mysql.cj.jdbc.Driver

## 2、url配置
MySQL5：url: jdbc:mysql://localhost:3306/数据库名

MySQL8：url: jdbc:mysql://localhost:3306/数据库名**?&serverTimezone=UTC**
```bash
DriverClasses = com.mysql.cj.jdbc.Driver
ecology.url = jdbc:mysql://172.16.216.171:13306/ecology?characterEncoding=utf8&useSSL=false&autoReconnect=true&failOverReadOnly=false&serverTimezone=Asia/Shanghai
ecology.user = ecology
ecology.password = ecology123
ecology.charset = ISO
ecology.maxconn = 300
ecology.minconn = 50
ecology.maxusecount = 6000
ecology.maxidletime = 600
ecology.maxalivetime = 10
ecology.checktime = 3600
ecology.isgoveproj = 0
LOG_FORMAT = yyyy.MM.dd'-'hh:mm:ss
DEBUG_MODE = false

MainControlIP = 172.16.216.183
ip = 172.16.216.184
broadcast=231.12.21.132
syncType=http
initial_hosts= 172.16.216.184:88,172.16.216.183:88
```

## 3、连接驱动jar包使用mysql-connector-java-5.1.49.jar or 官网

## mysql-cli
**mysql8新建数据库账号user_yyjc,赋予test数据库中edc_uf_table1186_dt1表查询权限,仅IP 192.168.100.11、192.168.100.14可访问**
```bash
#创建账号
CREATE USER 'user_yyjc'@'192.168.100.11' IDENTIFIED BY 'YourStrongPassword123';
CREATE USER 'user_yyjc'@'192.168.100.14' IDENTIFIED BY 'YourStrongPassword123';
#仅授权查询功能
GRANT SELECT ON test.edc_uf_table1186_dt1 TO 'user_yyjc'@'192.168.100.11';
GRANT SELECT ON test.edc_uf_table1186_dt1 TO 'user_yyjc'@'192.168.100.14';
FLUSH PRIVILEGES;

#验证授权
SELECT User, Host FROM mysql.user WHERE User = 'user_yyjc';
SHOW GRANTS FOR 'user_yyjc'@'192.168.100.11';
SHOW GRANTS FOR 'user_yyjc'@'192.168.100.14';
show grants for 'user_yyjc'@'%';
#删除
DROP USER 'user_yyjc'@'192.168.100.11';
DROP USER 'user_yyjc'@'192.168.100.14';
```


