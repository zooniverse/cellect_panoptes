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

# TODO: simulate a peak real workload as it happens, i.e. 10K users hit the site
#       on day 3 with 5 Mil+ seen subjects for 500K subjects.
#       If cellect can handle that then we're looking good.
#       If not what can 1 mode handle and how many nodes do we need for the peak load.

#1. load a workflow for a user
#2. select some subjects for users.
#3. update seen subjects for users / simulate classifications coming down
