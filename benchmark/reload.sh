#!/bin/bash
curl_prefix="http://localhost:4000/workflows/1"

#load subjects for the workflow
time curl -v -H 'Accept: application/json' "${curl_prefix}/status"

time curl -v -X POST -H 'Accept: application/json' "${curl_prefix}/reload"
