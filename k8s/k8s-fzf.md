# 基于fzf快速预览历史版本信息
k8s 里会记录历史版本信息，可以通过 kubectl rollout history来查看。但默认提供的信息很少，只能看到一个版本号  
可以通过加版本号的方式来获取更详细的信息： 

通过 fzf 快速预览对应版本的信息
每次都选择特定的版本会显的有些繁琐，我们可以通过 fzf 的 preview 功能来快速查看某个版本的信息。

把下面的代码保存成 khistory，存放在 PATH 路径里：
```bash
#!/bin/bash
# Author            : xx
# Date              : xx

main() {
  local svc="$1"
  local type="${2:-daemonset}"

  if [[ -z "$svc" ]]; then
    echo "Please specify component like adserver!"
    exit 1
  fi

  set -e

  local preview_cmd="kubectl rollout history $type/$svc --revision={1}"
  kubectl rollout history $type/$svc | grep '^\d' | tac | fzf --preview "$preview_cmd" --preview-window=right,80%
}

main "$@"

khistory component
```

[kubectl history](from: http://docs.kubernetes.org.cn/645.html#i)  





