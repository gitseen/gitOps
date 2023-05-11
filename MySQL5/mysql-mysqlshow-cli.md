# mysqlshow命令详解

mysqlshow命令用于显示mysql服务器中数据库、表和列表信息  

mysqlshow [选项] [db_name [tbl_name [col_name] ] ]  

如果没有给出数据库，显示所有匹配的数据库  
如果没有给出表，显示数据库中所有匹配的表  
如果没有给出列，显示表中所有匹配的列和列类型  

## 常用命令
```
mysqlshow  -uroot -pxx                   #显示所有数据库
mysqlshow  -uroot -pxx mysql             #显示mysql库下所有表
mysqlshow  -uroot -pxx mysql user        #显示user表的所有列信息
mysqlshow  -uroot -pxx mysql user HOST   #显示user表Host列信息
mysqlshow  -uroot -pxx --count mysq      #显示表的行数t和列数
mysqlshow  -uroot -pxx --count           #所有
mysqlshow  -uroot -pxx -t mysql          #显示表的类型
mysqlshow  -uroot -pxx -k mysql
mysqlshow  -uroot -pxx -k mysql servers  #显示表索引
mysqlshow  -uroot -pxx -i mysq           #显示额外信息

mysqlshow -uroot -pxx -v
mysqlshow -uroot -pxx -v -v
mysqlshow -uroot -pxx mysql -v
mysqlshow -uroot -pxx mysql -v -v
mysqlshow -uroot -pxx mysql user -v
```



[mysqlshow命令详解-IT干杂铺](https://www.toutiao.com/article/7230091727603008038)
