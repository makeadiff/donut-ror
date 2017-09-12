<?php
require 'iframe.php';

/// One time run. Copy all the centers in Madapp to donut as groups so that people can be assigned to it and group together. Add verticals to it too. Basically prefill the groups data. Make a lot of groups.

$madapp = new Sql("Project_Madapp");
$donut = new Sql("Project_Donut");

$all_centers = $madapp->getAll("SELECT id,name,city_id FROM Center WHERE status='1' ORDER BY city_id");
$all_verticals = $madapp->getAll("SELECT id,name FROM Vertical");

$city_transilation = array(
		// Madapp City ID 		=> Donut City ID
		'26'	=> '25',
		'24'	=> '13',
		'1'		=> '44',
		'21'	=> '12',
		'13'	=> '21',
		'6'		=> '14',
		'10'	=> '3',
		'16'	=> '19',
		'25'	=> '24',
		'12'	=> '20',
		'23'	=> '18',
		'19'	=> '23',
		'11'	=> '17',
		'14'	=> '11',
		'20'	=> '22',
		'2'		=> '4',
		'4'		=> '9',
		'22'	=> '5',
		'15'	=> '8',
		'5'		=> '10',
		'3'		=> '15',
		'8'		=> '6',
		'18'	=> '16',
		'17'	=> '7',
		'29'	=> '25',
		'30'	=> '25',
		'31'	=> '25',
		'32'	=> '25',
	);
$done = array();

foreach ($all_centers as $row) {
	extract($row);
	$donut->insert("groups", array(
		'name'		=> $name,
		'city_id'	=> $city_transilation[$city_id]
	));
}


foreach ($all_verticals as $row) {
	extract($row);
	foreach ($city_transilation as $madapp_city_id => $donut_city_id) {
		if(isset($done[$id .'-'. $donut_city_id])) continue;
		$done[$id .'-'. $donut_city_id] = true;
		$donut->insert("groups", array(
			'name'		=> $name,
			'city_id'	=> $donut_city_id
		));
	}
}
