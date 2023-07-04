#!/bin/bash

#May be executed once on login, or may be called via cron.

#Don't confuse local and remote dir

remoteHost="main.remote.host"
remoteHost2="secondary.remote.host"
remoteUser="user"
remoteDir="/home/$remoteUser/SyncDir/"
#local user, used only in variables
user="user"
#dir to be synced
localDir="/home/$user/SyncDir/"
#path to this script dir
scriptdir="/home/$user/scripts"

logdir="/home/$user/.local"
myPID="$logdir/syncDir.pid"
inotifyPID="$logdir/inotify.pid"

if test -f $myPID
then
    if [ $# -eq 0 ]
    then
        echo "script already running"
        exit 0
    fi
    kill -9 `cat $myPID`
    sleep 2
    if test -f $inotifyPID
    then
        kill -9 `cat $inotifyPID`
    fi

    if [ $1 == "stop" ]
    then
        rm -f $myPID
        rm -f $inotifyPID
        exit 0
    fi
fi

echo $$ > "$myPID"

echo $inotifyPID

trap "{ rm -f -- $myPID $inotifyPID; }" EXIT

startwatch()
{
# see man inotify
# if need something to exclude, use --exclude eg: --exclude "/.sync/"
inotifywait $localDir -r -e move,close_write,create,delete &

ipid=$!
echo $ipid > "$inotifyPID"

while [ -e /proc/$ipid ]
do
    sleep 3
done

if ping -c1 $remoteHost 1>/dev/null
then
        cd $localDir         
        echo $PATH
        /usr/bin/rsync -avz $localDir $remoteUser@$remoteHost:$remoteDir --delete >> /home/$user/.local/syncDir.log
        echo "`date +%Y-%m-%d_%H:%M`: Successfully synced with $remoteHost" >> /home/$user/.local/syncDir.log
        if nc -z -w3 $remoteHost2 22 1>/dev/null
        then            
                cd $localDir
                /usr/bin/rsync -avz $localDir $remoteUser@$remoteHost2:$remoteDir --delete
                echo "`date +%Y-%m-%d_%H_%M`: Successfully synced with $remoteHost2" >> /home/$user/.local/syncDir.log
        fi
else
        echo "`date +%Y-%m-%d_%H_%M`: ERROR. Remote host $remoteHost is unreachable" >> /home/$user/.local/syncDir.log
        if nc -z -w3 $remoteHost2 22 1>/dev/null
        then
            cd $localDir 
            /usr/bin/rsync -a -v -z $localDir $remoteUser@$remoteHost2:$remoteDir --delete
            echo "`date +%Y-%m-%d_%H_%M`: Successfully synced with $remoteHost2" >> /home/$user/.local/syncDir.log
        else
            echo "`date +%Y-%m-%d_%H_%M`: ERROR. Remote host $remoteHost2 is unreachable" >> /home/$user/.local/syncDir.log
        fi
fi
startwatch      #recurse
}
startwatch
exit 0
