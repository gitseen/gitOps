# rewrite基本介绍
rewrite是实现URL重写的关键指令,根据regex(正则表达式)部分内容,重定向到replacement,结尾是flag标记。
**基本语法**  
```bash
rewrite 	<regex> 	<replacement> 	[flag];
关键字     正则      替换内容         flag标记
``` 
- regex：正则表达式语句进行规则匹配  
- replacement：将正则匹配的内容替换成replacement  
- flag：last | break | redirect | permanent  
  + last: 本条规则匹配完成后,继续向下匹配新的locationURI规则  
  + break：本条规则匹配完成即终止,不再匹配后面的任何规则  
  + redirect：回302临时重定向,浏览器地址会显示跳转后的URL地址(防爬虫)  
  + permanent: 返回301永久重定向,浏览器地址栏会显示跳转后的URL地址

**rewrite使用位置(作用域)**  
- server: 在server中针对所有的请求  
- location: 在location中则针对单个匹配路径的  
- if  

# server中使用rewrite
>直接在server中使用rewrite,它会被先执行,优先于location中的rewrite 
## rewrite外部站点
>rewrite到外部站点-->是指replacement部分;
是一个完整的带http/https的外部路径,它的特点是浏览器会再次请求这个新的站点;
所以浏览器上的地址一定会发生变化,不受flag参数影响   

**示例**  
<details>
  <summary>rewrite全部拦截^/(.*)$</summary>
  <pre><code>
server {
        listen       80;
        server_name  www.testfront.com;
        #由于是外部站点带http/s的所以不受flag影响break last .. 都会进行跳转并且变更浏览器url
        rewrite ^/(.*)$ https://www.163.com break;

        location / {
            root html;
            index index.html;
        }
}
#所有的请求都转发了https://www.163.com
  </code></pre>
</details>

<details>
  <summary>部分匹配 和 http-->hhtps</summary>
  <pre><code>
server {
        listen       80;
        server_name  www.testfront.com;
        #只有当后缀是 数字.html 的时候才会转发到  https://www.163.com
        rewrite ^/([0-9]+).html$ https://www.163.com break;
        #其他的请求会走到这个location中
        location / {
            root html;
            index index.html;
        }
}
---
server {
        listen       80;
        server_name  www.testfront.com;      
        rewrite ^(.*)$ https://www.163.com permanent;
       
        #location / {
        #    root html;
        #    index index.html;
        #}
}
  </code></pre>
</details>

## rewrite到内部站
>rewrite到内部站点 是指replacement不带http/https而是内部的另外一个路径,相当于访问隐藏起来的这个内部路径;
>>只有这种内部站点跳转的时候,浏览器才有可能不变地址,要看rewite flag参数了last和break都不会变的, 只有redirect和permanent  
 
**示例**  
```bash
server {
        listen       80;
        server_name  www.testfront.com;
        rewrite ^/([0-9]+).html$ /my.gif break; #只有当后缀是 数字.html 的时候才会转发到  www.testfront.com

        #其他的请求会走到这个location中
        location / {
            root html;
            index index.html;
        }
        #上面的rewrite会被路由到这里,并且浏览器是不会感知到的 
        location /my.gif {
            root /www/static/;
        }
}
经过测试 当访问 www.testfront.com/222.html 的时候
flag = last 浏览器不会变化  隐藏了 后端 /my.gif 地址
flag = break 浏览器不会变化 隐藏了 后端 /my.gif 地址
flag = redirect和permanent 浏览器变化了URL 变更状态码302和301
```
# location中使用rewrite
>location中也可以使用rewrite,意思是只有匹配到这个location后才经过rewrite的正则通过后再跳转
 >>和上面一样,也分为rewirte的replacement是否包含http和https外部站点  
**示例**  
```bash
#希望是如果 访问的后缀 是 数字.html 则返回 my.gif 图 ,其他的都代理到 http://www.testbackend.com
server {
        listen       80;
        server_name  www.testfront.com;
        #rewrite ^/([0-9]+).html$ /my.gif last;

        location /my.gif {
	   			root /www/static/;
				}

        location / {
            rewrite ^/([0-9]+).html$ /my.gif break;
            proxy_pass http://www.testbackend.com;
        }
 }
经过测试 只有访问www.testfront.com/数字.html 的时候 才能获取到 my.gif 文件
```
# 使用场景模拟
## 基于域名跳转
>网站域名是www.testfront.com现在需要使用新的域名www.newtestfront.com替代;
 但是旧的域名不能作废, 需要让旧的域名跳转到新的域名上, 并且保持后面参数不变  
**示例** 
```bash
#模拟原本配置
server {
        listen       80;
        server_name  www.testfront.com;
        
        location / { 
            proxy_pass http://www.testbackend.com;
        }
 }

#新配置,使用rewrite操作 当访问老的域名www.testfront.com 跳转到 新的www.newtestfront.com
   server {
        listen       80;
        server_name  www.testfront.com ...;

        location / {
            # $host 是可以拿到访问的主机名
            if ( $host = 'www.testfront.com' ) {

                rewrite ^/(.*)$ http://www.newtestfront.com/$1 permanent;
            }

            proxy_pass http://www.testbackend.com;
        }

       location ^~ /static/ {
	    		root  /www/static;
			 }
    }

    server {
        listen       80;
        server_name  www.newtestfront.com;

        location / {
           # 这里可以改成 新域名的 新后端代理的服务, 依据实际情况
           proxy_pass http://www.testbackend.com;
        }

        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   html;
        }
   }
``` 
## 基于客户端IP访问跳转
>业务新版本上线,要求所有IP访问任何内容都显示一个固定维护页面,只有公司IP:192.168.200.100访问正常  

```bash
   server {
        listen       80;
        server_name  www.testfront.com ...;
        
        #先设置rewrite变量为true
        set $rewrite true;
         
        # 当客户端ip 是172.16.225.1 的时候 才不 rewrite
        if ( $remote_addr = "172.16.225.1" ) {
           set $rewrite = false;
        }
        
        if ( $rewirte = true) {
           # 将rewrite到 维护界面 weihu.html
           rewrite (.+) /weihu.html; 
        }
        
        location /weihu.html {
           # 如果要使用 echo 则需要加载 echo-nginx-module 才行
        	 echo "remote_addr: $remote_addr";
           root /www/weihu/;
        }

        location / {
         		# 如果要使用 echo 则需要加载 echo-nginx-module 才行
        		echo "remote_addr: $remote_addr";
            # 如果是 remote_addr 是特定的ip 则直接正常访问后台
            proxy_pass http://www.testbackend.com;
        }
    }
此时如果是172.16.225.1 访问就可以到 后端, 如果是其他的客户端ip 访问就只能到 weihu.html 页面
curl localhost
curl www.testfront.com
```
>注意echo-nginx-module模块需要单独下载加载]
 git clone https://gitee.com/yaowenqiang/echo-nginx-module.git  


# rewrite总结
rewrite基本概念,以及基本的使用方式,rewrite作用域(server、location、if)和,模拟场景  
- rewirte内部站点    
  当rewrite到内部站点的时候&ensp;会根据flag参数&ensp; last和break不变&ensp;redirect和permanent变  
- rewrite外部站点带http/https等  
  当rewrite外部站点&ensp;不管flag参数&ensp;浏览器URL都会进行变化 &ensp; 相当于浏览器进行了二次请求 
