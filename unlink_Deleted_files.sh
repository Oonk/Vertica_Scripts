#!/usr/bin

printf "\nTotal and Available size of disk on the Server:\n\n"
df -Th

printf "\nFollowing is the list of deleted logs/files which are still linked to a process:\n\n"
lsof -F sn0 | tr -d '\000' | grep deleted | sed 's/^[a-z]*\([0-9]*\)n/\1 /' | sort -n | tail

file_list=`lsof -F sn0 | tr -d '\000' | grep deleted | sed 's/^[a-z]*\([0-9]*\)n/\1 /' | sort -n | tail | cut -d ' ' -f 2 | uniq`
#echo $file_list

for log in $file_list
do
    printf "\nFiles with PID details:\n\n"
    lsof -a +L1 / | grep $log | head
    printf "\n"
    
    pid=`lsof -a +L1 / | grep $log | head | awk '{ print $2; }'`
    file=`lsof -a +L1 / | grep $log | head | awk '{ print $10; }'`
    
    for i in $pid
    do
        #pidecho $i | awk "{$1}"`
        echo "/proc/${i}/fd"
    done

done
