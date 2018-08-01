#!/bin/sh
# Gaomingjie - Aug 2018

numargs=$#
i=1

HELP=false
USR=$USER

LOGFILE=/tmp/SetupSSH_`date +%F-%H-%M-%S`.log



while [ $i -le $numargs ]; do
  j=$1 
  if [ $j = "--host" ] || [ $j = "-h" ]; then
     HOST=$2
     shift 1
     i=`expr $i + 1`
  fi

  if [ $j = "--user" ] || [ $j = "-u" ]; then
     USR=$2
     shift 1
     i=`expr $i + 1`
  fi

  if [ $j = "--logfile" ] || [ $j = "-l" ]; then
     LOGFILE=$2
     shift 1
     i=`expr $i + 1`
  fi

  if [ $j = "--help" ]; then
     HELP=true
  fi

  i=`expr $i + 1`
  shift 1
done


if [ $HELP = true ]; then
cat << EOF 
add
some help
here
...
$HOME
...
EOF
fi

#!------------------------------------!#
#                func                  #
#!------------------------------------!#
log() {
    echo -e "[LOG]$*" | tee -a $LOGFILE
}

logfailed() {
    echo -e "\033[33m[LOG]$*\033[0m" | tee -a $LOGFILE
}

logsuccess() {
    echo -e "\033[34m[LOG]$*\033[0m" | tee -a $LOGFILE
}

#!------------------------------------!#
#               check                  #
#!------------------------------------!#
test -n "$HOST" || { logfailed "host is missing, use -h or --host to specify"; exit 1; }
test -n "$USR"  || { logfailed "user is missing, use -u or --user to specify"; exit 1; }


#!------------------------------------!#
#                log                   #
#!------------------------------------!#
if [ -d "$LOGFILE" ]; then
  echo "$LOGFILE is a directory, setting logfile to $LOGFILE/SetupSSH_\`data\`.log"
  LOGFILE=$LOGFILE/SetupSSH_`date +%F-%H-%M-%S`.log
fi
log "The output of this script is also logged into $LOGFILE" 
if [ $? != 0 ]; then
    logfailed "Error writing to the logfile $LOGFILE, Exiting"
    exit 1
fi
#!------------------------------------!#
#            check bins                #
#!------------------------------------!#
MISSING=false

SSH=`which ssh`
test -z $SSH_PATH || SSH=$SSH_PATH
command -v $SSH 1>/dev/null 2>&1 || { logfailed "ssh not found, please set the variable SSH_PATH"; MISSING=true; }

SCP=`which scp`
test -z $SCP_PATH || SCP=$SCP_PATH
command -v $SCP 1>/dev/null 2>&1 || { logfailed "scp not found, please set the variable SCP_PATH"; MISSING=true; }

SSH_KEYGEN=`which ssh-keygen`
test -z $SSH_KEYGEN_PATH || SSH_KEYGEN=$SSH_KEYGEN_PATH
command -v $SSH_KEYGEN 1>/dev/null 2>&1 || { logfailed "ssh-keygeb not found, please set the variable SSH_KEYGEN_PATH"; MISSING=true; }

PING=`which ping`
test -z $PING_PATH || PING=$PING_PATH
command -v $PING 1>/dev/null 2>&1 || { logfailed "ping not found, please set the variable PING_PATH"; MISSING=true; }

$MISSING && { exit 1; }
#!------------------------------------!#
#            check system              #
#!------------------------------------!#
platform=`uname -s`
case "$platform" in
  "Linux")  os=linux;;
        *)  logfailed "$platform is not supported"
            exit 1;;
esac
log "Platform: $platform "
#!------------------------------------!#
#          check reachable             #
#!------------------------------------!#
$PING -c 5 -w 5 $HOST
if [ $? = 0 ]; then
	logsuccess "Remote host reachability check succeeded, $HOST are reachable"
else
	logfailed "Remote host reachability check failed, $HOST are not reachable"
	exit
fi

