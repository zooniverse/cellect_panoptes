# cellect_panoptes
Zooniverse API specific Cellect server

# Development

Use the docker-compose tool to get started.

1. `docker-compose up`
2. Alternatively `docker-compose build cellect` && `docker-compose up`

# Testing

1. You'll need a database running to run the specs. Best bet is to use the docker-compose pg database as per development.
  + `docker-compose run -d --name postgres_cellect --service-ports postgres`
2. Once done you can use the DATABASE_URL env var to configure ActiveRecord.
  + `DATABASE_URL=postgresql://panoptes:panoptes@localhost:6000/cellect_panoptes_test`
3. Create the db using rake tasks and load the test schema (db/schema.rb)
  + `DATABASE_URL=postgresql://panoptes:panoptes@localhost:6000/cellect_panoptes_test rake db:setup`
4. Once all that is done you can run the specs via
  + `DATABASE_URL=postgresql://panoptes:panoptes@localhost:6000/cellect_panoptes_test rspec`

Don't forget to tear down the daemonized postgres container when your done.
