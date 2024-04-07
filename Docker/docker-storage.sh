#!bin/bash
#dokcer选择合适的存储驱动: 
https://zhuanlan.zhihu.com/p/159228795
https://docs.docker.com/storage/storagedriver/select-storage-driver/

Storage Driver 管理的是 container 写入层内部的临时存储。
简单的来讲，装在 docker 中的软件需要写入数据，我们并没有 mount point 或者是外部存储设备，我们需要写入数据到内部的临时存储。

Storage Driver 提供一个可插拔式的框架来管理这个内部的临时存储。
选择不同的 storage driver, 我们管理这个内部存储的方式也将不同，这样 docker 就可以在不同的环境中支持不同的系统。

Storage Driver 的种类
Docker 支持很多种类的 Storage Driver 。但我们需要基于我们的使用环境来选择最适合的存储驱动。

我们介绍下最常用的两种存储驱动：
overlay2 这是 file-base storage（文件系统类型的存储，文件的读写和修改喝药上传和下载全部的文件）。默认在 Ubuntu 和 CentOS 8+ 中使用。
devicemapper 这是 block-storage（基于块的存储，文件的读写和修改不需要上传和下载全部的文件）。默认在 CentOS 7和旧版本中使用。

overlay2 performs better when you do a lot of reading to the container.
devicemapper performs better when you are doing a lot of writing to the container layers.

#Docker-存储驱动
