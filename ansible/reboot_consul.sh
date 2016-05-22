#!/bin/sh

servers="odroid1 odroid2 odroid3 odroid4 odroid5 pine1"

instances="i1 i2 i3 i4"

for s in $servers
do
  ssh -l root -A $s "systemctl stop consul"
  ssh -l root -A $s "rm -rf /var/consul/*"
done

for s in $servers
do
  ssh -l root -A $s "systemctl start consul"
done

for s in $servers
do
  ssh -l root -A $s "systemctl daemon-reload"
  for i in $instances
  do
    ssh -l root -A $s "systemctl stop kronos-cluster-node@$i"
    ssh -l root -A $s "systemctl start kronos-cluster-node@$i"
  done
done

for s in $servers
do
  ssh -l root -A $s "consul info|grep state"
done

exit
curl http://localhost:8500/v1/agent/services?pretty
journalctl -u kronos-cluster-node
