<?php

ini_set('error_reporting', E_ALL);
ini_set('display_errors', true);
// display errors


$dbhost = "dbase.cs.jhu.edu";
$dbuser = "21fa_xtao10";
$dbpass = "9ySMlEGvuO";
$conn = mysqli_connect($dbhost, $dbuser, $dbpass);
//Database connection



if (!$conn) {
die ("Error connecting to mysql");
}
else{

$dbname = "21fa_xtao10_db";
mysqli_select_db($conn,$dbname);

// connect to my own database

$year = $_POST['year'];
// $str variable obtained as an input to PHP


$result = mysqli_query($conn, "CALL list_avg_salary('$year')");
if ($result->num_rows < 1){
	DIE("DATA NOT FOUND, TRY ENTER WITHIN THE RANGE");
}



echo "<br>";
echo("<table border='1'>");
$first_row = true;
while ($row = mysqli_fetch_assoc($result)) {
    if ($first_row) {
        $first_row = false;
        // Output header row from keys.
        echo '<tr>';
        foreach($row as $key => $field) {
            echo '<th>' . htmlspecialchars($key) . '</th>';
        }
        echo '</tr>';
    }
    echo '<tr>';
    foreach($row as $key => $field) {
        echo '<td>' . htmlspecialchars($field) . '</td>';
    }
    echo '</tr>';
}
echo("</table>");

}
?>

