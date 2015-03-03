#!/bin/bash
# simple script to restart puma
# e.g. docker exec -it 'cellect_container_name' bash -c "/cellect_panoptes/restart_puma.sh"
kill -s SIGUSR2 `ps aux | grep [p]uma | awk '{print $2}'`
