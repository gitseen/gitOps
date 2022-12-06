# 如何通过kubectl 重启Pod (六种方法)
kubectl其实没有restart pod这个命令，这个主要是由于在k8s中pod的管理属于rs等控制器，并不需要运维手动维护，但有时候，我们修改了configmap的配置文件后，希望重启pod加载配置，此时就需要重启Pod。这里说的“重启”是加了引号的，准确地来说，是重建pod，给用户的感觉是重启。   
![pod-restart](https://p3-sign.toutiaoimg.com/tos-cn-i-qvj2lq49k0/4c8302c312c0466c85ddb4b268d7fc3c~noop.image?_iz=58558&from=article.pc_detail&x-expires=1670915173&x-signature=MrWnQRtorPR6hqYjjQvSGRteIwg%3D)
下面介绍六种k8s 里面重启pod的方式  

