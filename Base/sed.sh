通过 20 个实例掌握 Linux Sed 命令
https://www.toutiao.com/article/7196187682303803941/
SED 命令或 流编辑器是 Linux / Unix 系统提供的非常强大的实用程序。它主要用于文本替换，查找和替换，但也可以执行其他文本操作，例如 插入，删除，搜索 等。使用 SED，我们可以编辑完整的文件而无需打开它。SED 还支持使用正则表达式，这使得 SED 成为更强大的测试操作工具  

基本语法如下：

sed OPTIONS… [SCRIPT] [INPUTFILE…]

sed -n 22,29p testfile.txt  #选项 p 将只打印 22-29 行
sed 22,29d testfile.txt  
sed -n '2~3p' file.txt #显示从第 n 行开始的每 m 行
sed Nd testfile.txt
sed $d testfile.txt
sed '29,34d' testfile.txt #从 testfile.txt 文件中删除 29-34 行
sed '29,34!d' testfile.txt  #从 testfile.txt 文件中删除 29-34 之外的行

sed G testfile.txt #可以在每个非空行之后添加一个空行
sed 's/danger/safety/' testfile.txt
sed 's/danger/safety/g' testfile.txt
sed 's/danger/safety/2' testfile.txt
sed 's/danger/safety/2g' testfile.txt #为了完全替换第 2 次出现的所有单词
sed '4 s/danger/safety/' testfile.txt
sed '4,9 s/danger/safety/' testfile.txt #替换文件第 4-9 行的字符串
sed '/danger/a "This is new line with text after match"' testfile.txt    #使用选项 a, 在每个模式匹配之后添加新行
sed '/danger/i "This is new line with text before match" ' testfile.txt  #使用选项 i, 在每个模式匹配之前添加新行
sed '/danger/c "This will be the new line" ' testfile.txt  #使用 c 选项，当匹配时，正行都会被新内容替换
sed -i -e 's/danger/safety/g' -e 's/hate/love/' testfile.txt   #多个 sed 表达式，可以使用选项 e
 sed -i.bak -e 's/danger/safety/g'  testfile.txt 
sed -e 's/^danger.*stops$//g' testfile.txt 删除以模式开头和结尾的文件行

sed -e 's/.*/testing sed &/' testfile.txt #使用 sed & regex 在每行之前添加一些内容
sed -e 's/#.*//;/^$/d' testfile.txt #删除所有注释行和空行
sed -e 's/#.*//' testfile.txt #只删除注释行

sed 's/\([^:]*\).*/\1/' /etc/passwd #要获取 /etc/passwd 文件的所有用户名列表

 sed -i --follow-symlinks 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux #防止覆盖系统链接
