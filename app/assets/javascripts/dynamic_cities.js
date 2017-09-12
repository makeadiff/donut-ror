function dynamic_cities(state_id) {  
  //alert("State_id => " + state_id);
  jQuery.ajax({
    url: "/statewise_cities",
    type: "GET",
    data: {"state_id" : state_id},
    dataType: "html"
  }).done(function ( data ) {
  		 jQuery("#cities_div").html(data);
	});
}