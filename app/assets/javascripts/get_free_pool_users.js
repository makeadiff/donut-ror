function get_free_pool_users(city_id) {
    jQuery.ajax({
        url: "/dynamic_free_pool_users",
        type: "GET",
        data: {"city_id" : city_id},
        dataType: "html"
    }).done(function ( data ) {
            jQuery("#free_pool_div").html(data);
            remove()
        }).error(function(jqXHR, textStatus, errorThrown){
        });
}

function remove()
{
    $(".assign_user").on('ajax:success', function (e, xhr) {
        $('#user_id_' + xhr).fadeOut('fast');
    })
}