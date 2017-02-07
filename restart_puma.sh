#!/bin/bash
# simple script to restart puma
# e.g. docker exec -it 'cellect_container_name' bash -c "/cellect_panoptes/restart_puma.sh"
PUMA_PROC_ID=$(ps aux | grep "puma [[:digit:]]" | awk '{print $2}')
kill -s SIGUSR2 $PUMA_PROC_ID
