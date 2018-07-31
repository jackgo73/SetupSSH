#!/bin/sh
# Gaomingjie - Aug 2018

numagrs=$#
i=1

HELP=false
USR=$USER

LOGFILE=/tmp/SetupSSH_`date +%F-%H-%M-%S`.log

while [ $i -le $numargs ]; do
	echo 'a'
done

# while [ $i -le $numargs ]; do
#   j=$1 
  # if [ $j = "--host" ] || [ $j = "-h" ]; then
  #    HOST=$2
  #    shift 1
  #    i=`expr $i + 1`
  # fi

  # if [ $j = "--user" ] || [ $j = "-u" ]; then
  #    USR=$2
  #    shift 1
  #    i=`expr $i + 1`
  # fi

  # if [ $j = "--logfile" ] || [ $j = "-l" ]; then
  #    LOGFILE=$2
  #    shift 1
  #    i=`expr $i + 1`
  # fi

  # if [ $j = "--help" ]; then
  #    HELP=true
  # fi

  # i=`expr $i + 1`
  # shift 1
# done


if [ $HELP = true ]; then
cat < EOF 
asdad
sdfsfd
ewrrew

EOF
fi


