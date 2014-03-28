<?php
include('index.php');

//Datbase connection info
$dbhost = 'localhost:3306';
$dbuser = 'codebuilder';
$database = "test_db";
$server = "127.0.0.1";
$db_handle = mysql_connect($dbhost, $dbuser);
$db_found = mysql_select_db($database, $db_handle);

//filename of file to add to DB
$filename = 'test.txt';


//Two variables are from index.php POST of ScriptName textbox and the ScriptArrayIndex dropdown box

$ScriptArrayIndex= $_POST['ScriptListName'];
$print = "SELECT * FROM script WHERE script_id =" . $ScriptArrayIndex ;
$table = mysql_query("$print") or die(mysql_error());

while($row = mysql_fetch_assoc($table)){
	echo "Sctipt ID:" . $row['script_id'];
	echo "<br> Script Name: "  . $row['script_name'] . "<br>";
	echo "<B>SQL CODE :</B><BR><TABLE BORDER=1><TR><TD>" . SqlFormatter::format($row['script']) . "</TD></TR></TABLE><br><hr>";
    print "\r\n <br><br>";
}
 


mysql_close($db_handle);



?>