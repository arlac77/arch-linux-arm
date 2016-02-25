#!/bin/sh

servers="odroid1 odroid2 odroid3 odroid4 odroid5"

for i in $servers
do
  ssh -l root -A $i "systemctl stop consul"
  ssh -l root -A $i "rm -rf /var/consul/*"
done

for i in $servers
do
  ssh -l root -A $i "systemctl start consul"
done

for i in $servers
do
  ssh -l root -A $i "systemctl daemon-reload"
  ssh -l root -A $i "systemctl stop kronos-cluster-node"
  ssh -l root -A $i "systemctl start kronos-cluster-node"
done

for i in $servers
do
  ssh -l root -A $i "consul info|grep state"
done

exit
curl http://localhost:8500/v1/agent/services?pretty
journalctl -u kronos-cluster-node
