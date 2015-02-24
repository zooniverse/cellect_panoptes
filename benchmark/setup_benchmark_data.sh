#1. Create the set of data to benchmark with start with (locally or via fig)
#./benchmark/create_csv_data.rb
#fig run --rm --entrypoint=/bin/bash cellect -c "benchmark/create_csv_data.rb"

#2. create the db schema
fig run --rm --entrypoint=/bin/bash cellect -c "benchmark/create_db_schema.rb"

#3. load a set of User seens subjects for cellect
fig run --rm --entrypoint=/bin/bash cellect -c "benchmark/load_csv_data.rb"

#Power users to test cellect with for the current USS se
#3685,9616,4013,6538,1863

## TEST THE SERVER (see fig.yml for ports) using curl
#load subjects
#curl -s -H 'Accept: application/json' http://localhost:4000/workflows/1/status

#load a user seen set
#curl -s -H 'Accept: application/json' http://localhost:4000/workflows/1/users/2/load

#get some subjects for a user
curl -s -H 'Accept: application/json' http://localhost:4000/workflows/1?user_id=2


# TODO: simulate a peak real workload as it happens, i.e. 10K users hit the site
#       on day 3 with 5 Mil+ seen subjects for 500K subjects.
#       If cellect can handle that then we're looking good.
#       If not what can 1 mode handle and how many nodes do we need for the peak load.

#1. load a workflow for a user
#2. select some subjects for users.
#3. update seen subjects for users / simulate classifications coming down
