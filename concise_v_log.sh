#!/bin/bash

# The Script will extract detail from vertica.log based on SEARCH_PARAMS variable.
# Ensure that all the directory variables end with forward slash '/'

##-- Variables --##

# Date parameter
DAT=`date +%Y%m%d`

# Set Keywords to extract.
SEARCH_PARAMS='ERROR|FATAL|WARNING|FAILED|PANIC|shutdown'

# vertica.log location
LOG_DIR='/home/dbadmin/TestDB/v_testdb_node0001_catalog/'

# new log location
LOG_N_DIR='/home/dbadmin/TestDB/v_testdb_node0001_catalog/'

# File that will contain the log line data for future runs
# If the file doesnt exists, then create it with default value of 1
if [ ! -f ${LOG_N_DIR}.lin_num.dat ]; then
  touch ${LOG_N_DIR}.lin_num.dat
  echo 1 >${LOG_N_DIR}.lin_num.dat
fi

##-- Functions --##

log_me() {

  first_line=`cat ${LOG_N_DIR}.lin_num.dat`
  echo "First Line: $first_line"
  last_line=`sed -n '$=' ${LOG_DIR}vertica.log`
  echo "Last Line: $last_line"

  echo ${last_line} >${LOG_N_DIR}.lin_num.dat

  if [ ${last_line} -lt ${first_line} ]; then
    first_line=1
  fi

  sed -n ${first_line},${last_line}p ${LOG_DIR}vertica.log | egrep "${SEARCH_PARAMS}" >>${LOG_N_DIR}dba_vertica_${DAT}.log

}

##-- Main --##

log_me
