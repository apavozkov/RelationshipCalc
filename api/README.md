# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...

Generating API:

sudo rails g controller api/v1/names index show --no-helper --no-assets --no-template-engine --no-test-framework
sudo rails g controller api/v1/relations index show --no-helper --no-assets --no-template-engine --no-test-framework
sudo rails g model person name:string gender:string --no-helper --no-assets --no-template-engine --no-test-framework
sudo rails g model relation relative:string dependant:string relation:string --no-helper --no-assets --no-template-engine --force --no-test-framework
rake db:create
rake db:migrate
rake db:seed

https://stackoverflow.com/questions/69754628/psql-error-connection-to-server-on-socket-tmp-s-pgsql-5432-failed-no-such