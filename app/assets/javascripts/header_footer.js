$(function(){
  $( "#datepickerFrom input").datepicker({
  dateFormat: 'yy-mm-dd',
  changeMonth: true,
  changeYear: true,
  onClose: function( selectedDate ) {
$( "#datepickerTo input" ).datepicker( "option", "minDate", selectedDate );
}
});
$( "#datepickerTo input").datepicker({
  dateFormat: 'yy-mm-dd',
  changeMonth: true,
  changeYear: true,
  onClose: function( selectedDate ) {
$( "#datepickerFrom input" ).datepicker( "option", "maxDate", selectedDate );
}
});
$( "#show-help-link" ).click(function() {
$( ".status-help-panel" ).dialog({
      modal : true,
      width : 660
});
});
$( "#accordion" ).accordion();
$( "#accordion1" ).accordion();
});

$(document).ready(function() {
    $("#target").keydown(function(event) {
      // Allow only backspace and delete
      if ( event.keyCode == 46 || event.keyCode == 8 || event.keyCode == 9 || event.keyCode == 110 || event.keyCode == 190 || 
             // Allow: home, end, left, right
            (event.keyCode >= 35 && event.keyCode <= 39) ) {
        // let it happen, don't do anything
      }
      else {
        // Ensure that it is a number and stop the keypress
        if (event.shiftKey || (event.keyCode < 48 || event.keyCode > 57) && (event.keyCode < 96 || event.keyCode > 105 )) {
          event.preventDefault(); 
        } 
      }
    });
    $("#regionText").keydown(function(event) {
        // Allow: backspace, delete, tab, escape, space and enter
        if ( event.keyCode == 8 || event.keyCode == 9 || event.keyCode == 27 
          || event.keyCode == 46 || event.keyCode == 13 || event.keyCode == 32 || event.keyCode == 190 ||
             // Allow: Ctrl+A
            (event.keyCode == 65 && event.ctrlKey == true) || 
             // Allow: home, end, left, right
            (event.keyCode >= 35 && event.keyCode <= 39) ||
            (event.keyCode == 62 || event.keyCode == 95)) 
            {
                 // let it happen, don't do anything
                 return;
            }
          else 
          {
            // Ensure that it is a number and stop the keypress
            //if (event.shiftKey || (event.keyCode < 48 || event.keyCode > 57) && (event.keyCode < 96 || event.keyCode > 105 )) {
            if (event.keyCode < 65 || event.keyCode > 90) 
            {
                event.preventDefault(); 
            }   
        }
    });
    $("#ticketPrice").keydown(function(event) {
      // Allow only backspace and delete
      if ( event.keyCode == 46 || event.keyCode == 8 || event.keyCode == 9 || event.keyCode == 110 || event.keyCode == 190 || 
             // Allow: home, end, left, right
            (event.keyCode >= 35 && event.keyCode <= 39) ) {
        // let it happen, don't do anything
      }
      else {
        // Ensure that it is a number and stop the keypress
        if (event.shiftKey || (event.keyCode < 48 || event.keyCode > 57) && (event.keyCode < 96 || event.keyCode > 105 )) {
          event.preventDefault(); 
        } 
      }
    });
});


