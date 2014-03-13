<?php
$mysql = new mysqli("localhost","root","nemoabhay","helios");

$extension_folder='/home/nemo/Dropbox/cctc2/src/webstore/chrome/unzipped/';
chdir($extension_folder);

if(isset($_POST['url']))
{
	$url=explode("/",$_POST['url']);
	$extension_id=explode("?",$url[6])[0];
	
	$manifest_file=json_decode(file_get_contents($extension_id."/manifest.json"));
	echo "<h2>Permissions Being Asked: </h2><pre>";
	print_r($manifest_file->permissions);
	echo "</pre>";
	$result=$mysql->query("SELECT * FROM `usage` WHERE `extension`='$extension_id'");
	$permissions_used=[];
	while($row=$result->fetch_array())
	{
		if($row[1])
			array_push($permissions_used,$row[1]);
	}
	echo "<h2>Permissions Being Used: </h2><pre>";
	print_r($permissions_used);
	echo "</pre>";
	
	$difference = array_diff($manifest_file->permissions, $permissions_used);
	echo "<h2>Difference</h2><pre>";
	print_r($difference);
	echo "</pre>";
	
	if($result2->num_rows)
	{
		echo "<h2>The extension makes the following HTTP requests: </h2><pre>";
		$urls=array_map(function($x){return $x[0];},$result2->fetch_all());
		print_r($urls);
		echo "</pre>";
	}

}
else{
	//Show the box
	?>
	<h2>Chrome Webstore Extension Analysis</h2>
	<form method="POST">
		<input name="url" type="url">
		<input type="submit" value="Submit">
	</form>
	<?
}
