#!/bin/bash

set -x #debug mode
log_file=~/arping-test-result_"$(date +%X)".log

function usage() {
   echo -e "Usage: $(basename ${0}) --start IPADDR --end IPADDR"
   echo -e "  OR   $(basename ${0}) -s IPADDR -e IPADDR"
   1>&2; exit 1;
}


function ip_to_int() {
  local IP="${1}"
  local A=$(echo ${IP} | cut -d. -f1)
  local B=$(echo ${IP} | cut -d. -f2)
  local C=$(echo ${IP} | cut -d. -f3)
  local D=$(echo ${IP} | cut -d. -f4)
  local INT

  INT=$(expr 256 "*" 256 "*" 256 "*" ${A})
  INT=$(expr 256 "*" 256 "*" ${B} + ${INT})
  INT=$(expr 256 "*" ${C} + ${INT})
  INT=$(expr ${D} + ${INT})

  echo ${INT}
}

function int_to_ip() {
  local INT="${1}"
  local D=$(expr ${INT} % 256)
  local C=$(expr '(' ${INT} - ${D} ')' / 256 % 256)
  local B=$(expr '(' ${INT} - ${C} - ${D} ')' / 65536 % 256)
  local A=$(expr '(' ${INT} - ${B} - ${C} - ${D} ')' / 16777216 % 256)

  echo "${A}.${B}.${C}.${D}"
}

if [ $# -eq 0 ]; then
    usage
fi

while true;
do
    case "${1}" in
      -s | --start)
          shift
          ip_start=${1}
      ;;
      -e | --end)
          shift
          ip_end=${1}
      ;;
      -h | ? | --help)
          usage
      ;;
      *)
          break
      ;;
    esac
    shift
done

# IP Addr Number Representation
ip_start_num=$(ip_to_int ${ip_start})
ip_end_num=$(ip_to_int ${ip_end})

# clean log file.
if [ -e ${log_file} ];then
   rm -f ${log_file}
fi

# arping it.
offset=$(expr ${ip_end_num} - ${ip_start_num})
for i in $(seq 0 ${offset});
do
    ip_num=$(expr ${ip_start_num} + ${i})
    ip=$(int_to_ip ${ip_num})
    arping -c 1 ${ip} | tee -a ${log_file}
    sleep 1
done
