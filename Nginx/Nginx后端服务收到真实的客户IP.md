# 背景
开发有一个服务部署在阿里云上，依赖阿里云的CLB（传统型负载均衡）暴露服务，因特殊要求，CLB和后端服务之间需要通过自建Nginx做代理，拓扑图如下  
![IMG](https://p3-sign.toutiaoimg.com/tos-cn-i-qvj2lq49k0/937315be92234b6c82e3f8dafd706e78~noop.image?_iz=58558&from=article.pc_detail&x-expires=1676452383&x-signature=5lpRqlMdmcKvG8d4THmWtiV%2FE64%3D)  
# 操作
客户端的请求经过了两层代理，这里CLB和Nginx都要做配置。  

## 1、配置CLB  
CLB的配置比较简单，在配置监听时，要附加X-Forwarded-ForHTTP头字段  
![附加X-Forwarded-For HTTP头字段](https://p3-sign.toutiaoimg.com/tos-cn-i-qvj2lq49k0/4e90c194504548049a3a352458b56026~noop.image?_iz=58558&from=article.pc_detail&x-expires=1676452383&x-signature=osNLeAqPOHxDgRBz2qJXk8sgpfg%3D) 
大多数情况下，并没有CLB这层代理，但加入这层后，我们对后面知识的理解将更加透彻。

## 2、Nginx配置
直接上配置文件
```
server {
        listen 80;
        server_name www.example.com;
        set_real_ip_from 100.64.0.0/10;
        real_ip_header X-Forwarded-For;
        access_log /data/logs/nginx/access.log;
        error_log  /data/logs/nginx/error.log;

        location / {
            proxy_pass http://10.x.x.x:12345;  //后端服务地址
            proxy_set_header Host      $host;
            proxy_set_header X-REAL-IP $remote_addr;
            allow 120.79.x.x/32;    //对外服务，做好限制
            deny all;
            }
}
```
实现将客户端的真实IP传递给后端服务，依赖这三行  
```
set_real_ip_from 100.64.0.0/10;
real_ip_header X-Forwarded-For;
proxy_set_header X-REAL-IP $remote_addr;
```
# 知识
因为有阿里CLB和Nginx两层代理，需要用set_real_ip_from来辅助取得客户的真实IP，该选项后面的IP是第一层代理即CLB的IP，可以从Nginx访问日志中得到（在未配置选项set_real_ip_from的情况下），下图中第一列就是CLB的IP，因为阿里云CLB的IP随时变动，配置中用了IP段的方式。  
![logs](https://p3-sign.toutiaoimg.com/tos-cn-i-qvj2lq49k0/b6977e4d536c493289d42eb934f28ea2~noop.image?_iz=58558&from=article.pc_detail&x-expires=1676452383&x-signature=xc1vBIuQ21rLGv8N%2B4eiug7aP5A%3D)  

real_ip_header X-Forwarded-For，含义是使用HTTP头部域X-Forwarded-For的值作为客户端的IP，如果没有配置选项set_real_ip_from，该值将是CLB的IP。  

proxy_set_header X-REAL-IP $remote_addr，Nginx设置发送到后端服务的HTTP请求头X-REAL-IP，值为变量remote_addr的值，即客户端的真实IP。  

最后说明一下，HTTP请求头X-Forwarded-For的格式如下：
```
X-Forwarded-For: <client>, <proxy1>, <proxy2>
```
最左边的值是客户端的IP，后面的值是代理服务器的IP，时间顺序上，最右边的代理IP是最后访问的代理。这也就是为什么我们要加入选项set_real_ip_from的原因。  



