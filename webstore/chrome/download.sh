#!/bin/bash
mkdir -p crx
mkdir -p unzipped
while read str
do
	id=${str:${#str}-32:32}
    downloadUrl="https://clients2.google.com/service/update2/crx?response=redirect&os=linux&arch=x64&nacl_arch=x86-64&prod=chromecrx&prodchannel=stable&prodversion=32.0.1700.102&x=id%3D$id%26installsource%3Dondemand%26lang%3Den-US%26uc"
    echo $str
	if [ ! -d "unzipped/$id" ]; then
		wget -q "$downloadUrl" -O crx/$id.crx --referer="$str" -U "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/32.0.1700.102 Safari/537.36" >/dev/null 2>&1
		
		#mkdir unzipped/$id
		#-qq = quiet
		#-d  = directory
		#-n  = never overwrite
		unzip -n -q crx/$id.crx  -d unzipped/$id/
	fi
done < extensions.new.txt
