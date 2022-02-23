#!/bin/bash

#Don't confuse local and remote dir

remoteHost="remoteHost"
remoteUser="user"
remoteDir="/home/user/SyncDir/"
localDir="/home/user/LocalDir/"
scriptdir="/home/user/scripts"
mypid="$scriptdir/syncDir.pid"
inotifyPID="$scriptdir/inotify.pid"

if test -f $mypid
then
    if [ $# -eq 0 ]
    then
        echo "script already running"
	exit 0
    fi
    kill -9 `cat $mypid`
    sleep 2
    if test -f $inotifyPID
    then
        kill -9 `cat $inotifyPID`
    fi

    if [ $1 == "stop" ]
    then
	rm -f $mypid
        exit 0
    fi
fi

echo $$ > "$mypid"

trap "{ rm -f -- $mypid $inotifyPID; }" EXIT

inotifywait $localDir --exclude "/.sync/" -e move,close_write,create,delete &

ipid=$!
echo $ipid > "$inotifyPID"

while [ -e /proc/$ipid ]
do
    sleep 3
done


if ping -c1 $remoteHost 1>/dev/null
then
	cd $localDir &&	rsync -a -v $localDir $remoteUser@$remoteHost:$remoteDir --exclude "/.sync/" --delete
	echo "`date +%Y-%m-%d_%H:%M`: Successfully synced" > /home/user/scripts/syncDir.status
else
	echo "`date +%Y-%m-%d_%H:%M`: ERROR. Remote host is unreachable" > /home/user/scripts/syncDir.status
fi

exit 0


