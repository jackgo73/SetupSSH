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

if [ -d $LOGFILE ]; then
  echo $LOGFILE is a directory, setting logfile to $LOGFILE/SetupSSH_date.log
  LOGFILE=$LOGFILE/SetupSSH_`date +%F-%H-%M-%S`.log
fi
echo The output of this script is also logged into $LOGFILE | tee -a $LOGFILE

if [ `echo $?` != 0 ]; then
    echo Error writing to the logfile $LOGFILE, Exiting
    exit 1
fi

