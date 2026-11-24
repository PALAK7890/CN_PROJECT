#!/bin/sh
# Phase 2 Ext B/E: repoint app.team1.test on the PRIMARY DNS (Mac 1). Usage: sudo set_app_record.sh <IP>
set -e; IP=$1; CONF=/opt/homebrew/etc/dnsmasq.conf
cp $CONF $CONF.bak
sed -i '' "s#^address=/app.team1.test/.*#address=/app.team1.test/$IP#" $CONF
/opt/homebrew/sbin/dnsmasq --test -C $CONF >/dev/null 2>&1
/opt/homebrew/bin/brew services restart dnsmasq >/dev/null 2>&1
echo "primary: $(grep '^address=/app' $CONF)  (ttl $(grep '^local-ttl' $CONF | cut -d= -f2))"
