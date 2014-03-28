<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html lang="en">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<title>Code Builder</title>
	<script type="text/javascript" src="http://code.jquery.com/jquery-1.6.1.min.js"></script>
	<link rel="stylesheet" href="//code.jquery.com/ui/1.10.4/themes/smoothness/jquery-ui.css">
  <script src="//code.jquery.com/jquery-1.10.2.js"></script>
  <script src="//code.jquery.com/ui/1.10.4/jquery-ui.js"></script>

<!--Makes fields empty on page load-->
  <script type='text/javascript'>
		$(window).load(function(){
		$('#ScriptListName').prop('selectedIndex', -1)
		$('#ScriptCat').prop('selectedIndex', -1)
		})
</script>

<style type='text/css'>
    .left {
    width: 30%;
    float: left;
    text-align: right;
}
.right {
    width: 65%;
    margin-left: 10px;
    float:left;
}

  </style>

	

	<?php
	
	//include SQL formatter
	include "lib/SqlFormatter.php";
	
	//set inital variables -- ******************************MAKE MORE SECURE**************************************
	$dbhost = 'localhost:3306';
	$dbuser = 'codebuilder';
	$database = "test_db";
	$server = "127.0.0.1";
	$dbpassword = '';
	$db_handle = mysql_connect($dbhost, $dbuser);
	$db_found = mysql_select_db($database, $db_handle);
	$filename = 'test.txt';
	
	
	
 /*DECLARE PHP functions
	print_Loop($print) - Takes in a SQL statement string as $print and spits out colors
	print_All() - Prints all scripts with print all scripts button
	print_Selection($ScriptListName) - Prints script that is selected in select existing ****************PERHAPS AUTOSUGGEST?***************
	process_Upload($ScriptName, $filename) --
	
	
*/
	
	
	
/******* PRINT LooP FUNCTION **************/
//Print Loop Takes in a SQL statement, gets the table and spits out pretty SQL
					function print_Loop($print){
					$table = mysql_query("$print") or die(mysql_error());

					while($row = mysql_fetch_assoc($table)){
						echo"<div class='left'>Script Name: </div>";
						echo  "<div class='right'><b><font color='blue'>" . $row['script_name'] . "</font></b></div><br>";
						echo "<div class='left'>Category: </div>";
						echo "<div class='right'><b><font color='purple'>"  . $row['script_cat'] . "</font></b></div><br>";
						echo "<div class='left'>Sctipt ID: </div> ";
						echo"<div class='right'><b>" . $row['script_id'] . "</div></b><br>";
						echo "<B>SQL CODE :</B><BR><TABLE BORDER=1><TR><TD>" . SqlFormatter::format($row['script']) . "</TD></TR></TABLE><br><hr>";
						print "\r\n <br><br>";
					}
					}		
		
	
/******* PRINT ALL SCRIPTS FUNCTION **************/
//print each row from table, formatting sql
					function print_All(){
					$print = "SELECT * FROM script";
					print_Loop($print);

					}
					
		function print_Category($ScriptCat){
                     $ScriptCat= $_POST['ScriptCat'];
					$print = "SELECT * FROM script WHERE script_cat ='$ScriptCat'" ;
					print_loop($print);
					}					

/************* PRINT DROPDOWN SCRIPT SELECTON FUNCTION *****************/
//Two variables are from index.php POST of ScriptName textbox and the ScriptArrayIndex dropdown box
					function print_Selection($ScriptListName){

					$ScriptArrayIndex= $_POST['ScriptListName'];
					$print = "SELECT * FROM script WHERE script_id =" . $ScriptArrayIndex ;
					print_loop($print);
					}



/************* PROCESS UPLOAD FUNCTION *****************/
					function process_Upload($ScriptName, $filename){
					//Two variables are from index.php POST of ScriptName textbox and the ScriptArrayIndex dropdown box
					$ScriptName= $_POST['ScriptName'];
					$CategoryName =  $_POST['ScriptCat'];
					 
					 
					//This selects the highest (MAX) script_id and adds 1 to it, thus increasing the index.
					$highest_id = mysql_result(mysql_query("SELECT MAX(script_id) FROM script"), 0) + 1;	
									//echo $highest_id;
					   
					 //This gets the contents of the file
					 $content = file_get_contents($filename);
								//$content = stripslashes(file_get_contents("test.sql"));
								//echo $content;

					//Formats string. this allows for whole script file string to be input into DB
						$rule1=mysql_real_escape_string($content);
						

					//Insert script_name, script_cat and script into $highest_id for script_id, and script = $rule1 formatted string
					
						$query = "INSERT INTO script SET script_id = '" . $highest_id . "', script_name = '" . $ScriptName . "', script_cat= '" . $CategoryName . "',script = '" . $rule1 . "'";
						 mysql_query($query);
						 

					$print = "SELECT * FROM script WHERE script_id =" . $highest_id ;
					$table = mysql_query("$print") or die(mysql_error());

				print_Loop($print);

				
					}






/*$table = mysql_query("$print") or die(mysql_error());

while($row = mysql_fetch_assoc($table)){
	echo "Sctipt ID:" . $row['script_id'];
	echo "<br> Script Name: <b><font color='blue'>"  . $row['script_name'] . "</font></b<br>";
	echo "Script Category: "  . $row['script_cat'] . "<br>";
	echo "<B>SQL CODE :</B><BR><TABLE BORDER=1><TR><TD>" . SqlFormatter::format($row['script']) . "</TD></TR></TABLE><br><hr>";
    print "\r\n <br><br>";
}*/

?>

</head>
<body>

<?php


//<!--SELECT EXISTING DROPDOWN BOX BLOCK FORM START-->
echo "<p style='font-size:20px'>Select Existing Script: </p>
<form id='submit_dropdown' action='' method='post'>";

