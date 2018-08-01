#!/bin/sh
# Gaomingjie - Aug 2018

numargs=$#
i=1

HELP=false
USR=$USER
NEW_LOCAL_PAIR=false

IDRSA=id_rsa
BITS=1024
KEYTYPE="rsa"
PORT=22
PUBLIC_KEY=$HOME/.ssh/${IDRSA}.pub
PRIVATE_KEY=$HOME/.ssh/${IDRSA}

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

  if [ $j = "--newlocalpair" ] || [ $j = "-n" ]; then
     NEW_LOCAL_PAIR=true
     shift 1
     i=`expr $i + 1`
  fi

  if [ $j = "--logfile" ] || [ $j = "-l" ]; then
     LOGFILE=$2
     shift 1
     i=`expr $i + 1`
  fi

  if [ $j = "--port" ] || [ $j = "-p" ]; then
     PORT=$2
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

--newpair: the script will remove the old private/public local key files existing and create new ones

EOF
fi
#!------------------------------------!#
#                log                   #
#!------------------------------------!#
if [ -d "$LOGFILE" ]; then
  echo "$LOGFILE is a directory, setting logfile to $LOGFILE/SetupSSH_\`data\`.log"
  LOGFILE=$LOGFILE/SetupSSH_`date +%F-%H-%M-%S`.log
fi
echo "The output of this script is also logged into $LOGFILE" | tee -a $LOGFILE
if [ $? != 0 ]; then
    echo "Error writing to the logfile $LOGFILE, Exiting" | tee -a $LOGFILE
    exit 1
fi
#!------------------------------------!#
#               check                  #
#!------------------------------------!#
test -n "$HOST" || { echo "host is missing, use -h or --host to specify" | tee -a $LOGFILE; exit 1; }
test -n "$USR"  || { echo "user is missing, use -u or --user to specify" | tee -a $LOGFILE; exit 1; }
#!------------------------------------!#
#            check bins                #
#!------------------------------------!#
MISSING=false

SSH=`which ssh`
test -z $SSH_PATH || SSH=$SSH_PATH
command -v $SSH 1>/dev/null 2>&1 || { echo "ssh not found, please set the variable SSH_PATH" | tee -a $LOGFILE; MISSING=true; }

SCP=`which scp`
test -z $SCP_PATH || SCP=$SCP_PATH
command -v $SCP 1>/dev/null 2>&1 || { echo "scp not found, please set the variable SCP_PATH" | tee -a $LOGFILE; MISSING=true; }

SSH_KEYGEN=`which ssh-keygen`
test -z $SSH_KEYGEN_PATH || SSH_KEYGEN=$SSH_KEYGEN_PATH
command -v $SSH_KEYGEN 1>/dev/null 2>&1 || { echo "ssh-keygeb not found, please set the variable SSH_KEYGEN_PATH" | tee -a $LOGFILE; MISSING=true; }

PING=`which ping`
test -z $PING_PATH || PING=$PING_PATH
command -v $PING 1>/dev/null 2>&1 || { echo "ping not found, please set the variable PING_PATH" | tee -a $LOGFILE; MISSING=true; }

$MISSING && { exit 1; }
#!------------------------------------!#
#            check system              #
#!------------------------------------!#
platform=`uname -s`
case "$platform" in
  "Linux")  os=linux;;
        *)  echo "$platform is not supported" | tee -a $LOGFILE
            exit 1;;
esac
echo "Platform: $platform " | tee -a $LOGFILE
#!------------------------------------!#
#          check reachable             #
#!------------------------------------!#
echo "+-------------------------------------------+" | tee -a $LOGFILE
echo "|         Check host reachability           |" | tee -a $LOGFILE
echo "+-------------------------------------------+" | tee -a $LOGFILE
$PING -c 5 -w 5 $HOST                           | tee -a $LOGFILE
if [ $? = 0 ]; then
	echo "Remote host reachability check succeeded, $HOST are reachable" | tee -a $LOGFILE
else
	echo "Remote host reachability check failed, $HOST are not reachable" | tee -a $LOGFILE
	exit
fi
#!------------------------------------!#
#             local pair               #
#!------------------------------------!#
mkdir -p $HOME/.ssh                                                  | tee -a $LOGFILE
touch $HOME/.ssh/authorized_keys                                     | tee -a $LOGFILE
chmod 644 $HOME/.ssh/authorized_keys                                 | tee -a $LOGFILE
mv -f $HOME/.ssh/authorized_keys $HOME/.ssh/authorized_keys.tmp      | tee -a $LOGFILE
touch $HOME/.ssh/known_hosts                                         | tee -a $LOGFILE
chmod 644 $HOME/.ssh/known_hosts                                     | tee -a $LOGFILE 
mv -f $HOME/.ssh/known_hosts $HOME/.ssh/known_hosts.tmp              | tee -a $LOGFILE
echo "Host *" > $HOME/.ssh/config.tmp                                | tee -a $LOGFILE
echo "ForwardX11 no" >> $HOME/.ssh/config.tmp                        | tee -a $LOGFILE
if test -f $HOME/.ssh/config; then
	cp -f $HOME/.ssh/config $HOME/.ssh/config.backup                 | tee -a $LOGFILE
