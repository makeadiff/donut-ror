function dynamic_pocs(city_id) {  
  //alert("City_id => " + city_id);
  jQuery.ajax({
    url: "/dynamic_pocs",
    type: "GET",
    data: {"city_id" : city_id},
    dataType: "html"
  }).done(function ( data ) {
  		 jQuery("#poc_div").html(data);
	});
}