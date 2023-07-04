#/bin/bash

[ $# -lt 2 ] && echo "Usage: $(basename $0) <clientname> <peer_ip>" && exit 1

workdir="/etc/wireguard/clients/"
originalconf="/etc/wireguard/wg0.conf"
template="/etc/wireguard/clients/conf.template"
client=$1

CIP=$2

cd $workdir

wg genkey > $client.key
cat $client.key | wg pubkey > $client.key.pub

PK=`cat /etc/wireguard/clients/$client.key`
PUK=`cat /etc/wireguard/clients/$client.key.pub`

cp $template $client.conf

sed -i "s/PRIVATE_KEY/$PK/g" $client.conf
sed -i "s/IPADDR/$CIP/g" $client.conf

/usr/bin/wg-quick down wg0

echo "[Peer]" >> $originalconf
echo "PublicKey = $PUK" >> $originalconf
echo "AllowedIPs = $CIP/32" >> $originalconf
echo "" >> $originalconf

/usr/bin/wg-quick up wg0

qrencode -t ansiutf8 < $workdir$client.conf

