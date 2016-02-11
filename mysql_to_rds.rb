require 'fileutils'
#1.Get source and target details and Check the size of the tables.
#2.Pick tables greater than 2GB and Dump csv format tables only picked
#3.Get dump of entire DB with no data structure and import it into target.
#4 Exclude picked tables and dump the entire source DB.
#5 import the source DB into the target.
#6 run mysqlimport process on big tables later
#7 check for errors

start_time = Time.now
source = {:user => '',:password=>'',:dbhost=>'',:dbname=>''}
target = {:user => '',:password=>'',:dbhost=>'',:dbname=>''}
DUMP_DIR  = ''


def mysql_login(db)
  "-u #{db[:user]} -p#{db[:password]} -h#{db[:dbhost]}"
end

def get_large_tables(db)
  query= 'select table_name from information_schema.tables where data_length/1024/1024 >= 2000'
   `mysql #{mysql_login(db)} --skip-column-names -e "#{query}"`.split("\n")
end

def benchmark(label = nil)
  puts label unless label.nil?
  before=Time.now
  yield
  after=Time.now
  puts "Took %.3fs" % (after - before)
end

def dump_big_tables(db)
  unless !DUMP_DIR.nil?
  tables=get_large_tables(db)
  dir="#{DUMP_DIR}/#{db[:dbname]}"
  FileUtils.mkdir_p(dir)
  tables.each do |tab|
    benchmark("DB #{db[:dbname]}, table #{tab}") do
    `mysql #{mysql_login(db)} #{db[:dbname]} --batch -e "select * from #{tab}"| sed 's/\\t/","/g;s/^/"/;s/$/"/;s/\\n//g' > #{dir}/#{tab}.csv`
        end
  end
end

def dump_tables(db)
  excluded_tab=get_large_tables(db)
  unless !DUMP_DIR.nil?
  dir="#{DUMP_DIR}"
  ignoretables=excluded_tab.map {|tab| "--ignore-table=#{db[:dbname]}.#{tab}  "}
 `mysqldump #{mysql_login(db)} #{db[:dbname]} #{ignoretables}  > #{dir}/#{db[:dbname]}/#{db[:dbname]}.sql`
 `mysqldump #{mysql_login(db)} --no-data #{db[:dbname]} > #{dir}/#{db[:dbname]}/#{db[:dbname]}_nodata.sql`
 end
end

def import_all_tables(source,target)
  unless !DUMP_DIR.nil?
   dir="#{DUMP_DIR}"
  `mysql #{mysql_login(target)} #{target[:dbname]} <  #{dir}/#{source[:dbname]}/#{db[:dbname]}_nodata.sql`
  `mysql #{mysql_login(target)} #{target[:dbname]} <  #{dir}/#{source[:dbname]}/#{db[:dbname]}.sql`
  end
end

def backup_source_db(db)
  unless !DUMP_DIR.nil?
   dir="#{DUMP_DIR}"
  `mysqldump #{mysql_login(db)}  #{db[:dbname]} > #{dir}/#{db[:dbname]}/#{db[:dbname]}_source.sql`
  end
end
def import_big_tables(source,target)
  unless !DUMP_DIR.nil?
  dir="#{DUMP_DIR}"
  excluded_tab=get_large_tables(source)
  excluded_tab.each do |tab|   
  `mysqlimport --local #{mysql_login(target)} #{target[:dbname]} --ignore-lines=1 --fields-terminated-by=',' --fields-enclosed-by='"'  --lines-terminated-by='\n' --use-threads=6  #{DUMP_DIR}/#{source[:dbname]}/#{tab}.csv`
  end
  end
end

def dump_initiate(source,target)
  benchmark('Dump complete')
  get_large_tables(source)
  dump_big_tables(source)
  dump_tables(source)
  backup_source_db(source)
  benchmark('Import initate')
  import_all_tables(source,target)
  import_big_tables(source,target)
end


puts import_big_tables(source,target)






