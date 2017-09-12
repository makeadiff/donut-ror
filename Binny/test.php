<?php
require('iframe.php');
$html = new HTML;
showTop('SMS Simulator');

if(empty($_REQUEST['action'])) {
	print '<h1>SMS Simulator</h1>';
	print '<form action="" method="post" class="form-area">';
	$html->buildInput('url', "URL", "text", "http://localhost:3000/offline_donation/mad");
	$html->buildInput('message', "Message", "textarea", "");
	$html->buildInput('action','&nbsp','submit','Commit');
	print '</form>';
} else {
	if(!empty($_REQUEST['url'])) {
		$params = array(
			'msisdn'	=> '919746068565',
			'keyword'	=> @reset(explode(" ", $_REQUEST['message'])),
			'content'	=> $_REQUEST['message'],
			'timestamp'	=> time(),
			);
		//$data = load($_REQUEST['url'],array('method'=>'post','post_data'=>$params));dump($data);

		print "<a href='" . getLink($_REQUEST['url'], $params) . "'>Visit Link</a>";
	}
}

?>
<h3>Sample Texts</h3>
<pre>
TMAD Binny V A**9746068565**binnyva@gmail.com**500**y

</pre>


<?php

showEnd();
