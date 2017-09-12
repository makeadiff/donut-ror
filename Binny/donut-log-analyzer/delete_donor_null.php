<?php

require('common.php');

$sql->execQuery("DELETE FROM `donations` WHERE `donour_id` IS NULL");

echo "Done";


?>


