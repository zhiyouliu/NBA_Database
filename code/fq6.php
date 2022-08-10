<?php

$conn = new mysqli("dbase.cs.jhu.edu", "21fa_zliu167", "nNr0Drnalv", "21fa_zliu167_db" );

if (mysqli_connect_error()) {
  printf("Error");
  exit();
}
// printf("Success connection");




if($query = $conn->multi_query("CALL heightweightstats();"))

{
do{
  if($result = $conn->store_result()){
    if($array = $result->fetch_fields()){
      echo("<table border='1'>");
      echo '<tr>';
      printf("<th>%s</th><th>%s</th>",
      $array[0]->name, $array[1]->name);
      echo '</tr>';
    }
    
    while ($row = $result->fetch_row()){
      echo '<tr>';
      printf("<th>%s</th><th>%s</th>",
      $row[0],$row[1]);
      echo '</tr>';
    }
    $result->close();
  }

  if($conn->more_results()){
    printf("---------------------");
  }
}while($conn->next_result());
}
else{
  printf("ERROR IN ENTERED INFORMATION: SSN should be 4-digit number OR NewScore not satisfy input type");
}
mysqli_close($conn);

?>



