#!/bin/bash
curl_prefix="http://localhost:4000/workflows/1"
declare -a power_users=("3685" "9616" "4013" "6538" "1863")

#load subjects for the workflow
time curl -H 'Accept: application/json' "${curl_prefix}/status"
time curl -H 'Accept: application/json' "${curl_prefix}/reload"


#load all power users seen sets
for i in "${power_users[@]}"; do
  time curl -X POST -H 'Accept: application/json' "${curl_prefix}/users/$i/load"
done

# get some subjects for the power users
for i in "${power_users[@]}"; do
  time curl -H 'Accept: application/json' "${curl_prefix}/?user_id=$i"
done

#load a thousand empty users and select over them
for i in {1..1000}; do
  time curl -X POST -H 'Accept: application/json' "${curl_prefix}/users/$i/load"
  time curl -H 'Accept: application/json' "${curl_prefix}/?user_id=$i"
done
