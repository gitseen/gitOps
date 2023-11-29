k8s中configmap挂载文件的权限默认是420。这是十进制表示，转换成八进制就是644
如果容器中使用非root用户，此时文件没有可执行权限，需要修改文件权限。修改文件权限的方法如下：
在volumes字段中修改defaultMode参数的值:
volumes:
   - configMap:
       defaultMode: 493
       name: test
将名为test的configmap的权限设置成493，转换成八进制就是755
644-->420
755-->493
777-->511
https://www.sojson.com/hexconvert.html
