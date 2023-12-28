# free命令中cached和buffers的区别
显示系统中可用和可用的物理内存和交换内存的总量，以及内核使用的缓冲区和高速缓存

## free语法命参数
```bash
语法： free [options]
命令参数:
-b 以Byte为单位显示内存使用情况。
-k 以KB为单位显示内存使用情况。
-m 以MB为单位显示内存使用情况。
-g  以GB为单位显示内存使用情况。
-o 不显示缓冲区调节列。
-s<间隔秒数> 持续观察内存使用状况。
-t 显示内存总和列。
-h, --human
	Show all output fields automatically scaled to shortest three digit unit and display the units of print out.  Following units are used.
        B = bytes
        K = kilos
        M = megas
        G = gigas
        T = teras
        P = petas
```
## free计算
```bash
total: 总物理内存大小
used: 已使用
free: 可用
Shared: 多个进程共享的内存总额
Buffers/cached: 磁盘缓存的大小 

total1：表示物理 内存总量
used1：表示总计分配给缓存（包含buffers 与cache ）使用的数量，但其中可能部分缓存并未实际使用
free1：未被分配的内存
shared1：共享内存，一般系统不会用到，这里也不讨论
buffers1： 系统分配但未被使用的buffers 数量
cached1：系统分配但未被使用的cache 数量
used2：实际使用的buffers 与cache 总量，也是实际使用的内存总量
free2：未被 使用的buffers 与cache 和未被分配的内存之和，这就是系统当前实际可用内存
可以整理出如下等式
total1 = used1 + free1
total1 = used2 + free2
used1 = buffers1 + cached1 + used2
free2 = buffers1 + cached1 + free1

```

## 区别
1、page cahe和buffer cache
Page cache实际上是针对文件系统的，是文件的缓存，在文件层面上的数据会缓存到page cache。文件的逻辑层需要映射到实际的物理磁盘，这种映射关系由文件系统来完成。
当page cache的数据需要刷新时，page cache中的数据交给buffer cache，但是这种处理在2.6版本的内核之后就变的很简单了，没有真正意义上的cache操作。

Buffer cache是针对磁盘块的缓存，也就是在没有文件系统的情况下，直接对磁盘进行操作的数据会缓存到buffer cache中，例如，文件系统的元数据都会缓存到buffer cache中。
page cache用来缓存文件数据，buffer cache用来缓存磁盘数据。在有文件系统的情况下，对文件操作，那么数据会缓存到page cache，如果直接采用dd等工具对磁盘进行读写，那么数据会缓存到buffer cache。


2、cache 和 buffer的区别
A buffer is something that has yet to be “written” to disk. A cache is something that has been “read” from the disk种方法，一般的应用程序不会申请使用共享内存

Cache：高速缓存，是位于CPU与主内存间的一种容量较小但速度很高的存储器。由于CPU的速度远高于主内存，CPU直接从内存中存取
样就减少了CPU的等待时间，提高了系统的效率。Cache又分为一级Cache（L1 Cache）和二级Cache（L2 Cache），L1 Cache集成在C
```bash
查看CPU的 L1、L2、L3
 ll /sys/devices/system/cpu/cpu0/cache/
total 0
drwxr-xr-x 2 root root 0 Jan 26 22:49 index0 #一级cache中的data和instruction cache
drwxr-xr-x 2 root root 0 Jan 26 22:49 index1 #一级cache中的data和instruction cache
drwxr-xr-x 2 root root 0 Jan 26 22:49 index2 #二级cache，共享的
drwxr-xr-x 2 root root 0 Jan 26 22:49 index3 #三级cache，共享的
```
3、Free中的buffer和cache （它们都是占用内存）基于内存的
buffer ：作为buffer cache的内存，是块设备的读写缓冲区
cache：作为page cache的内存， 文件系统的cache
如果 cache 的值很大，说明cache住的文件数很多。如果频繁访问到的文件都能被cache住，那么磁盘的读IO 必会非常小

如何释放Cache Memory
```bash

```

# 总结
**cached是cpu与内存间的，buffer是内存与磁盘间的，都是为了解决速度不对等的问题**

- 缓存（cached）是把读取过的数据保存起来，重新读取时若命中（找到需要的数据）就不要去读硬盘了，若没有命中就读硬盘。其中的数据会根据读取频率进行组织，把最频繁读取的内容放在最容易找到的位置，把不再读的内容不断往后排，直至从中删除
- 缓冲（buffers）是根据磁盘的读写设计的，把分散的写操作集中进行，减少磁盘碎片和硬盘的反复寻道，从而提高系统性能。linux有一个守护进程定期 清空缓冲内容（即写入磁盘），也可以通过sync命令手动清空缓冲。举个例子吧：我这里有一个ext2的U盘，我往里面cp一个3M的MP3，但U盘的灯 没有跳动，过了一会儿（或者手动输入sync）U盘的灯就跳动起来了。卸载设备时会清空缓冲，所以有些时候卸载一个设备时要等上几秒钟
- 修改/etc/sysctl.conf中的vm.swappiness右边的数字可以在下次开机时调节swap使用策略。该数字范围是0～100，数字越大越倾向于使用swap。默认为60，可以改一下试试。–两者都是RAM中的数据

**buffer是即将要被写入磁盘的，而cache是被从磁盘中读出来的**

- buffer是由各种进程分配的，被用在如输入队列等方面。一个简单的例子如某个进程要求有多个字段读入，在所有字段被读入完整之前，进程把先前读入的字段放在buffer中保存
- cache经常被用在磁盘的I/O请求上，如果有多个进程都要访问某个文件，于是该文件便被做成cache以方便下次被访问，这样可提高系统性能
- Buffer Cachebuffer cache，又称bcache，其中文名称为缓冲器高速缓冲存储器，简称缓冲器高缓。另外，buffer cache按照其工作原理，又被称为块高缓

