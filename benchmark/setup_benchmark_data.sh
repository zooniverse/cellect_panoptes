
#1. Create the set of data to benchmark with start with (locally or via fig)
docker-compose run --rm --entrypoint=/bin/bash cellect -c "bundle exec benchmark/create_csv_data.rb"

#2. create the db schema
docker-compose run --rm --entrypoint=/bin/bash cellect -c "bundle exec rake db:setup"

#3. load a set of User seens subjects for cellect
docker-compose run --rm --entrypoint=/bin/bash cellect -c "bundle exec benchmark/load_csv_data.rb"
