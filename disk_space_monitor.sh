#!/usr/bin

if [ "$#" -ne 1 ]; then
    printf "\n\tUsage: sh $0 "/dev/sdg2" \n"
    exit
fi

FROM_EMAIL='nithesh.k.poojary@gmail.com'
TO_EMAIL='nithesh.k.poojary@gmail.com'
HOST=`hostname`

Filesystem=$1
util_percent=`df -Th | grep ${Filesystem} | awk {'print $6'} | cut -d '%' -f 1`
location=`df -Th | grep ${Filesystem} | awk {'print $7'} `

if (( ${util_percent} > 85 ));then

    #printf "\n\tAlert: Current disk Utilization is ${util_percent} Percentage. \n\n"
    echo " " | mailx -s "Alert: Current disk Utilization is ${util_percent} Percentage in ${HOST} on directory ${location}." -r $FROM_EMAIL $TO_EMAIL


fi

