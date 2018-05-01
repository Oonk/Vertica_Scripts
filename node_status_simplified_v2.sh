#!/usr/bin
#Script to send alerts when node is down.
#
# Specify recepient email id/s in the R_EMAIL_ID variable.
# Specify source email id/s in the S_EMAIL_ID variable.
# Specify Username in the USER variable.
# Specify the Password in the PSWD variable.


info()
{
cat <<EOF
  usage: $0 options

  Example:

  ./$0 -i 192.168.1.1


  #---------------------------------------------------------------------------------------------------#
  OPTIONS:
    -i <ip of current node>
                                                provide ip of current node to check database status.

    -h                  Help, show usage information
  #----------------------------------------------------------------------------------------------------#
EOF
}

CURRENT_IP=
#IP_LIST=

## Logging ------------------------------------#
LOG_DIR="/home/dbadmin"
DAT=`date +%y_%m_%d_%H_%M_%S`
LOG_SCRIPT="$LOG_DIR/VERTICA_NODE_CHECK_"$DAT".txt"
#LOG_SCRIPT="/home/dbadmin/VERTICA_NODE_CHECK_"$DAT".txt"
touch ${LOG_SCRIPT}

while getopts "i:h" OPTION
do
     case $OPTION in
         h)
             info
             exit 1
             ;;
         i)
             CURRENT_IP=$OPTARG
             ;;
         ?)
             info
             exit
             ;;
     esac
done

if [ -z "$CURRENT_IP" ]; then
    printf "\n  IP address for current server not provided...Please check the script usage:\n\n" >> $LOG_SCRIPT 2>&1
    printf "\n  IP address for current server not provided...Please check the script usage:\n\n"
    printf "\n  Command to get Complete Usage:\t sh $0 -h\n\n" >> $LOG_SCRIPT 2>&1
    printf "\n  Command to get Complete Usage:\t sh $0 -h\n\n"
    exit 0
fi

USER='dbadmin'
PSWD='elm0swirld'

#USER='dbadmin'
#PSWD='Vertica123'

S_EMAIL_ID='nithesh.k.poojary@gmail.com'
R_EMAIL_ID='nithesh.k.poojary@gmail.com'


## Functions ----------------------------------#


node_chk()
{

  rm -rf node_status_chk.txt

  /opt/vertica/bin/admintools -t list_allnodes >>node_status_chk.txt 2>&1

  node_status_chk=`cat node_status_chk.txt | egrep "DOWN" | wc -l`

  #echo $node_status_chk

  if [ $node_status_chk != 0 ]; then

      mail -s "One or More of the Nodes in Cluster are Down!" $R_EMAIL_ID -- -f $S_EMAIL_ID < node_status_chk.txt
          exit 1

  fi

}

## Function to get Epoch Delay Status---------------------------------#

epoch_Delay_Alert()
{
  #SELECT current_epoch - last_good_epoch FROM SYSTEM;
  #SELECT GET_CURRENT_EPOCH();
  #SELECT GET_LAST_GOOD_EPOCH()

  /opt/vertica/bin/vsql -U $USER -w $PSWD -h $1 -c "SELECT current_epoch - last_good_epoch FROM SYSTEM;" >epoch_delay_chk.txt 2>&1
  epoch_delay=$(cat epoch_delay_chk.txt | sed -n '3p')
  #echo $epoch_delay

  if (( $epoch_delay <= 10000 )); then

      mail -s "NOMINAL- Epoch Delay less than 10000." $R_EMAIL_ID -- -f $S_EMAIL_ID < epoch_delay_chk.txt

  elif (($epoch_delay > 10000)) && (($epoch_delay <= 20000)); then

      mail -s "WARNING- Epoch Delay greater than 10000." $R_EMAIL_ID -- -f $S_EMAIL_ID < epoch_delay_chk.txt

  elif ((${epoch_delay} > 20000)); then

      mail -s "CRITICAL- Epoch Delay greater than 20000." $R_EMAIL_ID -- -f $S_EMAIL_ID < epoch_delay_chk.txt

  fi

}

## Main

if ! type /opt/vertica/bin/vsql > /dev/null 2>&1; then

    USER=`whoami`
    printf "\n  The 'vsql' utility is not found!\n  You are logged in as $USER.\n\n" >>$LOG_SCRIPT 2>&1
    mail -s "Node Down  - `hostname`" $R_EMAIL_ID -- -f $S_EMAIL_ID < $LOG_SCRIPT
    exit 0

else

    node_chk
    epoch_Delay_Alert $CURRENT_IP

fi
