#!/bin/sh

# set -x # Modo de depuración
log_file=~/arping-test-result_$(date +%X).log

usage() {
   echo "Usage: $(basename "$0") --start IPADDR --end IPADDR"
   echo "  OR   $(basename "$0") -s IPADDR -e IPADDR"
   exit 1
}

ip_to_int() {
  IP="$1"
  A=$(echo "$IP" | cut -d. -f1)
  B=$(echo "$IP" | cut -d. -f2)
  C=$(echo "$IP" | cut -d. -f3)
  D=$(echo "$IP" | cut -d. -f4)
  INT=$((256 * 256 * 256 * A))
  INT=$((256 * 256 * B + INT))
  INT=$((256 * C + INT))
  INT=$((D + INT))
  echo "$INT"
}

int_to_ip() {
  INT="$1"
  D=$((INT % 256))
  C=$(((INT - D) / 256 % 256))
  B=$(((INT - C - D) / 65536 % 256))
  A=$(((INT - B - C - D) / 16777216 % 256))
  echo "${A}.${B}.${C}.${D}"
}

if [ $# -eq 0 ]; then
    usage
fi

while true;
do
    case "$1" in
      -s | --start)
          shift
          ip_start="$1"
      ;;
      -e | --end)
          shift
          ip_end="$1"
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

# Representación numérica de la dirección IP
ip_start_num=$(ip_to_int "$ip_start")
ip_end_num=$(ip_to_int "$ip_end")

# Limpiar el archivo de registro.
if [ -e "$log_file" ]; then
   rm -f "$log_file"
fi

# Realizar arping.
mac_regex='([0-9A-F]{2}[:-]){5}([0-9A-F]{2})'
offset=$((ip_end_num - ip_start_num))
for i in $(seq 0 "$offset");
do
    ip_num=$((ip_start_num + i))
    ip=$(int_to_ip "$ip_num")

    for mac in $(arping -c 1 "$ip" | grep -Eo "$mac_regex"); do
      echo "$ip<=>$mac" | tee -a "$log_file"
    done
    sleep 1
done

registered_ips_num=$(grep -E "$mac_regex" "$log_file" | wc -l)
echo "\n************************************************" | tee -a "$log_file"
echo "Scanning is finished." |  tee -a "$log_file"
echo "Total Scanned IPs=$((offset + 1)), where Registered IPs=$registered_ips_num" | tee -a "$log_file"
