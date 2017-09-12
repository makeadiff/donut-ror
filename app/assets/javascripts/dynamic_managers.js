function dynamic_managers(role_id,city_id) {
    //alert('role_id => ' + role_id + 'City =>'+city_id);
    jQuery.ajax({
        url: "/dynamic_managers",
        type: "GET",
        data: {"role_id" : role_id , "city_id" : city_id},
        dataType: "html"
    }).done(function ( data ) {
            jQuery("#manager_div").html(data);
            $('#submit_form').removeAttr("disabled");
        }).error(function(jqXHR, textStatus, errorThrown){
        	//alert('Status ==>'+jqXHR.status);
            if(jqXHR.status==400)
            {
                //alert('User\'s Role or City Not selected');
                $("#submit_form").prop('disabled', true);
            }
            else if(jqXHR.status==405)
            {
                alert('You can not create this same role for same city');
                $("#submit_form").prop('disabled', true);
            }
            else if(jqXHR.status==410)
            {
                alert('You can not create another role of this type');
                $("#submit_form").prop('disabled', true);
            }
            else if(jqXHR.status==415)
            {
                alert('No Managers Found for this City. Please Create them.')
                $("#submit_form").prop('disabled', true);
                $('#user_manager_id').remove();
            }
            $('#user_manager_id').remove();
    });
}

$(document).ready(function() {
    //$('#user_manager_id').remove();
});