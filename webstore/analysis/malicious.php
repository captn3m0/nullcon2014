<?php
ini_set('display_errors',1); 
error_reporting(E_ALL);

$mysql = new mysqli("localhost","root","nemoabhay","helios");
$extension_folder='/home/nemo/Dropbox/cctc2/src/webstore/chrome/unzipped/';
chdir($extension_folder);
$exclude_list = array(".","..");
$directories = array_diff(scandir('.'),$exclude_list);

//removed storage and notifications
$permission_list = array("activeTab" ,"background" ,"bookmarks" ,"chrome://favicon/" ,"clipboardRead" ,"clipboardWrite" ,"contentSettings" , "contextMenus" , "cookies" , "experimental" , "fileBrowserHandler" , "geolocation" , "history" , "idle" , "management" , "notifications" , "privacy" , "proxy" , "tabs" , "topSites" , "tts" , "ttsEngine" , "unlimitedStorage", "webNavigation" , "webNavigation" , "webRequest" , "webRequestBlocking");

$count = array();
for($i=0;$i<=23;$i++)
	$count[$i]=0;
$start =false;
foreach($directories as $directory){
	if($directory=='lpajfgbbghmckmgemicjlajifbgfhejf')
		$start=true;
	if(!$start)
		continue;
	$manifest_file=json_decode(file_get_contents($directory."/manifest.json"));
	if($manifest_file){
		$result=$mysql->query("SELECT * FROM `usage` WHERE `extension`='$directory'");
		$permissions_used=[];
		while($row=$result->fetch_array())
		{
			if($row[1])
				array_push($permissions_used,$row[1]);
		}
		if(isset($manifest_file->permissions)){
			$run=false;
			//print_r($manifest_file->permissions);
			foreach($manifest_file->permissions as &$perm)
				if(gettype($perm) == 'object')
					$run=true;
			//print_r($permissions_used);
			if($run)
				continue;
			$difference = array_diff(
				$manifest_file->permissions, 
				$permissions_used
			);
			//This line checks if the difference permissions are in the list of permissions or not.
			$difference = array_intersect($difference,$permission_list);
			$count[count($difference)]++;
			if(count($difference)>10)
				printf("***".$directory."\n");
		}
	}
	//print_r($count);
}
print_r($count);
?>
