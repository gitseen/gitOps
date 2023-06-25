**[Nginx官方文档](http://nginx.org/en/docs/)**
# Nginx 概述
Nginx是一个高性能HTTP和反向代理服务器、IMAP、POP3、SMTP服务器  
Nginx是开源、高性能、高可靠的Web和反向代理服务器,而且支持热部署,几乎可以做到7 * 24小时不间断运行,即使运行几个月也不需要重新启动,还能在不间断服务的情况下对软件版本进行热更新。性能是 Nginx最重要的考量,其占用内存少、并发能力强、能支持高达5w个并发连接数,最重要的是,Nginx是免费的并可以商业化,配置使用也比较简单。    

# Nginx特点  
1、高并发、高性能  
2、模块化架构使得它的扩展性非常好  
3、异步非阻塞的事件驱动模型这点和 Node.js 相似  
4、相对于其它服务器来说它可以连续几个月甚至更长而不需要重启服务器使得它具有高可靠性  
5、热部署、平滑升级  
6、完全开源,生态繁荣  

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
Nginx是由一个master管理进程,多个worker进程处理工作的多进程模型。基础架构设计如下
![如下图所示](https://p3-sign.toutiaoimg.com/pgc-image/53619e18837c4c5fb96e9314dcae038b~noop.image?_iz=58558&from=article.pc_detail&x-expires=1674528628&x-signature=Ds4VpyEHj1R2LpX2Ct14PKVfcPw%3D)  
![2](https://image.z.itpub.net/zitpub.net/JPG/2021-06-15/E2BB82F07925A570101FDC4A9694062D.jpg)  
Master负责管理worker进程,worker进程负责处理网络事件。整个框架被设计为一种依赖事件驱动、异步、非阻塞的模式。  
优点：  
1、可以充分利用多核机器,增强并发处理能力。  
2、多worker间可以实现负载均衡。  
3、Master监控并统一管理worker行为。在worker异常后,可以主动拉起worker进程,从而提升了系统的可靠性。并且由Master进程控制服务运行中的程序升级、配置项修改等操作,从而增强了整体的动态可扩展与热更的能力。    

# [Nginx原理](https://www.cnblogs.com/xiangsikai/p/8438772.html)
 $\color{red}{Nginx由Nginx内核和模块组成,其中内核的设计非常微小和简洁,完成的工作也非常简单}$
 $\color{red}{当它接到一个HTTP请求时,它仅仅是通过查找配置文件将此次请求映射到一个location block,而此location中所配置的各个指令则会启动不同的模块去完成工作,}$
 $\color{red}{因此模块可以看做Nginx真正的劳动工作者。通常一个location中的指令会涉及一个handler模块和多个filter模块（当然,多个location可以复用同一个模块）。}$
 $\color{red}{handler模块负责处理请求,完成响应内容的生成,而filter模块对响应内容进行处理。}$  

用户根据自己的需要开发的模块都属于第三方模块。正是有了这么多模块的支撑,Nginx的功能才会如此强大。

Nginx的模块从结构上分为核心模块、基础模块和第三方模块   
  - 核心模块：HTTP模块、EVENT模块和MAIL模块
  - 基础模块：HTTP Access模块、HTTP FastCGI模块、HTTP Proxy模块和HTTP Rewrite模块
  - 第三方模块：HTTP Upstream Request Hash模块、Notice模块和HTTP Access Key模块  
  
Nginx的模块从功能上分为如下三类  
  - Handlers（处理器模块）。此类模块直接处理请求,并进行输出内容和修改headers信息等操作。Handlers处理器模块一般只能有一个
  - Filters （过滤器模块）。此类模块主要对其他处理器模块输出的内容进行修改操作,最后由Nginx输出
  - Proxies （代理类模块）。此类模块是Nginx的HTTP Upstream之类的模块,这些模块主要与后端一些服务比如FastCGI等进行交互,实现服务代理和负载均衡等功能  
 

# 负载均衡方式
  **当一台服务器的单位时间内的访问量越大时,服务器压力就越大,大到超过自身承受能力时,服务器就会崩溃。为了避免服务器崩溃,让用户有更好的体验,我们通过负载均衡的方式来分担服务器压力**  
  **负载均衡策略**  
|  负载类型   | 负载类型解释  |
|  ----  | ----  |
| 轮询RR   | 默认方式  |
| weight  | 权重方式 |
| ip_hash  | 依据ip分配方式 |
| least_conn  | 最少连接方式 |
| fair(第三方)  | 响应时间方式 |
| url_hash(第三方)  | 依据URL分配方式 |  

  ## RR（默认）
  $\color{green}{每个请求按时间顺序逐一分配到不同的后端服务器,如果后端服务器down掉,能自动剔除}$
   ```bash
     upstream backserver {
     server 192.168.0.14;
     server 192.168.0.15;
     }
  ```
    
   ## 权重
   $\color{green}{指定轮询几率,weight和访问比率成正比,用于后端服务器性能不均的情况;权重值越大,服务器越容易被访问,因此,性能好的服务器应适当加大权重值}$  
   ```bash
      upstream backserver {
      server 192.168.0.14 weight=10;
      server 192.168.0.15 weight=11;
      }
   ```
   ## ip_hash
   指定负载均衡器按照基于客户端IP的分配方式,这个方法确保了相同的客户端的请求一直发送到相同的服务器,以保证session会话。这样每个访客都固定访问一个后端服务器,可以解决session不能跨服务器的问题。  
   ```bash
      upstream backserver {
      ip_hash;
      server 192.168.0.14:88;
      server 192.168.0.15:80;
     }
   ```
   ## [least_conn](https://www.toutiao.com/article/7246780199151862312)
   把请求转发给连接数较少的后端服务器。轮询算法是把请求平均的转发给各个后端,使它们的负载大致相同；但是,有些请求占用的时间很长,会导致其所在的后端负载较高。这种情况下,least_conn这种方式就可以达到更好的负载均衡效果。  
   ```bash
      upstream backserver {
      least_conn;
      server 192.168.0.14:88;
      server 192.168.0.15:80;
      }
   ```
   ## fair(第三方)
   按后端服务器的响应时间来分配请求,响应时间短的优先分配。  
   ```bash
      upstream backserver {
      server server1;
      server server2;
      fair; #实现响应时间短的优先分配
      }
   ```
   ## url_hash(第三方)
   按访问url的hash结果来分配请求,使每个url定向到同一个后端服务器,后端服务器为缓存时比较有效。 在upstream中加入hash语句,server语句中不能写入weight等其他的参数,hash_method是使用的hash算法  
   ```bash
      upstream backserver {
      server squid1:3128;
      server squid2:3128;
      hash $request_uri;#实现每个url定向到同一个后端服务器
      hash_method crc32;
     }
     upstream backend{
     least_conn;
     server 192.168.200.146:9001;
     server 192.168.200.146:9002;
     server 192.168.200.146:9003;
     }
     server {
     listen 8083;
     server_name localhost;
     location /{
        proxy_pass http://backend;
    }
    }
   ```
   ## [nginx 负载均衡示例](https://www.toutiao.com/article/7195169258300342842/)  
   
　****以上便是6种负载均衡策略的实现方式,其中除了轮询和轮询权重外,都是Nginx根据不同的算法实现的。在实际运用中,需要根据不同的场景选择性运用,大都是多种策略结合使用以达到实际需求****   
 ## nginx拉黑IP
 在Nginx中,你可以使用deny指令和allow指令来拉黑（或允许）特定的IP地址。这些指令位于Nginx的server块内
 ```
    server {
      listen 80;
      server_name example.com;
      location / {
          deny 192.168.1.1;
          allow 192.168.0.0/16;
          # deny all;
          proxy_pass http://backend;
      }
   }
 ```
 
[Nginx访问如何分流常见情景](https://github.com/gitseen/gitOps/blob/main/Nginx/Nginx%E8%AE%BF%E9%97%AE%E5%A6%82%E4%BD%95%E5%88%86%E6%B5%81%E5%B8%B8%E8%A7%81%E6%83%85%E6%99%AF)  

# Nginx跨域配置
同源策略主要是指三点相同(协议+域名+端口)相同的两个请求,则可以被看做是同源的,但如果其中任意一点存在不同,则代表是两个不同源的请求,同源策略会限制了不同源之间的资源交互
```

cation / {  
    # 允许跨域的请求,可以自定义变量$http_origin,*表示所有  
    add_header 'Access-Control-Allow-Origin' *;  

    # 允许携带cookie请求  
    add_header 'Access-Control-Allow-Credentials' 'true';  

    # 允许跨域请求的方法：GET,POST,OPTIONS,PUT  
    add_header 'Access-Control-Allow-Methods' 'GET,POST,OPTIONS,PUT';  

    # 允许请求时携带的头部信息,*表示所有  
    add_header 'Access-Control-Allow-Headers' *;  

    # 允许发送按段获取资源的请求  
    add_header 'Access-Control-Expose-Headers' 'Content-Length,Content-Range';  

    # 一定要有！！！否则Post请求无法进行跨域！  
    # 在发送Post跨域请求前,会以Options方式发送预检请求,服务器接受时才会正式请求  
    if ($request_method = 'OPTIONS') {  
        add_header 'Access-Control-Max-Age' 1728000;  
        add_header 'Content-Type' 'text/plain; charset=utf-8';  
        add_header 'Content-Length' 0;  
        # 对于Options方式的请求返回204,表示接受跨域请求  
        return 204;  
    }  
}  
```

# Nginx防盗链
盗链即是指外部网站引入当前网站的资源对外展示  

Nginx的防盗链机制实现,跟一个头部字段：Referer有关,该字段主要描述了当前请求是从哪儿发出的,那么在Nginx中就可获取该值,然后判断是否为本站的资源引用请求,如果不是则不允许访问。语法如下：
```
valid_referers none | blocked | server_names | string ...;
```
- none：表示接受没有Referer字段的HTTP请求访问。
- blocked：表示允许http://或https//以外的请求访问。
- server_names：资源的白名单,这里可以指定允许访问的域名。
- string：可自定义字符串,支配通配符、正则表达式写法。
```
# 在动静分离的location中开启防盗链机制  
location ~ .*\.(html|htm|gif|jpg|jpeg|bmp|png|ico|txt|js|css){  
    # 最后面的值在上线前可配置为允许的域名地址  
    valid_referers blocked 192.168.12.129;  
    if ($invalid_referer) {  
        # 可以配置成返回一张禁止盗取的图片  
        # rewrite   ^/ http://xx.xx.com/NO.jpg;  
        # 也可直接返回403  
        return   403;  
    }        
    root   /soft/nginx/static_resources;  
    expires 7d;  
} 
```
对于防盗链机制实现这块,也有专门的第三方模块ngx_http_accesskey_module实现了更为完善的设计  


# Nginx动静分离
动静分离应该是听的次数较多的性能优化方案,那先思考一个问题：为什么需要做动静分离呢？它带来的好处是什么？  
其实这个问题也并不难回答,当你搞懂了网站的本质后,自然就理解了动静分离的重要性  
```
location ~ .*\.(html|htm|gif|jpg|jpeg|bmp|png|ico|txt|js|css){ 
    root /mnt/static_resources; 
    expires 7d; 
}
~代表匹配时区分大小写
.*代表任意字符都可以出现零次或多次,即资源名不限制
\.代表匹配后缀分隔符.
(html|...|css)代表匹配括号里所有静态资源类型
```


# Nginx设置密码认证
安装Apache2-utils软件包：该软件包提供了htpasswd工具,用于管理用户的证书。你可以通过运行以下命令将其安装到你的系统中  
```
apt-get install apache2-utils || yum -y install httpd
sudo htpasswd -c /etc/nginx/.htpasswd username
nginx-conf-ADD
auth_basic "Restricted Content";
auth_basic_user_file /etc/nginx/.htpasswd;
eg:
server {
      listen 80 default_server;
      listen [::]:80 default_server ipv6only=on;
  
      root /usr/share/nginx/html;
      index index.html index.htm;
  
      server_name localhost;
  
      location / {
                try_files $uri $uri/ =404; #location/表示处理根目录请求,try_files uriuri/ =404表示如果请求的页面存在,则返回该页面,否则返回404页面
                auth_basic "Restricted Content";
                auth_basic_user_file /etc/nginx/.htpasswd;
      }
}
这将要求对该地点进行认证,并使用.htpasswd文件对用户进行认证
nginx -s reload

```

# Nginx-rewrite
Nginx是一种高性能的Web服务器和反向代理服务,它可以通过rewrite模块来实现URL重写和重定向等功能  
常用的rewrite方法和技巧,以及它们的优缺点   
## 1、使用正则表达式匹配URL
使用正则表达式来匹配URL是最常见的rewrite技巧之一。例如,以下规则可以将所有以/test/开头的URL重写到/test.php文件中   
```
rewrite ^/test/(.*)$ /test.php?param=$1 last;
```
优点：可以通过复杂的正则表达式来实现灵活的URL重写规则  

缺点：需要熟悉正则表达式语法,并且在处理大量请求时可能会影响性能  

## 2、使用map模块来匹配URL：
map模块可以将一个字符串映射到另一个字符串,它可以用来实现URL的重写和重定向。例如,以下规则可以将所有以/hello开头的URL重定向到/welcome页面
```
map $uri $new_uri {
    /hello   /welcome;
}

server {
    ...
    rewrite ^ $new_uri permanent;
    ...
}
``` 
优点：可以将映射规则定义在单独的文件中,方便管理和修改   

缺点：不如正则表达式灵活,只能处理简单的URL重定向和重写   

## 3、使用if语句来匹配URL：
if语句可以根据请求的特定属性来判断是否需要进行URL重写或重定向。例如,以下规则可以将所有以http://example.com旧域名开头的URL重定向到https://example.com新域名  
```
if ($http_host ~* "^example\.com$") {
    rewrite ^(.*)$ https://example.com$1 permanent;
}
```
优点：可以根据请求的属性灵活判断是否需要进行URL重写或重定向  

缺点：if语句可能会影响性能,并且容易出现错误或歧义,需要谨慎使用  

## 4、使用proxy_pass重定向URL
proxy_pass指令可以将请求重定向到另一个URL地址,例如：  
```
location /old/ {
    proxy_pass http://new.example.com/;
}
```
优点：可以快速简便地实现URL重定向  

缺点：不能进行URL重写,只能进行重定向。此外,需要注意代理的性能问题   

**Rewrite模块可以实现URL重写和重定向等功能,可以根据需要选择不同的rewrite方法和技巧。需要注意的是,rewrite规则的性能和正确性都非常重要,必须进行适当的测试和验证**  

5、nginx维护页面处理
nginx维护页面处理-全部URL指向同一个页面  

一般来说nginx的维护页面需要把所有访问本站的链接全部重定向到某个指定页面  
```
5.1 添加伪静态rewrite
rewrite ^(.*)$ /lengxi.html break;
注意这句后面如果有重定向等语句,那么后面执行的重定向等语句需要全部注释掉

5.2 使用状态码
location /{
return 503;
}
#注意其他location优先级高的匹配均需要注释掉
error_page 503 /lengxi.html;

每当服务器遇到 502 代码时,就自动转到临时维护的静态页：
server {
listen 80;
server_name mydomain.com;
# ... 省略掉 N 行代码
error_page 502 = @tempdown;
location @tempdown {
rewrite ^(.*)$ /pages/maintain.html break;
}
}

如果你只想要【临时维护页面】就这样写（适合服务器更新东西或者改版）：
server {
listen 80;
server_name mydomain.com;
# ... 省略掉 N 行代码
# 所有页面都转跳到维护页
rewrite ^(.*)$ /pages/maintain.html break;
}
注：
临时维护页要找对正确的路径
```

# Nginx模块详解
[Nginx模块详解](https://cloud.tencent.com/developer/article/2057869)  
https://www.toutiao.com/article/6679950432736903694/?channel=&source=search_tab  

# nginx for k8s
[nginx for k8s](https://jamesdefabia.github.io/docs/user-guide/kubectl/kubectl_run/)  
[nginx for run pod](https://dockerlabs.collabnix.com/kubernetes/beginners/workshop/lab00-running-nginx-pod/)    

# 参考来源
[万字总结体系化带你全面认识 Nginx](https://juejin.cn/post/6942607113118023710)  
[Nginx架构](https://www.cnblogs.com/ludongguoa/p/15316464.html)  
[负载均衡](https://www.cnblogs.com/1214804270hacker/p/9325150.html)
