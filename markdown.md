[toc]
[Markdown 官方教程](https://markdown.com.cn/) 
[Markdown 语法速查表](https://markdown.com.cn/cheat-sheet.html#%E6%80%BB%E8%A7%88)
[Markdown 基本语法](https://markdown.com.cn/basic-syntax/)
[Markdown 基本语法](https://markdown.com.cn/extended-syntax/)
[撰写新主题](https://kubernetes.io/zh-cn/docs/contribute/style/write-new-topic/)   
[样式指南](https://kubernetes.io/zh-cn/docs/contribute/style/style-guide/)  



# 分隔线

---  
***  
___

# 文本居中显示

<center>我是不是居中</center>

**<center>我是不是居中</center>**

# 标题居中

<h1 align = "center">h1居中
<h2 align = "center">h2居中
<h2 align = "center" > h2居中 </h2>

# 标题左右显示

<h1 align = "left" > left标题  
<h1 align = "right" > right标题

# 空行/换行

- 使用html语言换行标签\<br/>  <br/>
- 连续两个以上空格+回车
  begin
  <br/>
  end

begin

end

# 文字中空格/特殊字符/文字颜色

[字体颜色](https://www.dengtar.com/15539.html)
&#160; 半角的空格 &ensp; 或 &#8194; 全角的空格 &emsp; 或 &#8195;

&#10004;&#10006;&#10004;&#10006;&#10006;
&#10084;&#10052;&#10003;&#9835;&#9728;&#9733;
&#9730;&#9775;&#9762;&#9742;&#9734;&#9733;&#9733;
\\;\*;\_;\{\};\[\];\+;

写法: $\color{red}{red}$
写法: $\color{green}{green}$
写法: $\color{blue}{blue}$
写法: $\color{#376956}{cyan-blue}$
写法: $\color{#4285f4}{更}\color{#ea4335}{丰}\color{#fbbc05}{富}\color{#4285f4}{的}\color{#34a853}{颜}\color{#ea4335}{色}$
写法: $\color{#4285f4}{G}\color{#ea4335}{o}\color{#fbbc05}{o}\color{#4285f4}{g}\color{#34a853}{l}\color{#ea4335}{e}$

**html标签实现颜色大小字体**
<font size="1">size1</font>
<font size="2">size2</font>
<font size="3">size3</font>
<font size="4">size4</font>
<font size="5">size5</font>
<font size="6">size6</font>

<font face="新宋体">我是新宋体</font>
<font face="楷体">我是楷体</font>
<font face="fantasy">我是fantasy</font>
<font face="Helvteica">我是Helvteica</font>

<font color=#FF0000>红色：#FF0000 </font>
<font color=red>红色：</font>

<font color=#FF0000 size=3 face="Arial">红色，字体：Arial，大小：3号</font>

<table><tr><td bgcolor=F4A460>背景色是：F4A460</td></tr></table> 
<table><tr><td bgcolor=FF6347>背景色是：FF6347</td></tr></table> 
<table><tr><td bgcolor=D8BFD8>背景色是：D8BFD8</td></tr></table> 
<table><tr><td bgcolor=008080>背景色是：008080</td></tr></table> 
<table><tr><td bgcolor=FFD700>背景色是：FFD700</td></tr></table>

<table><tr><td bgcolor=orange>背景色是：orange</td></tr></table> 
<table><tr><td bgcolor=red>背景色是：red</td></tr></table> 
<table><tr><td bgcolor=green>背景色是：green</td></tr></table>



使用<kbd>Ctrl</kbd>+<kbd>Alt</kbd>+<kbd>Del</kbd>重启电脑

***emoji表情符号***
������ ������
:broken_heart:

# 无序列表

+ +空格

- -空格

* *空格

# 一些字体变化的收集

- 粗体 **变粗**
- 斜体 *变斜*
- 粗斜 ***AAA***
- 删除线 ~~删除线~~
- 下划线 <u>下划线</u>

# 计划安排打钩

- [X] deploy-harbor
- [ ] deploy-k8s
  - [X] init-install
  - [X] init-cluster
  - [ ] CRI-ing
- [ ] deploy-redis
- [ ] deploy-kafka

# 引用单行多行

> AAA

> AAA
>
>> AAAA
>>
>>> AAAA
>>>
>>

> AAA
>
> BBB

>>> 1
>>> 2
>>> 3
>>>
>>

> 这是第一层引用。
>>
>> 这是第二层引用。

> - 这是引用中的列表项
> - 这是另一个列表项
>
> [这是引用中的链接](#)



**引用单个多个字符**
请打开`linux.sh`文件

# 链接

- 本图片     ![xx](/1.png)
- 线上图     ![xx](http://1.1.1.1/1.png)
- 自动连接   [https://sports.qq.com/nba](https://sports.qq.com/nba)
- 变量图片
  这个链接用 1 作为网址变量 [RUNOOB][2] . 然后在文档结尾变量赋值(url)
<img src="http://www.txrjy.com/static/image/common/logo.gif" width=20%/>


# 表格-代码块里面包含html代码
<table>
  <tr>
    <th rowspan="2">值班人员</th>
    <th>星期一</th>
    <th>星期二</th>
    <th>星期三</th>
  </tr>
  <tr>
    <td>KEY</td>
    <td>TOM</td>
    <td>FAN</td>
  </tr>
</table>


| 服务    | 用户 |      IP      | 账号  | code      | url                       |
| :-------- | -----: | :-------------: | :------ | :---------- | :-------------------------- |
| jenkins | kins | 10.114.233.45 | admin | N2etBvJqC | http://10.114.233.45:8080 |


| 姓名  | 姓别 | 分数 |
| ------- | ------ | ------ |
| Tom   | 男   | 66   |
| Key   | 女   | 77   |
| Alter | 女   | 88   |


{{< table caption="配置参数" >}}
参数      | 描述        | 默认值
:---------|:------------|:-------
`timeout` | 请求的超时时长 | `30s`
`logLevel` | 日志输出的级别 | `INFO`
{{< /table >}}  


{{< tabs name="tab_with_file_include" >}}
{{< tab name="Content File #1" include="example1" />}}
{{< tab name="Content File #2" include="example2" />}}
{{< tab name="JSON File" include="podtemplate" />}}
{{< /tabs >}}




# 使用LaTex数学公式

- 1.行内公式
  使用两个"\$"符号引用公式:  $公式$
- 2.行间公式
  使用两对"\$\$"符号引用公式：

  $$
  公式

  $$

  $\sqrt{x^{2}}$

# 隐藏细节

<details>
  <summary>seq</summary>
  <pre><code>
  #!/bin/bash
  echo "fast..."
  log "OK"
  </code></pre>
</details>

# 可视化差异

```diff
  function addTwoNumbers (num1, num2) {
-  return 1 + 2
+  return num1 + num2
}
```

# 注脚

使用Markdown[^1]书写文档,直接转换HTML[^2]

---

---

---

# [mermaid流程图](https://www.jianshu.com/p/ca9a14b69938)
[mermaid官方文档](http://mermaid.js.org/intro/)  

[Typora-MarkDown](https://support.typora.io/Draw-Diagrams-With-Markdown/)
[横向图与纵向图](http://mermaid.js.org/intro/getting-started.html)
[官方网站](http://mermaid.js.org/#/)
[参考](https://unbroken.blog.csdn.net/?type=blog)

```bash
Mermaid是一种简单的类似Markdown的脚本语言，通过 JavaScript 编程语言，将文本转换为图片
Mermaid是一个用于画流程图、状态图、时序图、甘特图的库，使用JS进行本地渲染，广泛集成于许多Markdown编辑器中
Mermaid 支持绘制非常多种类的图，常见的有时序图、流程图、类图、甘特图等等。

TB/TD(top bottom/top down)表示从上到下
BT(bottom top)表示从下到上
RL(right left)表示从右到左
LR(left right)表示从左到右

LR即left to right，描述流程图展开方向
A、B、C 是某图形的ID
[] () {} 描述图形的形状，依次是 方角框，圆角框，菱形
--> 是带箭头的连接线
--是不带箭头的连接线
|| 里面写，箭头线上面的信息
```

## mermaid-纵向-TD

```mermaid
graph TD 
A(工业用地效率)-->B1(土地利用强度)
A-->B2(土地经济效益)
B1-->C1(容积率)
B1-->C2(建筑系数)
B1-->C3(亩均固定资本投入)
B2-->D1(亩均工业产值) 
B2-->D2(亩均税收)
```

```mermaid
graph TD
    A[Enter Chart Definition] --> B(Preview)
    B --> C{decide}
    C --> D[Keep]
    C --> E[Edit Definition]
    E --> B
    D --> F[Save Image and Code]
    F --> B
```

```mermaid
graph TD
a1[带文本矩形]-->a2(带文本圆角矩形)-->a3>带文本不对称矩形]-->b1{带文本菱形}-->c1((带文本圆形))
```

```mermaid
graph TD;
    A-->B;
    A-->C;
    B-->D;
```

```mermaid
graph TD
    A[AI生成建议] --> B{风险等级}
    B -- P0 --> C[自动执行]
    B -- P1 --> D[Teams审批]
    D -- 批准 --> E[执行+记录]
    D -- 拒绝 --> F[人工处理]
```

**箭头上添加文字**

```mermaid
graph TD
A--> |"argmax(output)"|result["breathing/cough"]
```

## mermaid-TB

```mermaid
 graph TB
  A
  B[bname]
  C(cname)
  D((dname))
  E>ename]
  F{fname}
```

```bash
默认节点 A
文本节点 B[bname]
圆角节点 C(cname)
圆形节点 D((dname))
非对称节点 E>ename]
菱形节点 F{fname}
A~F 是当前节点名字，类似于变量名，画图时便于引用  
[b~f]name是节点中显示的文字，默认节点的名字和显示的文字都为A  
```

**eg2**

```mermaid
graph TB
  A1-->B1
  A2---B2
  A3--text---B3
  A4--text-->B4
  A5-.-B5
  A6-.->B6
  A7-.text.-B7
  A8-.text.->B8
  A9===B9
  A10==>B10
  A11==text===B11
  A12==text==>B12
```

```bash
箭头连接 A1–->B1
开放连接 A2—B2
标签连接 A3–text—B3
箭头标签连接 A4–text–>B4
虚线开放连接 A5.-B5
虚线箭头连接 A6-.->B6
标签虚线连接 A7-.text.-B7
标签虚线箭头连接 A8-.text.->B8
粗线开放连接 A9===B9
粗线箭头连接 A10==>B10
标签粗线开放连接 A11==text===B11
标签粗线箭头连接 A12==text==>B12
```
**Pod 拓扑分布约束** 
```mermaid
graph TB
   subgraph "zoneB"
       n3(Node3)
       n4(Node4)
   end
   subgraph "zoneA"
       n1(Node1)
       n2(Node2)
   end
 
   classDef plain fill:#ddd,stroke:#fff,stroke-width:4px,color:#000;
   classDef k8s fill:#326ce5,stroke:#fff,stroke-width:4px,color:#fff;
   classDef cluster fill:#fff,stroke:#bbb,stroke-width:2px,color:#326ce5;
   class n1,n2,n3,n4 k8s;
   class zoneA,zoneB cluster
```
## mermaid-横向-LR

```mermaid
graph LR
  start("input x") --> handler("x > 0?")
  handler --yes--> yes("output x")
  handler --no--> start
  yes --> exit("exit")
```

```mermaid
graph LR
A[Sonar Standard] -->B(CWE)
A -->C(SANS)
A -->D(OWASP)
A -->E(MISRA)
A -->F(CERT)
```

```mermaid
graph LR
A[Hard edge] -->B(Round edge)
B --> C{Decision}
C --> |One| D[Result one]
C --> |Two| E[Result two]
C --> |Three| F[Result three]
```

```mermaid
graph LR
KaTex--> A(标记 Accents)
A-->撇,估计,均值,向量等写于符号上下的标记
KaTex--> 分隔符_Delimiters
分隔符_Delimiters-->小中大括号,竖杠,绝对值等分隔符的反斜杠写法
KaTex--> 公式组_Enviroments
公式组_Enviroments-->B(.....)
KaTex-->C(...)
```

```mermaid
graph LR;
  A-->B
  B-->C
  C-->D
  D-->A 
```

**文本换行、文本中包含空格或者其他特殊符号**

```mermaid
graph LR
root-->Generic["Generic (organisational)  <br/>Domains <br/> (e.g. .com, .edu, .gov, .net, org)"]
-->Cdn["CDN" <br/>WEB </br>IPTV <br/>LIVE]
-->CAT["FUC.."]
```

**其他形状**

```mermaid
graph LR
a1[带文本矩形]-->a2(带文本圆角矩形)-->a3>带文本不对称矩形]-->b1{带文本菱形}-->c1((带文本圆形))
```

## html实现TDLR

<body>
  Here is a mermaid diagram:
  <pre class="mermaid">
        graph TD 
        A[Client] --> B[Load Balancer] 
        B --> C[Server01] 
        B --> D[Server02]
  </pre>
</body>

<html lang="en">
  <head>
    <meta charset="utf-8" />
  </head>
  <body>
    <pre class="mermaid">
            graph LR 
            A --- B 
            B-->C[fa:fa-ban forbidden] 
            B-->D(fa:fa-spinner);
    </pre>
    <pre class="mermaid">
            graph TD 
            A[Client] --> B[Load Balancer] 
            B --> C[Server1] 
            B --> D[Server2]
    </pre>
    <script type="module">
      import mermaid from 'The/Path/In/Your/Package/mermaid.esm.mjs';
      mermaid.initialize({ startOnLoad: true });
    </script>
  </body>
</html>

## mermaid-子图-subgraph

```mermaid
graph LR;
 client([客户端])-. Ingress 所管理的<br>负载均衡器 .->ingress[Ingress];
 ingress-->|路由规则|service[服务];
 subgraph cluster
 ingress;
 service-->pod1[Pod];
 service-->pod2[Pod];
 end
 classDef plain fill:#ddd,stroke:#fff,stroke-width:4px,color:#000;
 classDef k8s fill:#326ce5,stroke:#fff,stroke-width:4px,color:#fff;
 classDef cluster fill:#fff,stroke:#bbb,stroke-width:2px,color:#326ce5;
 class ingress,service,pod1,pod2 k8s;
 class client plain;
 class cluster cluster;
```

```mermaid
graph LR
  subgraph g1
    a1-->b1
  end
  subgraph g2
    a2-->b2
  end
  subgraph g3
    a3-->b3
  end
  a3-->a2
  a1 .-> a2
```

## mermaid-时序图-sequenceDiagram

```bash
先输入```mermaid
sequenceDiagram
->> 代表实线箭头，–>> 则代表虚线箭头
-> 直线，–>虚线
使用sequenceDiagram 则不使用``sequence
```

**UML时序图-简单**

```mermaid
sequenceDiagram
客户->>银行柜台: 我要存钱  
银行柜台->>后台: 改一下这个账户数字哦  
后台->>银行柜台: 账户的数字改完了，明天起息  
银行柜台->>客户: 好了，给你回单 ，下一位
```

**eg-连线**

```mermaid
sequenceDiagram
    Alice->>John: Hello John, how are you?
    John-->>Alice: Great!
    #语法解释：->> 代表实线箭头，-->> 则代表虚线。
```

```mermaid
sequenceDiagram
Alice->Bob: Hello Bob, how are you?
Note right of Bob: Bob thinks
Bob-->Alice: I am good thanks!
```

```mermaid
sequenceDiagram
Alice->Bob: -> 是无箭头实线
Alice-->Bob: -->是无箭头虚线
Alice->>Bob: -->是有箭头实线
Alice-->>Bob: -->>是有箭头虚线
Alice-x Bob: -x是无箭头实线
Alice--x Bob: --x是无箭头虚线
Bob-->Alice: I am good thanks!
```

```mermaid
sequenceDiagram
	A ->> B : 把地扫了!
	activate B
	B ->> A : 我干完了！
	A ->> B : 把碗洗了!
	B ->> A : 我干完了！
	A ->> B : 行，下班吧
	deactivate B

	activate C
	B ->> C : 下班啦
	deactivate C
```

```mermaid
sequenceDiagram
  Note right of A: 倒霉, 碰到B了
  A->B:   Hello B, how are you ?
  note left of B: 倒霉,碰到A了
  B-->A:  Fine, thx, and you?
  note over A,B: 快点溜，太麻烦了
  A->>B:  I'm fine too.
  note left of B: 快点打发了A
  B-->>A: Great!
  note right of A: 溜之大吉
  A-xB:   Wait a moment
  loop Look B every minute
　  A->>B: look B, go?
　　B->>A: let me go?
　end
　B--xA: I'm off, byte 　
  note right of A: 太好了, 他走了
```

```bash
无箭头实线 ->
有箭头实线 ->>
无箭头虚线 -->
有箭头虚线 -->>
带x实线 -x
带x虚线 –x
```

**改变AB的顺序**

```mermaid
sequenceDiagram
  # 通过设定参与者(participant)的顺序控制展示顺序
  participant B
  participant A
  Note right of A: 倒霉, 碰到B了
  A->B:   Hello B, how are you ?
  note left of B: 倒霉,碰到A了
  B-->A:  Fine, thx, and you?
  note over A,B:快点溜，太麻烦了。。。
  A->>B:  I'm fine too.
  note left of B: 快点打发了A
  B-->>A: Great!
  note right of A: 溜之大吉
  A-xB:   Wait a moment
  loop Look B every minute
　  A->>B: look B, go?
　　B->>A: let me go?
　end
　B--xA: I'm off, byte 　
  note right of A: 太好了, 他走了
```

**选择语法**

```mermaid
sequenceDiagram
　　Alice->>Bob: Hello Bob, how are you?
　　alt is sick
　　　　Bob->>Alice:not so good :(
　　else  is well
　　　　Bob->>Alice:good
　　end
　　opt Extra response
　　　　Bob->>Alice:Thanks for asking
　　end
```

**通过设定参与者(participants)的顺序控制展示模块顺序**

```mermaid
sequenceDiagram
  # 通过设定参与者(participants)的顺序控制展示模块顺序
  participant Alice
　participant Bob
　participant John
　Alice->John:Hello John, how are you?
　loop Healthcheck
　  John->John:Fight against hypochondria
　end
　Note right of John:Rational thoughts <br/>prevail...
　John-->Alice:Great!
　John->Bob: How about you?
　Bob-->John: good!
```

**时序图之loop用法**

```mermaid
sequenceDiagram
  Note left of A: A左侧
  Note right of A: A右侧
  note over A,B: A与B中间
 
  #1.loop第一种方式
　A->>+B: loop: A to B.
　B->>-A: loop: B to A.
　
　#2.loop第二种方式
　loop 循环例子
　	C->>D: C to D.
　	D->>C: D to C.
　end
```

**序列图sequence 示例**

```mermaid
sequenceDiagram
title: 序列图sequence 示例
# participant, 参与者
participant A
participant B
participant C
 
note left of A: A左侧说明
note over B: 覆盖B的说明
note right of C: C右侧说明
 
# - 代表实线, -- 代表虚线; > 代表实箭头, >> 代表虚箭头
A->A:自己到自己
A->B:实线实箭头
A-->C:虚线实箭头
B->>C:实线虚箭头
B-->>A:虚线虚箭头
```

**eg2**

```mermaid
sequenceDiagram
       对象A->>对象B: 对象B你好吗?（请求）
       Note right of 对象B: 对象B的描述
       Note left of 对象A: 对象A的描述(提示)
       对象B-->>对象A: 我很好(响应)
       对象A->>对象B: 你真的好吗？
```

**eg3**

```mermaid
sequenceDiagram
Title: 标题:复杂使用
对象A->>对象B:对象B你好吗?(请求) Note right of对象B: 对象B的描述
Note left of 对象A:对象A的描述(提示)对象B-->>对象A:我很好(响应)对象B->>小三:你好吗
小三-->>对象A:对象B找我了对象A->>对象B:你真的好吗?
Note over 小三,对象B:我们是朋友 participant C
Note right of C:没人陪我玩
```

**标准**

```mermaid
%% 时序图例子,-> 直线，-->虚线，->>实线箭头
sequenceDiagram
    participant 张三
    participant 李四
    张三->王五: 王五你好吗？
    loop 健康检查
        王五->王五: 与疾病战斗
    end
    Note right of 王五: 合理 食物 <br/>看医生...
    李四-->>张三: 很好!
    王五->李四: 你怎么样?
    李四-->王五: 很好!A
```

**练习时序图**

```mermaid
sequenceDiagram
		participant A
		participant B
		participant C
		participant D
		title: 练习时序图
		A->>B:request
		B->>B:verify sign
		B->>C:123
		C-->>B:321
		B->>C:456
		C->>C:code
		C->>D:789
		D-->>B:987
		alt yes
		Note right of B:yes的结果
		else no
		B-->>D:login
		D-->>B:login success
		end
		B->>B:加密
		B-->>A:return  
```

**时序图例子**

```mermaid
sequenceDiagram
		title: 时序图例子
		Alice->>Alice:自言自语
		Alice-->>John:hello john,
		%% over 可以用于单独一个角色上，也可以用于相邻的两个角色间：
		note over Alice,John:friend
	
		%% loop 后跟循环体说明文字
		loop healthcheck
			John-->>John:Fight agaist hypochondra
		end
	
		note right of John: Rational
	
		John-->>Alice:Great!
		John->>Bob:How about you?
	
		%% 控制焦点：用来表示时序图中对象执行某个操作的一段时间
		%% activate 角色名：表示激活控制焦点
		activate Bob
		Bob-->>John:Jolly good!
		%% deactivate 角色名 表示控制焦点结束
    deactivate Bob
  
    Alice->>+Bob: Hello Bob, how are you?
  
    rect rgb(175, 255, 212)
    alt is sick
    Bob-->>Alice: Not so good :(
    else is well
    Bob-->>Alice: Feeling fresh like a daisy
    end
    opt Extra response
    Bob-->>Alice: Thanks for asking
    end
    end
  
    loop communicating
        Alice->>+John: asking some questions
        John-->>-Alice: answer 
    end
  
    par Alice to John
      Alice->>John: Bye
    and Alice to Bob
      Alice->>Bob: Bye
    end
		Alice-xJohn: 这是一个异步调用
    Alice--xBob: 这是一个异步调用
```

**[k8spod-init](https://kubernetes.io/zh-cn/docs/contribute/style/diagram-guide/)**
```mermaid
%%{init:{"theme":"neutral"}}%%
sequenceDiagram
    actor me
    participant apiSrv as 控制面<br><br>api-server
    participant etcd as 控制面<br><br>etcd 数据存储
    participant cntrlMgr as 控制面<br><br>控制器管理器
    participant sched as 控制面<br><br>调度器
    participant kubelet as 节点<br><br>kubelet
    participant container as 节点<br><br>容器运行时
    me->>apiSrv: 1. kubectl create -f pod.yaml
    apiSrv-->>etcd: 2. 保存新状态
    cntrlMgr->>apiSrv: 3. 检查变更
    sched->>apiSrv: 4. 监视未分派的 Pod(s)
    apiSrv->>sched: 5. 通知 nodename=" " 的 Pod
    sched->>apiSrv: 6. 指派 Pod 到节点
    apiSrv-->>etcd: 7. 保存新状态
    kubelet->>apiSrv: 8. 查询新指派的 Pod(s)
    apiSrv->>kubelet: 9. 将 Pod 绑定到节点
    kubelet->>container: 10. 启动容器
    kubelet->>apiSrv: 11. 更新 Pod 状态
    apiSrv-->>etcd: 12. 保存新状态
```

## 状态图

```mermaid
stateDiagram
    [*] --> s1
    s1 --> [*]
```

```bash
语法解释：[*] 表示开始或者结束，如果在箭头右边则表示结束。 
```

## 类图

```bash
类是类图中的核心组成，类的成员包括属性和方法，以及一些扩展信息。在类图中，一个类实例由三层组成
类名称，在类图的最顶端；
类属性，在类图的中间层；
类方法，在类图的最下层。
```

```mermaid
classDiagram
class 动物
    动物 : String 标签
    动物 : 吃()
```

```mermaid
classDiagram
      Animal <|-- Duck
      Animal <|-- Fish
      Animal <|-- Zebra
      Animal : +int age
      Animal : +String gender
      Animal: +isMammal()
      Animal: +mate()
      class Duck{
          +String beakColor
          +swim()
          +quack()
      }
      class Fish{
          -int sizeInFeet
          -canEat()
      }
      class Zebra{
          +bool is_wild
          +run()
      }
```

```bash
语法解释：<|-- 表示继承，+ 表示 public，- 表示 private，学过 Java 的应该都知道。
```

**各种连线类型展示**

```mermaid
classDiagram
  classA <|-- classB
  classC *-- classD
  classE o-- classF
  classG <-- classH
  classI -- classJ
  classK <.. classL
  classM<|.. classN
  classO ..classP
```

```bash
<|-- 继承关系
*-- 组成关系
o-- 集合关系
--> 关联关系
-- 实现连接
..> 依赖关系
..|> 实现关系
..  虚线 
```

**不同基数关系的定义**

```mermaid
classDiagram
    顾客 "1" --> "*" 票据
    学生 "1" --> "1..*" 课程
    银河 --> "many" 星星 : 包含
```

**test**

```mermaid
classDiagram
   	Vector  <|-- SortedVector: 继承
    class SortedVector{
	    friend#32;class#32;Vector#60;TYPE#62;
	}
```

> 注意：“#32;" ：表示空格

## 折线图


## mermaid-饼图-pie

```mermaid
pie
    title 为什么总是宅在家里？
    "喜欢宅" : 15
    "天气太热或太冷" : 20
    "穷" : 50
```

```mermaid
pie
    title Key elements in Product X
    "Calcium" : 42.96
    "Potassium" : 50.05
    "Magnesium" : 10.01
    "Iron" :  5
```



## mermaid-甘特图
**关键字列表**
| title      | 标题               |
| ------------ | -------------------- |
| dateFormat | 日期格式           |
| section    | 模块               |
| Completed  | 已经完成           |
| Active     | 当前正在进行       |
| Future     | 后续待处理         |
| crit       | 关键阶段           |
| 日期缺失   | 默认从上一项完成后 |

```bash
甘特图一般用来表示项目的计划排期，目前在工作中经常会用到
语法也非常简单，从上到下依次是图片标题、日期格式、项目、项目细分的任务
```

```mermaid
gantt
dateFormat YYYY-MM-DD
section S1
T1: 2023-10-01, 9d
section S2
T2: 2023-10-11, 9d
section S3
T3: 2023-10-02, 9d
```

```mermaid
gantt
    dateFormat  YYYY-MM-DD
    title Adding GANTT diagram functionality to mermaid
 
    section A section
    Completed task            :done,    des1, 2023-01-06,2023-01-08
    Active task               :active,  des2, 2023-01-09, 3d
    Future task               :         des3, after des2, 5d
    Future task2               :         des4, after des3, 5d
 
    section Critical tasks
    Completed task in the critical line :crit, done, 2023-01-06,24h
    Implement parser and jison          :crit, done, after des1, 2d
    Create tests for parser             :crit, active, 3d
    Future task in critical line        :crit, 5d
    Create tests for renderer           :2d
    Add to mermaid                      :1d
 
    section Documentation
    Describe gantt syntax               :active, a1, after des1, 3d
    Add gantt diagram to demo page      :after a1  , 20h
    Add another diagram to demo page    :doc1, after a1  , 48h
 
    section Last section
    Describe gantt syntax               :after doc1, 3d
    Add gantt diagram to demo page      : 20h
    Add another diagram to demo page    : 48h
```

```mermaid
gantt
    title 工作计划
    dateFormat  YYYY-MM-DD
    section Section
    A task           :a1, 2023-11-01, 30d
    Another task     :after a1  , 20d
    section Another
    Task in sec      :2023-11-12  , 12d
    another task      : 24d
```

```mermaid
gantt
dateFormat  YYYY-MM-DD
        title 软件开发甘特图
        section 设计
        需求                      :done,    des1, 2023-01-06,2023-01-08
        原型                      :active,  des2, 2023-01-09, 3d
        UI设计                     :         des3, after des2, 5d
    未来任务                     :         des4, after des3, 5d
        section 开发
        学习准备理解需求                      :crit, done, 2023-01-06,24h
        设计框架                             :crit, done, after des2, 2d
        开发                                 :crit, active, 3d
        未来任务                              :crit, 5d
        耍                                   :2d
 
        section 测试
        功能测试                              :active, a1, after des3, 3d
        压力测试                               :after a1  , 20h
        测试报告                               : 48h
```

---

# mindmap

```mindmap
- 教程
- 语法指导
  - 普通内容
  - 提及用户
  - 表情符号 Emoji
    - 一些表情例子
  - 大标题 - Heading 3
    - Heading 4
      - Heading 5
        - Heading 6
  - 图片
  - 代码块
    - 普通
    - 语法高亮支持
      - 演示 Go 代码高亮
      - 演示 Java 高亮
  - 有序、无序、任务列表
    - 无序列表
    - 有序列表
    - 任务列表
  - 表格
  - 隐藏细节
  - 段落
  - 链接引用
  - 数学公式
  - 脑图
  - 流程图
  - 时序图
  - 甘特图
  - 图表
  - 五线谱
  - Graphviz
  - 多媒体
  - 脚注
```

```mindmap
- Food
  - x
  - y 
- Fruits
  - easy to eat
  - apple
  - banana
  - not so easy
  - grapes
- Vegetables
  - cabbage
  - tomato
```

# 图表
```echarts
{
  "title": { "text": "最近 30 天" },
  "tooltip": { "trigger": "axis", "axisPointer": { "lineStyle": { "width": 0 } } },
  "legend": { "data": ["帖子", "用户", "回帖"] },
  "xAxis": [{
      "type": "category",
      "boundaryGap": false,
      "data": ["2023-05-08","2023-05-09","2023-05-10","2023-05-11","2023-05-12","2023-05-13","2023-05-14","2023-05-15","2023-05-16","2023-05-17","2023-05-18","2023-05-19","2023-05-20","2023-05-21","2023-05-22","2023-05-23","2023-05-24","2023-05-25","2023-05-26","2023-05-27","2023-05-28","2023-05-29","2023-05-30","2023-05-31","2023-06-01","2023-06-02","2023-06-03","2023-06-04","2023-06-05","2023-06-06","2023-06-07"],
      "axisTick": { "show": false },
      "axisLine": { "show": false }
  }],
  "yAxis": [{ "type": "value", "axisTick": { "show": false }, "axisLine": { "show": false }, "splitLine": { "lineStyle": { "color": "rgba(0, 0, 0, .38)", "type": "dashed" } } }],
  "series": [
    {
      "name": "帖子", "type": "line", "smooth": true, "itemStyle": { "color": "#d23f31" }, "areaStyle": { "normal": {} }, "z": 3,
      "data": ["18","14","22","9","7","18","10","12","13","16","6","9","15","15","12","15","8","14","9","10","29","22","14","22","9","10","15","9","9","15","0"]
    },
    {
      "name": "用户", "type": "line", "smooth": true, "itemStyle": { "color": "#f1e05a" }, "areaStyle": { "normal": {} }, "z": 2,
      "data": ["31","33","30","23","16","29","23","37","41","29","16","13","39","23","38","136","89","35","22","50","57","47","36","59","14","23","46","44","51","43","0"]
    },
    {
      "name": "回帖", "type": "line", "smooth": true, "itemStyle": { "color": "#4285f4" }, "areaStyle": { "normal": {} }, "z": 1,
      "data": ["35","42","73","15","43","58","55","35","46","87","36","15","44","76","130","73","50","20","21","54","48","73","60","89","26","27","70","63","55","37","0"]
    }
  ]
}
```

# 五线谱  shift+ctrl+alt+M预览
```abc
X: 24
T: Clouds Thicken
C: Paul Rosen
S: Copyright 2023, Paul Rosen
M: 6/8
L: 1/8
Q: 3/8=116
R: Creepy Jig
K: Em
|:"Em"EEE E2G|"C7"_B2A G2F|"Em"EEE E2G|\
"C7"_B2A "B7"=B3|"Em"EEE E2G|
"C7"_B2A G2F|"Em"GFE "D (Bm7)"F2D|\
1"Em"E3-E3:|2"Em"E3-E2B|:"Em"e2e gfe|
"G"g2ab3|"Em"gfeg2e|"D"fedB2A|"Em"e2e gfe|\
"G"g2ab3|"Em"gfe"D"f2d|"Em"e3-e3:|
```


# Graphviz

# Flowchart流程图  shift+ctrl+alt+M

```
flowchartgg
st=>start: Start
op=>operation: Your Operation
cond=>condition: Yes or No?
e=>end
st->op->cond
cond(yes)->e
cond(no)->op
```

```flowchart
cond1=>condition: x>0?
cond1(yes)->module1
cond1(no)->moudle2
# 指定方向,如果后面占用了这个方向, 前面的无效   
cond1(yes,right)->module1
cond1(no)->moudle2
```

```flowchart
# 先自定义变量,然后画图
st=>start: 开始
e=>end: 结束
op=>operation: 输入x
sub=>subroutine: 是否重新输入
cond1=>condition: x>0?
cond2=>condition: yes/no 
io=>inputoutput: 输出x  
 
st(right)->op->cond1
cond1(yes)->io(right)->e
cond1(no)->sub(right)->cond2()
cond2(no)->e 
```

**标准-竖向-**

```flowchart
st=>start: 开始框 
op=>operation: 处理框 
cond=>condition: 判断框(是或否?) 
sub1=>subroutine: 子流程 
io=>inputoutput: 输入输出框 
e=>end: 结束框 
st->op->cond 
cond(yes)->io->e 
cond(no)->sub1(right)->op
```

**标准-横向**

```flowchart
st=>start: 开始框 
op=>operation: 处理框 
cond=>condition: 判断框(是或否?) 
sub1=>subroutine: 子流程 
io=>inputoutput: 输入输出框 
e=>end: 结束框 
st(right)->op(right)->cond 
cond(yes)->io(bottom)->e 
cond(no)->sub1(right)->op
```

# HTML思维导图Mindmap

**eg1**

<!DOCTYPE html>

<html>
  <head>
    <meta charset="UTF-8">
    <title>Mermaid 思维导图</title>
    <script src="https://cdn.jsdelivr.net/npm/mermaid/dist/mermaid.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/mermaid/dist/mermaid.js"></script>
  </head>
  <body>
    <pre class="mermaid">
      mindmap
      根节点
          第一级别
              第二级别 1
              第二级别 2
    </pre>
    <script>
  const config = {
    startOnLoad: false,
    securityLevel: 'loose',
  };
  mermaid.initialize(config);
</script>
  </body>
</html>

**eg2**

<!DOCTYPE html>

<html>
  <head>
    <meta charset="UTF-8">
    <title>Mermaid 思维导图X</title>
    <script src="https://cdn.jsdelivr.net/npm/mermaid/dist/mermaid.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/mermaid/dist/mermaid.js"></script>
  </head>
  <body>
    <pre class="mermaid">
  mindmap
  root((思维导图))
    起源
      悠久的历史
      ::icon(fa fa-book)
      普及
        英国流行心理学作家托尼·布赞
    研究
      关于有效性<br/>和功能
      论自动创造
        用途
          创造性技术
          战略规划
          参数映射
    工具
      笔和纸
      Mermaid
  </pre>
      <script>
  const config = {
    startOnLoad: false,
    securityLevel: 'loose',
  };
  mermaid.initialize(config);
    </script>
    </body>
  </html>

**eg3-形状**

<!DOCTYPE html>

<html>
  <head>
    <meta charset="UTF-8">
    <title>Mermaid 思维导图</title>
    <script src="https://cdn.jsdelivr.net/npm/mermaid/dist/mermaid.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/mermaid/dist/mermaid.js"></script>
  </head>
  <body>
    <pre class="mermaid">
      mindmap
      id[矩形]
    </pre>
    <script>
  const config = {
    startOnLoad: false,
    securityLevel: 'loose',
  };
  mermaid.initialize(config);
</script>
  </body>
</html>

<!DOCTYPE html>

<html>
  <head>
    <meta charset="UTF-8">
    <title>Mermaid 思维导图</title>
    <script src="https://cdn.jsdelivr.net/npm/mermaid/dist/mermaid.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/mermaid/dist/mermaid.js"></script>
  </head>
  <body>
    <pre class="mermaid">
      mindmap
      id(圆角矩形)
    </pre>
    <script>
  const config = {
    startOnLoad: false,
    securityLevel: 'loose',
  };
  mermaid.initialize(config);
</script>
  </body>
</html>

<!DOCTYPE html>

<html>
  <head>
    <meta charset="UTF-8">
    <title>Mermaid 思维导图</title>
    <script src="https://cdn.jsdelivr.net/npm/mermaid/dist/mermaid.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/mermaid/dist/mermaid.js"></script>
  </head>
  <body>
    <pre class="mermaid">
      mindmap
      id((圆形))
    </pre>
    <script>
  const config = {
    startOnLoad: false,
    securityLevel: 'loose',
  };
  mermaid.initialize(config);
</script>
  </body>
</html>

<!DOCTYPE html>

<html>
  <head>
    <meta charset="UTF-8">
    <title>Mermaid 思维导图</title>
    <script src="https://cdn.jsdelivr.net/npm/mermaid/dist/mermaid.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/mermaid/dist/mermaid.js"></script>
  </head>
  <body>
    <pre class="mermaid">
      mindmap
      id))爆炸((
    </pre>
    <script>
  const config = {
    startOnLoad: false,
    securityLevel: 'loose',
  };
  mermaid.initialize(config);
</script>
  </body>
</html>

<!DOCTYPE html>

<html>
  <head>
    <meta charset="UTF-8">
    <title>Mermaid 思维导图</title>
    <script src="https://cdn.jsdelivr.net/npm/mermaid/dist/mermaid.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/mermaid/dist/mermaid.js"></script>
  </head>
  <body>
    <pre class="mermaid">
      mindmap
      id)云朵(
    </pre>
    <script>
  const config = {
    startOnLoad: false,
    securityLevel: 'loose',
  };
  mermaid.initialize(config);
</script>
  </body>
</html>

<!DOCTYPE html>

<html>
  <head>
    <meta charset="UTF-8">
    <title>Mermaid 思维导图</title>
    <script src="https://cdn.jsdelivr.net/npm/mermaid/dist/mermaid.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/mermaid/dist/mermaid.js"></script>
  </head>
  <body>
    <pre class="mermaid">
      mindmap
      id{{六边形}}
    </pre>
    <script>
  const config = {
    startOnLoad: false,
    securityLevel: 'loose',
  };
  mermaid.initialize(config);
</script>
  </body>
</html>

<!DOCTYPE html>

<html>
  <head>
    <meta charset="UTF-8">
    <title>Mermaid 思维导图</title>
    <script src="https://cdn.jsdelivr.net/npm/mermaid/dist/mermaid.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/mermaid/dist/mermaid.js"></script>
  </head>
  <body>
    <pre class="mermaid">
      mindmap
      默认形状
    </pre>
    <script>
  const config = {
    startOnLoad: false,
    securityLevel: 'loose',
  };
  mermaid.initialize(config);
</script>
  </body>
</html>

```bash
只须修改ID即可：
id[矩形]  id(圆角矩形) id((圆形))  id))爆炸((  id)云朵(  id{{六边形}}  默认形状
```

**[eg4-图标和类](https://blog.csdn.net/chenlu5201314/article/details/131293977)**
*图标*

<!DOCTYPE html>

<html>
  <head>
    <meta charset="UTF-8">
    <title>Mermaid 思维导图</title>
    <link rel="preload stylesheet"
      href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css"
      as="style">
    <link rel="preload stylesheet"
      href="https://cdn.jsdelivr.net/npm/@mdi/font@6.9.96/css/materialdesignicons.min.css"
      as="style">
    <script src="https://cdn.jsdelivr.net/npm/mermaid/dist/mermaid.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/mermaid/dist/mermaid.js"></script>
  </head>
  <body>
    <pre class="mermaid">
      mindmap
      根节点
          第一级
          ::icon(fa fa-book)
          第一级(二)
          ::icon(mdi mdi-skull-outline)
    </pre>
    <script>
  const config = {
    startOnLoad: false,
    securityLevel: 'loose',
  };
  mermaid.initialize(config);
</script>
  </body>
</html>

*类*

<!DOCTYPE html>

<html>
  <head>
    <meta charset="UTF-8">
    <title>Mermaid 思维导图</title>
    <script src="https://cdn.jsdelivr.net/npm/mermaid/dist/mermaid.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/mermaid/dist/mermaid.js"></script>
    <style type="text/css">
      .urgent .node-rect {
          fill: hsl(0deg 100% 50%);;
      }
      .large .text-inner-tspan {
        font-size: large;
        fill: white;
       }
   </style>
  </head>
  <body>
    <pre class="mermaid">
      mindmap
      根节点
          A[节点1]
          :::urgent large
          B(节点2)
          节点3
    </pre>
    <script>
  const config = {
    startOnLoad: false,
    securityLevel: 'loose',
  };
  mermaid.initialize(config);
</script>
  </body>
</html>

*缩进*

<!DOCTYPE html>

<html>
  <head>
    <meta charset="UTF-8">
    <title>Mermaid 思维导图</title>
    <link rel="preload stylesheet"
      href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css"
      as="style">
    <link rel="preload stylesheet"
      href="https://cdn.jsdelivr.net/npm/@mdi/font@6.9.96/css/materialdesignicons.min.css"
      as="style">
    <script src="https://cdn.jsdelivr.net/npm/mermaid/dist/mermaid.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/mermaid/dist/mermaid.js"></script>
  </head>
  <body>
    <pre class="mermaid">
      mindmap
      根节点
          第一级
              第二级1
            第二级2
    </pre>
    <script>
  const config = {
    startOnLoad: false,
    securityLevel: 'loose',
  };
  mermaid.initialize(config);
</script>
  </body>
  </html>

*Markdown字符串*

<!DOCTYPE html>

<html>
  <head>
    <meta charset="UTF-8">
    <title>Mermaid 思维导图</title>
    <link rel="preload stylesheet"
      href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css"
      as="style">
    <link rel="preload stylesheet"
      href="https://cdn.jsdelivr.net/npm/@mdi/font@6.9.96/css/materialdesignicons.min.css"
      as="style">
    <script src="https://cdn.jsdelivr.net/npm/mermaid/dist/mermaid.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/mermaid/dist/mermaid.js"></script>
  </head>
  <body>
    <pre class="mermaid">
      mindmap
      id1["`**根节点**
  第二行
  使用Unicode: ������`"]
        id2["`狗**骑**猪身上... *很长很长的文本* 自动换行到新的一行`"]
        id3[常规标签仍然有效]
    </pre>
    <script>
  const config = {
    startOnLoad: false,
    securityLevel: 'loose',
  };
  mermaid.initialize(config);
</script>
  </body>
</html>



```mermaid
%%{init: {"flowchart": {"htmlLabels": false}} }%%
flowchart LR
    markdown["`This **is** _Markdown_`"]
    newLines["`Line 1
    Line 2
    Line 3`"]
    newthree["`test 1
    test 2
    test 3`"]
    markdown --> newLines--> newthree
```
```mermaid
flowchart LR
    id["This ❤ Unicode"]
```
---  

```mermaid
flowchart TD;
    A[Start] --> B[Process 1];
    B --> C[Process 2]; 
    C --> D[End];
```

```mermaid
flowchart
    st=>start: Start
    op=>operation: Your Operation
    cond=>condition: Yes or No?
    e=>end
    st->op->cond
    cond(yes)->e
    cond(no)->op
```

[2]: https://bedebug.com/upload/2021/09/k8s%E5%B0%81%E9%9D%A2-5f054e7636dc42dba34b955998ea4bd8.jpg
[^1]: Markdown是一种。。。
    
[^2]: HyperText Markup Language






