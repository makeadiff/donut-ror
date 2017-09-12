function dynamic_volunteers_by_city(city_id) {  
  
  jQuery.ajax({
    url: "/citywise_volunteers",
    type: "GET",
    data: {"city_id" : city_id},
    dataType: "html"
  }).done(function ( data ) {
  		 jQuery("#volunteer_div").html(data);
	});
}

function dynamic_volunteers_by_state(state_id) {  
  
  jQuery.ajax({
    url: "/statewise_volunteers",
    type: "GET",
    data: {"state_id" : state_id},
    dataType: "html"
  }).done(function ( data ) {
         jQuery("#volunteer_div").html(data);
    });
}