# RelationshipCalc


# Server 

Default port: 3000

To run server in dev mode:
```
sudo rails server -e development
```


# Generating API:

```
sudo rails g controller api/v1/names index show --no-helper --no-assets --no-template-engine --no-test-framework
sudo rails g controller api/v1/relations index show --no-helper --no-assets --no-template-engine --no-test-framework
sudo rails g controller api/v1/formulas index show --no-helper --no-assets --no-template-engine --no-test-framework

sudo rails g model marriage husband:string wife:string --no-helper --no-assets --no-template-engine --no-test-framework
sudo rails g model parent parent:string child:string --no-helper --no-assets --no-template-engine --no-test-framework
sudo rails g model person name:string gender:string --no-helper --no-assets --no-template-engine --no-test-framework
sudo rails g model relation relative:string dependant:string relation:string --no-helper --no-assets --no-template-engine --force --no-test-framework
sudo rails g model formulas formulas:string name:string  --no-helper --no-assets --no-template-engine --force --no-test-framework

rake db:create
rake db:migrate
rake db:seed
```


