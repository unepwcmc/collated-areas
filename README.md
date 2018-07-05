# protectedplanet-pame

Please clone the project using git and then run the usual commands:
```
rails db:create
rails db:migrate
```


To import the data please run this command:
```
rake import:sites['lib/data/seed/PAME_Data-2018-06-27.csv']
```

Finally please run:
```
rails s
```
