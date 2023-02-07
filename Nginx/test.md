# Nginx核心配置Core




from https://www.toutiao.com/article/7180186438662144570/ 

关于老板让我用Openresty实现的各种奇怪需求以及实现
2022-12-23 11:55·互联网高级架构师
本文主要介绍最近整理的用Openresty处理的一些需求或功能，当然这都是领导时不时给我提出来需求，有些需求个人感觉还是怪怪的，不过领导的话不能不听不是？

关于Openresty网上有很多介绍，他的普通用法和Nginx几乎一样没什么特别的。高级功能的话，Openresty比Nginx支持更多的模块，还支持Lua、JavaScript作为脚本语言实现更高级的功能。

需求一、URL重写
这个需求还算比较常见，就是把一个url转换成另一种形式，举个例子：

领导：你来把
https://www.example.com/article/xxxxx这个url给我转后端的https://www.example.com/api/article/xxxxx一个接口上。

我：为啥不直接请求后端接口？

领导：/api/一看就是后端接口，要让用户看起来像是直接访问一个页面。

这个小需求可以直接用rewrite实现，先看下rewrite的用法：

rewrite

用法：

rewrite regex replacement [last|break|redirect|permanent];

位置：server、location、if
其中最后一个参数：

last: 表示在匹配完本条规则后还会继续向下找其他location；
break:表示匹配完本条规则后就直接返回；
redirect:会返回302临时重定向，地址栏的地址会发生变化，爬虫不会更新url。
permanent:会返回301永久重定向，地址栏的地址会发生变化，爬虫会更新url。
需求实现

我只要拿到uri，因为前缀是一样的，所以只需要把uri后面的xxxxx解析出来就好了，rewrite之后，直接break。直接在server块里加上下面这块代码，轻轻松松实现。

if ($uri ~* "^/article/(.*)") {
  rewrite ^/article/(.*) /api/article/$1 break;
}
需求二、URL重写+参数名转换
这个需求，跟上一个基本类型，只是多了一个参数转变的过程。

领导：你来把
https://www.example.com/article/xxxxx?id=yyyyy这个url给我转后端的https://www.example.com/api/article/xxxxx一个接口上，然后把id这个参数给我变成articleId。

我：直接用articleId不行吗？

领导：不行。

好吧，继续干活，这个需求可以分为两步，第一步把url用rewrite重写和上面的一样，第二步把参数换一个名字。

参数获取

在nginx中可以使用$arg_XXX来获取请求的参数，例如https://www.example.com/article/xxxxx?id=yyyyy这个请求，在nginx中可以直接使用$arg_id获取id这个参数。

需求实现

知道怎么拿到参数后，实现就简单了，在第一示例的代码基础上改改就可以了。

if ($uri ~* "^/article/(.*)") {
  rewrite ^/article/(.*) /api/article/$1?articleId=$arg_id break;
}
需求三、域名过滤
这个需求是说，服务器接收好多请求，这些请求有不同的域名，要过滤需要的域名请求。

领导：咱们目前的服务器是别的组不用的，现在还有其他域名请求会进来，你判断下如果是咱们的域名就继续执行，如果不是咱们的，直接返回404。

我：哦。

if AND OR 判断

这个需求理解是如果是A域名或者是B域名，请求继续，如果都不是则返回404，但nginx虽然支持if判断，但是并不支持AND、 OR这样的操作，只能换一种方式实现。

实现思路为：我设置一个字符串，如果不是A域名我追加一个字符，如果不是B域名我再追加一个字符，如果这个字符串为等于一个值那么就返回404。

需求实现

刚才已经分析完了，直接上代码吧，在server块里，加上下面这个代码即可。

server {
    listen 80;
    server_name _;
    set $flag "n";
    if ($host != 'a.example.com'){
        set $flag "${flag}o";
    }
    if ($host != 'b.example.com'){
        set $flag "${flag}t";
    }
    if ($flag = "not"){
        return 404;
    }
    location / {
        ...
    }
}
需求四、配置CORS指定Origin
这个需求是跨域设置，不能设置为*，只允许特定的域名请求，添加信任域名。

领导：给咱们网站接口设置下允许哪些域名可以访问。

我：你后端不能做吗？

领导：后端还不得写代码吗。

我：。。。。。。

map指令

用法：

map string $variable {...}

位置：http
这个map的含义简单理解为，map匹配一个字符串作为key，按照映射关系把value的值赋值给$variable这个变量。

需求实现

既然不能用*设置允许所有跨域访问，只能定义一个白名单了，最终实现如下：

map $http_origin $allow_origin {
    ~https://a.example.com https://a.example.com;
    ~https://b.example.com   https://b.example.com;
    default               deny;
}
server {
    listen 80;
    server_name *.example.com;

    location / {
        add_header Access-Control-Allow-Origin $allow_origin;
        add_header Access-Control-Allow-Credentials true;
        ...
    }
}
需求五、参数值转换
这天领导又给我来了个震惊我的需求：把一个请求的参数值按照一定的规则动态换成数据库里的另一个值。

领导：你看这个url，
https://www.example.com/api/user/info?openId=xxxx,在Openresty中把这个openId给我换成数据库里的主键id，然后用id参数传给我，就是变为https://www.example.com/api/user/info?id=yyyy。

我：你没开玩笑？

领导：我像在开玩笑吗?下午给我。

解决思路

既然没开玩笑，那就想办法呗。用Openresty连数据库？额，不太好。

从官网找了找，也没有找到好办法，那只能写个脚本了。

先判断是这个url，先内部发送个请求根据openId查询对应id，再把id拼接到url继续处理后续逻辑。

需求实现

先写个lua脚本，从脚本中根据openId查询出对应id是多少，然后再把id参数拼接上，重新请求接口。

相当于中间经过了一层中转，因为是服务内部请求，所以性能影响不是很大，来看下代码实现。

lua脚本 user_api.lua

-- 判断标识，防止死循环
if ngx.var.arg_internal == 'internal' then 
    return
end
local open_id = ngx.var.arg_openId
if open_id == nil then
    local result = '{"success": false,"code": 1001,"msg":"用户不存在"}'
    ngx.status = ngx.HTTP_OK
    ngx.say(result)
    ngx.exit(ngx.HTTP_OK)
end
-- 根据openId查询
local resp = ngx.location.capture("/api/third/user/info?openId=" .. open_id, {
        method = ngx.HTTP_GET,
        keepalive_timeout = 60,
        keepalive_pool = 100
    })
if not resp or 200 ~= resp.status then
    local result = '{"success": false,"code": 1002,"msg":"请求失败"}'
    ngx.status = ngx.HTTP_OK
    ngx.say(result)
    ngx.exit(ngx.HTTP_OK)
end

local cjson = require "cjson"
local user = cjson.decode(resp.body).data
local id = user.id
-- 重新请求，加上内部请求标识
return ngx.exec('/api/user/info?internal=internal&id=' .. id)
openresty配置如下，需要加上access_by_lua_file，对应的值为lua脚本的路径。

location /api/user {
        proxy_pass http://user_upstream;
        proxy_pass_header Date;
        proxy_pass_header Server;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        access_by_lua_file /usr/local/openresty/lua_lib/user_api.lua;
}
后记
这些都是领导提出的一些需求，你以为就这些吗？不不不，这只是冰山一角，后续会再介绍其他需求，以及解决方案。

作者：JavaCub
链接：
https://juejin.cn/post/7179824911999844413
来源：稀土掘金

  