/******* SELECT EXISTING SCRIPT DROPDOWN BOX **********/
//select script_name and script_id from table script and populate the dropdown box
$sqlName = "SELECT script_name, script_id FROM script";
$result = mysql_query($sqlName) or die(mysql_error());
//Selected item =ScriptListName
echo "<select name='ScriptListName' id='ScriptListName'>";
//loop through rows and add script_name to dropdown option and set value to script_id
while($row = mysql_fetch_assoc($result)){
		echo "\r\n<option value='{$row['script_id']}'>{$row['script_name']}</option>";
        }
		echo '\r\n</select><input type="submit" value="Select Existing" id="submit_dropdown" name="submit_dropdown"></form>';
	
	
	
//*********CATEGORY SELECT DROPDOWN BOX****************/
echo 'Select by Category <form id="cat_dropdown" action="" method="post">';
		$sqlCat = "SELECT DISTINCT script_cat FROM script";
		$catResult = mysql_query($sqlCat) or die(mysql_error());

		echo "<select name='ScriptCat' id='ScriptCat'>";
		//loop through rows and add script_cat to dropdown option and set value to script_id
		while($row = mysql_fetch_assoc($catResult)){
				echo "\r\n<option value='{$row['script_cat']}'>{$row['script_cat']}</option>";
				}
				echo "\r\n</select>";


//echos the rest of the form elements - This is done instead of RAW HTML to put the elements above the Print submit interactions / upload printout
echo'<input type="submit" value="Select Category" id="submit_cat" name="submit_cat">
</form>


<hr>

<!-- Closes dropdown box form -->
<!--END SELECT EXISTING DROPDOWN BOX BLOCK-->

<!-- Upload Script Block - ScriptName textbox input to $ScriptName= $_POST["ScriptName"]; then add $ScriptName to script_name table column and set FileName as $filename to be read in -->

<form  enctype="multipart/form-data" id="submit_script" action="" method="post">
  <p style="font-size:20px">Upload script:</p>
  
  Select File: <input type="file" name="uploadFile" id="uploadFile" style="width:90%"/>
  <br>
  Save ScriptName as:
  <input type="text" name="ScriptName" id="ScriptName"/>
    <br>
		Enter or Select Category:
<input type="text" name="ScriptCat" list="catList"/>
    ';
	
	
	//*********************SELECT CATEGORY DROPDOWN SUGGEST/ENTRY
$sqlCat = "SELECT DISTINCT script_cat FROM script";
$result2 = mysql_query($sqlCat) or die(mysql_error());
	echo '<datalist id="catList">';
	while($row = mysql_fetch_assoc($result2)){
		echo "<option value='{$row['script_cat']}'</option>";
        }
		
	echo '

	</datalist>
		
		
<!--input id="autocomplete">
 
<script>
$( "#autocomplete" ).autocomplete({
  source: [ "c++", "java", "php", "coldfusion", "javascript", "asp", "ruby" ]
});
</script> -->
<br>
  <input name="submit_script" type="submit" value="Upload" id="submit_script">
</form>
<!-- END Upload Script Block-->

<br>
<hr>
<p style="font-size:20px">
Print All Scripts<br>
<!-- Print all scripts - uses function print_All() after submit of submit_all form-->
<form id="submit_all" action="" method="post">
  <input name="submit_all" value="Print All Scripts" type="submit">
</form>
</p>
<hr>
';


//PRINT INTERACTIONS / UPLOAD PRINTOUTS FROM BUTTON CLICKS
/****** PRINT ALL SCRIPTS************
Runs if Print All button is pushed*/
if (isset($_POST['submit_all']))
{
print_All();
}

/****** PROCESS UPLOAD************
Add file contents to DB and print out record*/
if (isset($_POST['submit_script']))
{
print "Received {$_FILES['uploadFile']['name']} - its size is {$_FILES['uploadFile']['size']}<br>";
move_uploaded_file ($_FILES['uploadFile'] ['tmp_name'], 
       "C:\Users\jcstin02\Desktop\local\HTML.PHP\htdocs\codebuilder\uploads/{$_FILES['uploadFile'] ['name']}");
	   
	   //$location='../uploads/{$_FILES["uploadFile"] ["name"]';
	   process_Upload($_POST['ScriptName'], "C:\Users\jcstin02\Desktop\local\HTML.PHP\htdocs\codebuilder\uploads/{$_FILES['uploadFile'] ['name']}");
}

/****** PRINT SELECTED DROPDOWN SCRIPT************
Print Selected dropdown script*/
if (isset($_POST['submit_dropdown']))
{
print_Selection($_POST['ScriptListName']);
}

if (isset($_POST['submit_cat']))
{
print_Category($_POST['ScriptCat']);
}
?>




<!-- HTML OF ECHO REPLACE "DASH-> to --<")
<input type="submit" value="Select Existing" id="submit_dropdown" name="submit_dropdown">
</form> <!-- Closes dropdown box form DASH->
<!--END SELECT EXISTING DROPDOWN BOX BLOCK DASH->

<br>

<!-- Upload Script Block - ScriptName textbox input to $ScriptName= $_POST['ScriptName'];
 then add $ScriptName to script_name table column and set FileName as $filename to be read in DASH->
<form id="submit_script" action="" method="post">
Upload script:
<br>
Save ScriptName as:
<input type="text" name="ScriptName" id="ScriptName">
<br>
<input name="submit_script" type="submit" value="Upload" id="submit_script">
</form>
<!-- END Upload Script Block DASH->

<br>
<!-- Print all scripts - uses function print_All() after submit of submit_all form DASH->
<form id="submit_all" action="" method="post">
<input name="submit_all" value="Print All Scripts" type="submit">
</form>
-->

</body>
</html>