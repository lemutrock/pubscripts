#!/bin/bash
#first acc number
i="301"
#last acc number
l="304"
#cut password from pos
s=0
#till
e=8
tname="accountname"
tpass="accountpass"
hname="sip.host.name"
printf "[general]\ncontext=office\nalloguest=no\nbindport=5060\nnat=auto_force_rport,auto_comedia\nbindaddr=0.0.0.0\nallow=alaw\nallow=g729\nallow=h263\nallow=h264\nlanguage=ru\ntos_audio=ef\ndefaultexpiry=125\n\n">>sip.conf

printf "register => $tname:$tpass@$hname/from-pstn\n\n">>sip.conf

printf "[$tname]\ntype=peer\nusername=$tname\nsecret=$tpass\nhost=$hname\nnat=force_rport,comedia\nfromuser=$tname\nfromdomain=$hname\ndtmfmode=rfc2833\ncanreinvite=no\ninsecure=invite\ncontext=from-pstn\nqualify=no\ndisallow=all\nallow=alaw\nallow=g729\n\n">>sip.conf


while [ $i -lt $l ]
do
dat=`date`
tmp=`echo $dat$i$RANDOM | md5sum`
pass=${tmp:$s:$e}
printf "[$i]\ntype=friend\nhost=dynamic\nusername=$i\nsecret=$pass\ncanreinvite=no\ncontext=office\ndisallow=all\nallow=alaw\nallow=g729\ndtmfmode=rfc2833\ncall-limit=2\ncallerid=$i<$i>\n\n">>sip.conf
i=$[$i+1]
done


