<?php
require('iframe.php');
$html = new HTML;
showTop('Poster');

//$base_url = 'http://mad:mad@cfrapp.makeadiff.in:3000';
$base_url = 'http://mad:mad@0.0.0.0:3000';

// $url = $base_url . '/event_donations';
//$post = 'amount=1000&phone_no=9886768565&first_name=Binny&last_name=VA&email_id=binnyv@gmail.com&event_id=51&address=&fundraiser_id=3022&ticket_type_id=1367&donation_type=EVNT&format=xml';

/// Simulate system getting at 'GETEVENTS' SMS.
// $url = $base_url . '/offline_donation/mad';
// $post = 'content=GETEVENTS&msisdn=919746068565';

/// Get Event XML
// $url = $base_url . '/mobile_events/events.xml';
// $post = 'volunteer_id=3022';

/// Login using Phone
// $url = $base_url . '/mobileuser/';
// $post = 'format=xml&phone_no=9886768565';

/// CFR - General Donation
$url = $base_url . '/donations/';
$post = 'amount=1000&phone_no=9886768565&first_name=Binny V A&email_id=binnyva@gmail.com&eighty_g_required=0&address=&fundraiser_id=3022&product_id=GEN&donation_type=GEN&format=xml';

// $url = $base_url . '/donations/';
// $post = 'amount=1000&phone_no=9886768565&first_name=Binny&last_name=VA&email_id=&eighty_g_required=0&address=&fundraiser_id=3022&product_id=GEN&donation_type=GEN&format=xml';

/// Other Apps
// $url = "http://localhost/Projects/Madapp/index.php/api/user_login";
// $post = "email=cto@makeadiff.in&password=driven";

$method = "POST";


if(empty($_REQUEST['action'])) {
	print '<h1>Poster</h1>';
	print '<form action="" method="'.$method.'" class="form-area">';
	$html->buildInput('url', "URL", 'text', $url, array('size'=>52));
	$html->buildInput('post', "Post Data", "textarea", $post);
	$html->buildInput('action','&nbsp','submit','Get Page');
	$html->buildInput('direct-post','&nbsp','button','Direct Post');
	print '</form>';
} else {
	if(!empty($_REQUEST['url'])) {
		$post = $_REQUEST['post'];
		$parts = explode("&", $post);
		$params = array();
		foreach ($parts as $part) {
			list($key, $value) = explode("=", $part);
			$params[$key] = $value;
		}

		$data = load($_REQUEST['url'],array('method'=>'post','post_data'=>$params));
		highlight_string($data);

		print "<a href='" . getLink($_REQUEST['url'], $params) . "'>Visit Link</a>";
	}
}

?>
<h3>Sample POST</h3>
<pre>
phone_no=9746068565&amp;format=xml
</pre>
<script type="text/javascript">
function init () {
	$("#direct-post").click(directPost);
}

function directPost() {
	$(".form-area").attr("action", $("#url").val());
	var data = $("#post").val().replace("/[\n\r]/","");
	var html = "";
	var parts = data.split("&");
	for(var i in parts) {
		var split = parts[i].split("=");
		html += "<label>"+split[0]+"</label><input type='text' name='"+split[0]+"' value='"+split[1]+"' /><br />";
	}
	$(".form-area").html(html);
	$(".form-area").submit();
}
</script>

<?php

showEnd();
