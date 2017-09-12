<?php
require('iframe.php');
$config['db_host']	= 'localhost';
$config['db_user']	= 'root';
$config['db_password']='';
$config['site_url']	= 'http://localhost/makeadiff.in/home/makeadiff/public_html/';

$sql = new Sql($config['db_host'], $config['db_user'], $config['db_password'], 'Project_Donut');

$time_zone_offset = 12.5 * 60 * 60;