fi
mv -f $HOME/.ssh/config.tmp $HOME/.ssh/config                        | tee -a $LOGFILE
chmod 644 $HOME/.ssh/config                                          | tee -a $LOGFILE

if [ $NEW_LOCAL_PAIR = true ]; then
	echo "Remove old key pair on local host"                         | tee -a $LOGFILE
    rm -f $PRIVATE_KEY                                               | tee -a $LOGFILE
    rm -f $PUBLIC_KEY                                                | tee -a $LOGFILE
    echo "Run ssh-keygen on local host with empty passphrase"        | tee -a $LOGFILE
    echo "+-------------------------------------------+" | tee -a $LOGFILE
    echo "|               ssh-keygen                  |" | tee -a $LOGFILE
    echo "+-------------------------------------------+" | tee -a $LOGFILE
    $SSH_KEYGEN -t $KEYTYPE -b $BITS -f $HOME/.ssh/${IDRSA} -N ''    | tee -a $LOGFILE
elif [ -f $HOME/.ssh/${IDRSA}.pub ] && [ -f $HOME/.ssh/${IDRSA} ]; then
	echo "Use the local key pair that already exists"                | tee -a $LOGFILE
	continue
else
	echo "Key pair is missing, create new one on local host"         | tee -a $LOGFILE
    rm -f $PRIVATE_KEY                                               | tee -a $LOGFILE
    rm -f $PUBLIC_KEY                                                | tee -a $LOGFILE
    echo "Run ssh-keygen on local host with empty passphrase"        | tee -a $LOGFILE
    echo "+-------------------------------------------+" | tee -a $LOGFILE
    echo "|               ssh-keygen                  |" | tee -a $LOGFILE
    echo "+-------------------------------------------+" | tee -a $LOGFILE
    $SSH_KEYGEN -t $KEYTYPE -b $BITS -f $HOME/.ssh/${IDRSA} -N ''    | tee -a $LOGFILE
fi
echo "+-------------------------------------------+" | tee -a $LOGFILE
echo "|          Configure remote SSH             |" | tee -a $LOGFILE
echo "+-------------------------------------------+" | tee -a $LOGFILE
echo "[1]Creating .ssh directory and setting permissions on remote host $HOST"    | tee -a $LOGFILE
echo "[2]Add local public key to ~/.ssh/authorized_keys of remote host $HOST"     | tee -a $LOGFILE
echo "The user may be prompted for a password here"                               | tee -a $LOGFILE
$SSH -p $PORT -o StrictHostKeyChecking=no -x -l $USR $HOST "/bin/sh -c \"  mkdir -p .ssh ; chmod og-w . .ssh;   touch .ssh/authorized_keys .ssh/known_hosts;  chmod 644 .ssh/authorized_keys  .ssh/known_hosts; cp  .ssh/authorized_keys .ssh/authorized_keys.tmp ;  cp .ssh/known_hosts .ssh/known_hosts.tmp;echo `cat $PUBLIC_KEY` >> .ssh/authorized_keys; echo \\"Host *\\" > .ssh/config.tmp; echo \\"ForwardX11 no\\" >> .ssh/config.tmp; if test -f  .ssh/config ; then cp -f .ssh/config .ssh/config.backup; fi ; mv -f .ssh/config.tmp .ssh/config\""

if [ $? -eq 0 ]; then
	echo "Done with [1]creating .ssh directory and setting permissions on remote host $host"   | tee -a $LOGFILE
	echo "Done with [2]adding local public key to ~/.ssh/authorized_keys on remote host $host" | tee -a $LOGFILE
else
	echo "$SSH failed"
	exit 1
fi
#!------------------------------------!#
#              verify                  #
#!------------------------------------!#
echo "+-------------------------------------------+" | tee -a $LOGFILE
echo "|             Verify SSH setup              |" | tee -a $LOGFILE
echo "+-------------------------------------------+" | tee -a $LOGFILE
echo "Run 'date' command on the remote host using ssh to verify if ssh is setup correctly"   | tee -a $LOGFILE
echo "! IF THE SETUP IS CORRECTLY, THERE SHOULD BE ****NO OUTPUT OTHER THAN THE DATE****"  | tee -a $LOGFILE
echo "" | tee -a $LOGFILE
$SSH -l $USR $HOST "/bin/sh -c date"  | tee -a $LOGFILE
echo "" | tee -a $LOGFILE
echo "Verification complete, bye" | tee -a $LOGFILE




