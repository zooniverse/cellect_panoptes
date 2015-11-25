
#1. Create the set of data to benchmark with start with (locally or via fig)
#./benchmark/create_csv_data.rb
docker-compose run --rm --entrypoint=/bin/bash cellect -c "benchmark/create_csv_data.rb"

#2. create the db schema
docker-compose run --rm --entrypoint=/bin/bash cellect -c "rake db:create"
docker-compose run --rm --entrypoint=/bin/bash cellect -c "benchmark/create_db_schema.rb"

#3. load a set of User seens subjects for cellect
docker-compose run --rm --entrypoint=/bin/bash cellect -c "benchmark/load_csv_data.rb"
