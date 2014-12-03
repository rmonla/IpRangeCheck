IpRangeCheck
============

check the given IP ranges which were registered or not. (via Linux command `arping`) 


`` Usage: $(basename ${0}) --start IPADDR --end IPADDR 
   OR                      -s IPADDR  -e IPADDR ``


Examples
========
 
 1. ./ip_range_check.sh  --start 192.168.0.100 --end 192.168.0.200 -netmask 255.255.255.0
 2. check IP & MAC addresses in the "~/arping-test-result.log"
 3. MAC addresses lookup, http://aruljohn.com/mac.pl
 

