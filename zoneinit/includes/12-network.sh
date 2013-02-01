log "setting hostname, IPs and resolvers"

echo "${HOSTNAME}.${DOMAINNAME}" > /etc/nodename
/bin/hostname ${HOSTNAME}.${DOMAINNAME}

(
echo "domain ${DOMAINNAME}"
/bin/sed -E -e '/nameserver|domain/d' /etc/resolv.conf 2>/dev/null
for HOST in ${RESOLVERS[@]}; do
  echo "nameserver ${HOST}"
done
) > /etc/resolv.conf.tmp
mv /etc/resolv.conf{.tmp,}

for IP in ${PUBLIC_IPS[@]}; do
  echo "${IP}"$'\t'"${HOSTNAME}" >> /etc/inet/hosts
done
for IP in ${PRIVATE_IPS[@]}; do
  echo "${IP}"$'\t'"${ZONENAME}"$'\t'"loghost" >> /etc/inet/hosts
done

log "checking if we can reach the Internets"

if dig www.joyent.com +short +time=2 +tries=1 >/dev/null 2>&1 && \
   ping www.joyent.com 2 >/dev/null 2>&1 && \
   curl -m 5 -s -I http://www.joyent.com >/dev/null; then
  NETWORKING=yes
else
  NETWORKING=no
  log "continuing with no apparent Internet access"
fi
