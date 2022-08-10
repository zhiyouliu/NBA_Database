<?php

$dbhost = "dbase.cs.jhu.edu";
$dbuser = "21fa_zliu167";
$dbpass = "nNr0Drnalv";
$conn = mysqli_connect($dbhost, $dbuser, $dbpass);
//Database connection



if (!$conn) {
die ("Error connecting to mysql");
}
else{

$dbname = "21fa_zliu167_db"; 
mysqli_select_db($conn,$dbname);

// connect to my own database

$D = $_POST['D'];
$HOMEABB = $_POST['HOMEABB'];
$AWAYABB = $_POST['AWAYABB'];
// $str variable obtained as an input to PHP


$query = mysqli_multi_query($conn, "CALL makeprediction('".$D."','".$HOMEABB."','".$AWAYABB."')");


if( $query ) 
{ 
  do { 
    if( $result = mysqli_store_result( $conn ) ) 
    { 
      echo "<br>";
      echo("<table border='1'>");

      $first_row = true;
        while ($row = mysqli_fetch_assoc($result)) {
          if ($first_row) {
            $first_row = false;
            // Output header row from keys.
            echo '<tr>';
            foreach($row as $key2 => $field2) {
                echo '<th>' . htmlspecialchars($key2)  . '</th>';
            }
            echo '</tr>';
        }
        echo '<tr>';
        foreach($row as $key => $field) {
            echo '<td>' . htmlspecialchars($field) . '</td>';
        }
        echo '</tr>';
      }
    }
        echo("</table>");
    //     if ($conn->more_results()) {
    //       printf("-----------------\n");
    //   }
    } while ($conn->next_result()); 
}  

mysqli_close( $conn ); 


}

?>