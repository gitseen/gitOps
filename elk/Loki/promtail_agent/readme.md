# agent_promtail Install
1.tar xf agentpromtail && cd agentpromtail
2.sh install_agent_promtail.sh  install
3.journalctl -u promtail -f
4.curl http://172.16.219.234:13100/ready
5.cat /tmp/positions.yaml
