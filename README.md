This file helpes in faster DB migration from one mysql DB to anotheri mysql only.
Source,Target & Dump_dir location have to be specified.
This script skips traditional way of mysqldump process as the traditional one uses single thread process for completing the task.Script checks for tables greater than 2GB in size and export them out in csv format  table by table basis and imports back accordingly.

--Script usage
Following paramters required
source = {:user => '',:password=>'',:dbhost=>'',:dbname=>''}
target = {:user => '',:password=>'',:dbhost=>'',:dbname=>''}
DUMP_DIR  = ''


ruby mysql_to_rds.rb 

