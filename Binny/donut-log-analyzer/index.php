<?php
require('common.php');

$log = file_get_contents('production_tail.log');


preg_match_all("/POST \"\/mobileauth\/\" for (\S+).*?\"phone_no\"=>\"(\S*)\"/s",$log,$fundraisers);

preg_match_all("/POST \"\/donations\/\" for (\d+\.\d+\.\d+\.\d+) at \d+\-\d+\-\d+ \d+\:\d+\:\d+ \+\d+\s*Processing by DonationsController#create as XML\s  Parameters\: \{\"amount\"=>\"\d+\", \"first_name\"=>\"(.*?)\", \"email_id\"=>\"(\S*)\", \"phone_no\"=>\"(\d*)\", \"eighty_g_required\"=>\"\w+\", \"address\"=>\".*?\", \"fundraiser_id\"=>\"undefined\", \"product_id\"=>\"GEN\"/",$log,$donors);


//To find fundraiser id from the phone number

for($i=0;$i<count($fundraisers[0]);$i++) {
    if(!empty($fundraisers[2][$i])) {
        $id = $sql->getAssoc("SELECT id FROM users WHERE phone_no='" . $fundraisers[2][$i] . "'");

        if(!empty($id["id"])) {
            $fundraisers[3][$i] = $id["id"];
        }else{
            $fundraisers[3][$i] = '';
        }

    }else{
        $fundraisers[3][$i] = '';
    }
}

//To eliminate the duplicate entries in fundraisers. Starting from bottom since fundraisers are more likely to enter the correct phone number and log in later in time. There are cases where they try multiple phone nos before correctly logging in.
for($i = count($fundraisers[0]) -1 ; $i>=0 ; $i--){
    for($j = $i-1 ; $j>=0 ; $j--) {
        if($fundraisers[1][$i] == $fundraisers[1][$j]) {
            $fundraisers[3][$j] = '';
        }
    }
}


//To find the donor id from the phone number or the email address
for($i=0;$i<count($donors[0]);$i++) {
    if(!empty($donors[4][$i])) {
        $id = $sql->getAssoc("SELECT id FROM donours WHERE phone_no = " . $donors[4][$i]);

        if(!empty($id["id"])){
            $donors[5][$i] = $id["id"];
        }else{
            $donors[5][$i] = '';
        }

    }elseif(!empty($donors[3][$i])) {
        $id = $sql->getAssoc("SELECT id FROM donours WHERE email_id = '" . $donors[3][$i] . "'");

        if(!empty($id["id"])){
            $donors[5][$i] = $id["id"];
        }else{
            $donors[5][$i] = '';
        }
    }else{
        $donors[5][$i] = '';
    }

}

$links = array();

for($i=0;$i<count($fundraisers[0]);$i++) {
    for($j=0;$j<count($donors[0]);$j++) {
        if(!empty($fundraisers[3][$i]) && !empty($donors[5][$j]) && $fundraisers[1][$i] == $donors[1][$j]) {
            $link = new stdClass();
            $link->fundraiser_id = $fundraisers[3][$i];
            $link->donor_id = $donors[5][$j];

            array_push($links,$link);
        }
    }
}


foreach($links as $link) {
    $sql->execQuery("UPDATE donations SET fundraiser_id = $link->fundraiser_id, updated_by = $link->fundraiser_id WHERE donour_id = $link->donor_id AND DATE(created_at) >= '2015-01-04'");
}

// var_dump($fundraisers);
// var_dump($donors);

// var_dump($links);

//match phone number of donor and find the donor id and then update fundraiser id for all the donations of that donor
//117.247.97.37
//9845068957

//106.79.165.22


/*
$changes = array(
    array(
        'fundraiser_id' => 100,
        'donor_id' => 2586
    ),
    array(
        'fundraiser_id' => 32,
        'donor_id' => 242
    ),
    array(
        'fundraiser_id' => 12437,
        'donor_id' => 709
    ),
    array(
        'fundraiser_id' => 12380,
        'donor_id' => 716
    )
);
*/
?>
