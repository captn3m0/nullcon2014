import json
import os

def return_keys(directory):

	keys = []
	try:
		f = open('manifest.json','r')
		manifest = f.read()
		try:
			json.loads(manifest)
			manifest = json.loads(manifest)
			#keys = manifest.keys();
			return manifest
		except ValueError:
			print "Invalid json at " + directory
			return 0
	except IOError:
		print "No manifest file found at " + directory
		return 0
	return keys
os.chdir('./unzipped')
directories = os.listdir('.')

keylist = []
i=0
for directory in directories:
	os.chdir('./' + directory)
	manifest = return_keys(directory)
	f = open('./helios.html','w+')
	if(manifest):
		if('permissions' in manifest):
			#converting the unicode to strings
			for x in range(len(manifest['permissions'])):
				manifest['permissions'][x] = str(manifest['permissions'][x])
			f.write(str(manifest['permissions'])+'\n')

		if('content_scripts' in manifest):
			if('matches' in manifest['content_scripts']):
				f2 = open('./helios.html','wa')
				for x in range(len(manifest['content_scripts']['matches'])):
					manifest['content_scripts']['matches'][x] = str(manifest['content_scripts']['matches'][x])
				f2.write(str(manifest['content_scripts']['matches']))

	os.chdir('..')
	i+=1
	if(i%100==0):
		print i

# for x in range(len(keylist)):
# 	keylist[x] = str(keylist[x])
# print keylist

# f = open('../keys.txt','r+')
# for x in keylist:
# 	f.write(x+'\n')