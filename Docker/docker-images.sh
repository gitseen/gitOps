#!/bin/bash
#del_id=$(docker images | grep -v "1.0.0.Standard.RELEASE" | grep -v "latest" | awk '{print $3}')
#for del in ${del_id}
#do
#docker rmi $del
#done
#echo -e "_____________"
docker images | grep -v "1.0.0.Standard.RELEASE" | grep -v "latest" | awk '{print $3}'|xargs docker rmi -f
docker images | grep "none" |awk '{print $3}' |xargs docker rmi -f
#docker images | grep 'registry.cn-hangzhou' |awk '{print $3}'| xargs docker rmi -f
#docker ps -a|grep -E "Exited|Created" |awk '{print $1}'|xargs docker rm -f
#echo jhuYF8y7g!gcy4ts | passwd --stdin root
#tag
#docker image ls | awk '{if (NR>1){print $1":"$2}}'
docker images|grep -v 'myshare.io'|awk 'NR>1' |awk '{print $1":"$2}'|xargs docker rmi -f

#force
kubectl delete pod statusreporter-server-0 -n ks-zzjz-statusreportersvr --grace-period=0 --force


#批量打tag
tag_names=$(docker images|grep -v "myshare.io:5000"|awk 'NR>1'|awk '{print $1":"$2}' |xargs)
for i in ${tag_names[*]}
do
        docker tag $i myshare.io:5000/$i && docker push myshare.io:5000/$i
done

docker images|grep -v 'myshare.io'|awk 'NR>1' |awk '{print $1":"$2}'|xargs docker rmi -f

#导出
tag_names=$(docker images|grep -v "myshare.io:5000"|awk 'NR>1'|awk '{print $1":"$2}' |xargs)
for i in ${tag_names[*]};do
#new_tag=`echo $i|cut -d "/" -f 3`
new_tag=$(echo $i|awk -F'/' '{print $NF}')
docker save  $i > ${new_tag}.tar
done

or

docker images |grep  "myshare.io:5000"| awk '{if (NR>1){print $1":"$2}}' | while read line;do
     IMAGE_TAG=$(docker images | awk '{if (NR>1){print $1":"$2}}' | grep "${line}" | awk -F'/' '{print $NF}')
     docker save -o ${IMAGE_TAG}.tar.gz ${line}
done


or

#批量导出docker image镜像至不同的文件中，导出的tar包文件与镜像名称相同。
IMAGE_SAVE_PATH=/opt
docker image ls --format {{.Repository}}:{{.Tag}} | awk '/^10/{print $0}' | while read repo;do
	REPO_TAG=`echo $repo | awk -F'/' '/^10/{print $NF}' |  awk -F':' '{print $1"-"$2}'`
	echo -e "$repo >>>>>>>>>>>>>>>>>>正在导出" 
   	docker save $repo -o ${IMAGE_SAVE_PATH}/${REPO_TAG}.tar
	[ $? -eq 0 ] && echo -e "$repo>>>>>>>>>导出成功"
done
