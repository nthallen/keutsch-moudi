#! /bin/bash
tgtdir=/usr/local/lib/systemd/timesyncd.conf.d
[ -d $tgtdir ] || mkdir -p $tgtdir
cp timesyncd.conf $tgtdir
systemctl restart systemd-timesyncd
timedatectl timesync-status
