function validate_role(role_id) {
	//alert('role_id => ' + role_id);
	jQuery.ajax({
        url: "/is_validate_role",
        type: "GET",
        data: {"role_id" : role_id },
        dataType: "html"
    }).done(function ( data ) {
            $('#submit_form').removeAttr("disabled");
        }).error(function(jqXHR, textStatus, errorThrown){
            if(jqXHR.status==400)
            {
            	$("#submit_form").prop('disabled', true);
                alert('You can not create another role of this type');              
            }
            else
            {
            	$("#submit_form").prop('disabled', false);
            }
     });
}