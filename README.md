<snippet>
  <content>
##Mysql large db migration
Faster way to migrate large mysql db's from on server to another.Source,Target & Dump_dir location have to be specified.
This script skips traditional way of mysqldump process as the traditional one uses single thread process for completing the task.Script checks for tables greater than 2GB in size and export them out in csv format  table by table basis and imports in using mysqlimport process where we could pass in thread counts back.
## Installation
Download the mysql_to_rds.rb file
### Usage
####Provide required paramters
``` 
source = {:user => '',:password=>'',:dbhost=>'',:dbname=>''}
target = {:user => '',:password=>'',:dbhost=>'',:dbname=>''}
DUMP_DIR  = ''

ruby mysql_to_rds.rb
```

###Disclaimer
I used this regularly.Wouldn't say this is completely tested ,please use at your own risk.


</content>
</snippet>

