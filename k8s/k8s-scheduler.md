# k8s调度之初探nodeSelector和nodeAffinity
**k8s的调度中类型** 
  - 有强制性的nodeSelector
  - 节点亲和性nodeAffinity
  - Pod亲和性podAffinity
  - pod反亲和性podAntiAffinity  

进入主题之前，先看看创建pod的大概过程  
![创建pod流程](https://p3-sign.toutiaoimg.com/tos-cn-i-qvj2lq49k0/01235649687f49ab9c753705c94ec72c~noop.image?_iz=58558&from=article.pc_detail&x-expires=1678325352&x-signature=UV6Rxxr5pBaRgksqFDMfeddJI34%3D)  




[不背锅运维-k8s调度之初探](https://www.google.com/)
