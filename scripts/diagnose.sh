#!/bin/bash
# Team1 layer-by-layer diagnosis (Phase 2 Ext F). Run on a client Mac.
# Usage: ./diagnose.sh [name] [port]      default: app.team1.test 8443
NAME=${1:-app.team1.test}; PORT=${2:-8443}; DNS_SERVERS="10.7.2.17 10.7.2.169"
CA=${CA:-}; [ -n "$CA" ] && CAOPT="--cacert $CA" && OSSL="-CAfile $CA"
G='\033[1;32m'; R='\033[1;31m'; Y='\033[1;33m'; N='\033[0m'
ok(){ printf "  ${G}PASS${N} %s\n" "$*"; }; bad(){ printf "  ${R}FAIL${N} %s\n" "$*"; FAILED=${FAILED:-$*}; }; info(){ printf "  ${Y}....${N} %s\n" "$*"; }
hdr(){ printf "\n\033[1;36m[%s]\033[0m\n" "$*"; }
FAILED=""

hdr "1  DNS (application layer, UDP 53)"
for s in $DNS_SERVERS; do a=$(dig +short +time=2 +tries=1 @$s $NAME A 2>/dev/null | tail -1)
  [ -n "$a" ] && [[ $a != *timed* ]] && ok "server $s answers $NAME -> $a" || bad "DNS server $s gives no answer"; done
SYS=$(dscacheutil -q host -a name $NAME | awk '/ip_address/{print $2; exit}')
TEAM=$(dig +short +time=2 +tries=1 $NAME | tail -1)
info "system resolver (what apps use) -> ${SYS:-none}; resolvers: $(scutil --dns | awk '/nameserver\[/{print $3}' | sort -u | tr '\n' ' ')"
[ -z "$SYS" ] && bad "DNS: system cannot resolve $NAME"
[ -n "$SYS" ] && [ -n "$TEAM" ] && [ "$SYS" != "$TEAM" ] && bad "DNS: system answer $SYS != team DNS answer $TEAM -> check /etc/hosts: $(grep -v '^#' /etc/hosts | grep -w $NAME | tr -s '\t ' ' ')"
[ -n "$SYS" ] && [ "$SYS" = "$TEAM" ] && ok "system resolver agrees with team DNS"
IP=${SYS:-$TEAM}

hdr "2  IP reachability (network layer, ICMP)"
[ -z "$IP" ] && bad "no IP to test" || { ping -c1 -t2 $IP >/dev/null 2>&1 && ok "$IP answers ping" || bad "IP: $IP unreachable"; }

hdr "3  TCP $PORT (transport layer)"
nc -z -G3 $IP $PORT 2>/dev/null && ok "3-way handshake to $IP:$PORT completes" || bad "TCP: connect to $IP:$PORT refused/timed out (service down, wrong port, or firewall)"

hdr "4  TLS (certificate + handshake)"
V=$(echo | openssl s_client -connect $IP:$PORT -servername $NAME $OSSL 2>/dev/null)
SUBJ=$(echo "$V" | openssl x509 -noout -subject -enddate 2>/dev/null | tr '\n' ' ')
[ -n "$SUBJ" ] && ok "handshake ok: $SUBJ" || bad "TLS: no handshake on $IP:$PORT"
CV=$(curl -s $CAOPT -o /dev/null -w '%{ssl_verify_result}' https://$NAME:$PORT/ 2>/dev/null)
[ "$CV" = "0" ] && ok "certificate trusted for $NAME (no -k)" || bad "TLS: certificate not trusted for $NAME (verify=$CV)"

hdr "5  HTTP (application layer)"
H=$(curl -s $CAOPT -m5 -D- -o /dev/null https://$NAME:$PORT/api/status | tr -d '\r')
CODE=$(echo "$H" | awk 'NR==1{print $2}'); BE=$(echo "$H" | awk -F': ' 'tolower($1)=="x-backend"{print $2}'); ED=$(echo "$H" | awk -F': ' 'tolower($1)=="x-edge"{print $2}')
case "$CODE" in 200) ok "HTTP $CODE  backend=$BE edge=$ED";; 502|503|504) bad "HTTP: edge reached, upstream failed ($CODE) -> check backends 3001/3002";; *) bad "HTTP: status ${CODE:-none}";; esac

echo; [ -z "$FAILED" ] && printf "${G}ALL LAYERS OK${N}\n" || printf "${R}FIRST FAILING LAYER: %s${N}\n" "$FAILED"
