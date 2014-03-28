<?php
include('index.php');

//Datbase connection info
$dbhost = 'localhost:3306';
$dbuser = 'codebuilder';
$database = "test_db";
$server = "127.0.0.1";
$dbpassword = '';
$db_handle = mysql_connect($dbhost, $dbuser);
$db_found = mysql_select_db($database, $db_handle);
//filename of file to add to DB
$filename = 'test.txt';

//Two variables are from index.php POST of ScriptName textbox and the ScriptArrayIndex dropdown box
$ScriptName= $_POST['ScriptName'];
//$ScriptArrayIndex= $_POST['ScriptListName'];

/*print Script Array Index, The script name and the Array value of the index
echo $ScriptArrayIndex;
echo "<br>";
echo $ScriptName;
echo "<br><br><hr>";
*/
//echo "$code[$ScriptArrayIndex] <br>";
  
  
//This selects the highest (MAX) script_id and adds 1 to it, thus increasing the index.
$highest_id = mysql_result(mysql_query("SELECT MAX(script_id) FROM script"), 0) + 1;	
				//echo $highest_id;
 
 
 //This gets the contents of the file
 $content = file_get_contents($filename);
 			//$content = stripslashes(file_get_contents("test.sql"));
			//echo $content;

//Formats string. this allows for whole script file string to be input into DB
    $rule1=mysql_real_escape_string($content);
	

//Insert script into $highest_id for script_id and script = $rule1 formatted string
    $query = "INSERT INTO script SET script_id = '" . $highest_id . "', script_name = '" . $ScriptName . "', script = '" . "$rule1" . "'";
     mysql_query($query);
	 

$print = "SELECT * FROM script WHERE script_id =" . $highest_id ;
$table = mysql_query("$print") or die(mysql_error());

while($row = mysql_fetch_assoc($table)){
	echo "Sctipt ID:" . $row['script_id'];
	echo "<br> Script Name: "  . $row['script_name'] . "<br>";
	echo "<B>SQL CODE :</B><BR><TABLE BORDER=1><TR><TD>" . SqlFormatter::format($row['script']) . "</TD></TR></TABLE><br><hr>";
    print "\r\n <br><br>";
}

	 
	/* 
	 //Print all Scripts from script table
$print = "SELECT * FROM script";
$table = mysql_query("$print") or die(mysql_error());

//orint each row from table, formatting sql
while($row = mysql_fetch_assoc($table)){
	echo "Sctipt ID:" . $row['script_id'];
	echo "<br> Script Name: "  . $row['script_name'] . "<br>";
	echo "<B>SQL CODE :</B><BR><TABLE BORDER=1><TR><TD>" . SqlFormatter::format($row['script']) . "</TD></TR></TABLE><br><hr>";
    print "\r\n <br><br>";
}
 ****/


mysql_close($db_handle);



?>