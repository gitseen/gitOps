# split  
功能: split可以将一个大文件分割成很多个小文件,有时文件太大处理起来不方便就需要使用到了 

```
age: split [OPTION]... [INPUT [PREFIX]]
Output fixed-size pieces of INPUT to PREFIXaa, PREFIXab, ...; default
size is 1000 lines, and default PREFIX is 'x'.  With no INPUT, or when INPUT
is -, read standard input.

Mandatory arguments to long options are mandatory for short options too.
  -a, --suffix-length=N   generate suffixes of length N (default 2)
      --additional-suffix=SUFFIX  append an additional SUFFIX to file names
  -b, --bytes=SIZE        put SIZE bytes per output file
  -C, --line-bytes=SIZE   put at most SIZE bytes of lines per output file
  -d, --numeric-suffixes[=FROM]  use numeric suffixes instead of alphabetic;
                                   FROM changes the start value (default 0)
  -e, --elide-empty-files  do not generate empty output files with '-n'
      --filter=COMMAND    write to shell COMMAND; file name is $FILE
  -l, --lines=NUMBER      put NUMBER lines per output file
  -n, --number=CHUNKS     generate CHUNKS output files; see explanation below
  -u, --unbuffered        immediately copy input to output with '-n r/...'
      --verbose           print a diagnostic just before each
                            output file is opened
      --help     display this help and exit
      --version  output version information and exit

SIZE is an integer and optional unit (example: 10M is 10*1024*1024).  Units
are K, M, G, T, P, E, Z, Y (powers of 1024) or KB, MB, ... (powers of 1000).

CHUNKS may be:
N       split into N files based on size of input
K/N     output Kth of N to stdout
l/N     split into N files without splitting lines
l/K/N   output Kth of N to stdout without splitting lines
r/N     like 'l' but use round robin distribution
r/K/N   likewise but only output Kth of N to stdout

GNU coreutils online help: <http://www.gnu.org/software/coreutils/>
For complete documentation, run: info coreutils 'split invocation'

```
---

# 示例CentOS-7-x86_64-DVD-1810.iso拆分还原
## 拆分
```
split  -b 500m -d CentOS-7-x86_64-DVD-1810.iso Centos  #将CentOS-7-x86_64-DVD-1810.iso拆分
参数说明 
-b： 指定大小
-d : 使用数字后缀而不是字母
-rw-r--r--  1 root root  524288000 5月   4 14:55 Centos00
-rw-r--r--  1 root root  524288000 5月   4 14:55 Centos01
-rw-r--r--  1 root root  524288000 5月   4 14:55 Centos02
-rw-r--r--  1 root root  524288000 5月   4 14:56 Centos03
-rw-r--r--  1 root root  524288000 5月   4 14:56 Centos04
-rw-r--r--  1 root root  524288000 5月   4 14:56 Centos05
-rw-r--r--  1 root root  524288000 5月   4 14:56 Centos06
-rw-r--r--  1 root root  524288000 5月   4 14:56 Centos07
-rw-r--r--  1 root root  394264576 5月   4 14:56 Centos08
```

## 还原
```
cat Centos0* > CentOS-7-x86_64-DVD-1810.iso
root@di188 15:01:49  /opt/test # ls -l
总用量 8962084
-rw-r--r-- 1 root root  524288000 5月   4 14:55 Centos00
-rw-r--r-- 1 root root  524288000 5月   4 14:55 Centos01
-rw-r--r-- 1 root root  524288000 5月   4 14:55 Centos02
-rw-r--r-- 1 root root  524288000 5月   4 14:56 Centos03
-rw-r--r-- 1 root root  524288000 5月   4 14:56 Centos04
-rw-r--r-- 1 root root  524288000 5月   4 14:56 Centos05
-rw-r--r-- 1 root root  524288000 5月   4 14:56 Centos06
-rw-r--r-- 1 root root  524288000 5月   4 14:56 Centos07
-rw-r--r-- 1 root root  394264576 5月   4 14:56 Centos08
-rw-r--r-- 1 root root 4588568576 5月   4 15:01 CentOS-7-x86_64-DVD-1810.iso
```

## 测试拆分还原是否可用
```
mount CentOS-7-x86_64-DVD-1810.iso /mnt/  #挂载本地仓库测试
mount: /dev/loop0 写保护，将以只读方式挂载
yum makecache fast
已加载插件：fastestmirror
Determining fastest mirrors
centos7-iso                                                                                                                                | 3.6 kB  00:00:00     
cm-web                                                                                                                                     | 2.9 kB  00:00:00     
zzjz-r-web                                                                                                                                 | 2.9 kB  00:00:00    


## 测试拆分还原核对MD5值
md5sum /root/CentOS-7-x86_64-DVD-1810.iso 
5b61d5b378502e9cba8ba26b6696c92a  /root/CentOS-7-x86_64-DVD-1810.iso

ls
Centos00  Centos01  Centos02  Centos03  Centos04  Centos05  Centos06  Centos07  Centos08  CentOS-7-x86_64-DVD-1810.iso

md5sum /opt/test/CentOS-7-x86_64-DVD-1810.iso 
5b61d5b378502e9cba8ba26b6696c92a  /opt/test/CentOS-7-x86_64-DVD-1810.iso

拆分还原后文件与源文件md5一样;tar文件也是如此分割即可
```
