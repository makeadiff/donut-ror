module EmailTemplateHelper
  # To reset the dates to the correct one, replace all instance of '31/03/2018' to "' + Time.new.inspect + '"
  
  def confirmation_mail_template_for_event(donor_name, donor_email, don_amount, don_id, product_or_event_name)
    @email_text = '<html>
<head>
<title>Event Confirmation Email</title>
</head>
<body>
<table style="width: 960px;margin:0 auto;height: auto;border: 2px solid #f1f1f1;font-family:arial;font-size:20px;">
<tr><td style="vertical-align: top;"><img style="float:left;margin: 0px;" src="' + MadConstants.app_http_root_path + '/assets/mad-letterhead-left.png'.to_s + '"/><img style="margin-left: -70px;" src="' + MadConstants.app_http_root_path + '/assets/mad-letterhead-logo.png'.to_s + '"/><img style="float:right;margin:0px;" src="' + MadConstants.app_http_root_path + '/assets/mad-letterhead-right.png'.to_s + '"/></td></tr>
<tr><td style="color:#cc2028;float:right;margin:10px 20px;">31/03/2018</td></tr>
<tr><td style="padding:10px 20px;"><strong>Dear ' + donor_name + ',</strong></td></tr>
<tr><td style="padding:10px 20px;">Thanks a lot for your contribution of Rs.<strong style="color:#cc2028;">'+ don_amount.to_s + '/-</strong> through the event <strong style="color:#cc2028;">'+ product_or_event_name +'</strong>  towards Make A Difference. Your donation will directly go towards funding our projects for the children we are reaching out to, across 23 cities.</td></tr>
<tr><td style="padding:10px 20px;">A detailed mail with event details will be sent soon.</td></tr>
<tr><td style="padding:10px 20px;"><i>Little bit about Make A Difference: We are a youth run volunteer organization that  mobilizes young leaders to provide better outcomes to children living in shelter homes across India.</i></td></tr>
<tr><td style="padding:20px 20px;"><i>You can read more about us @ <a href="http://www.makeadiff.in"> www.makeadiff.in </a> | <a href="http://www.facebook.com/makeadiff"> www.facebook.com/makeadiff </a> | <a href="http://www.twitter.com/makeadiff">www.twitter.com/makeadiff</a></i></td></tr>
<tr><td style="padding:10px 20px;">Please feel free to contact us on <a href="mailto:info@makeadiff.in">info@makeadiff.in</a> for any clarifications.</td></tr>
</table>
</body>
</html>'
  end

  def confirmation_sponser_mail_template(donor_name, don_amount)
    @email_text = '<html>
<head>
<title>Event Confirmation Email</title>
</head>
<body>
<table style="width: 960px;margin:0 auto;height: auto;border: 2px solid #f1f1f1;font-family:arial;font-size:20px;">
<tr><td style="vertical-align: top;"><img style="float:left;margin: 0px;" src="' + MadConstants.app_http_root_path + '/assets/mad-letterhead-left.png'.to_s + '"/><img style="margin-left: -70px;" src="' + MadConstants.app_http_root_path + '/assets/mad-letterhead-logo.png'.to_s + '"/><img style="float:right;margin:0px;" src="' + MadConstants.app_http_root_path + '/assets/mad-letterhead-right.png'.to_s + '"/></td></tr>
<tr><td style="color:#cc2028;float:right;margin:10px 20px;">31/03/2018</td></tr>
<tr><td style="padding:10px 20px;"><strong>Dear ' + donor_name + ',</strong></td></tr>
<tr><td style="padding:10px 20px;">Thanks a lot for your contribution of Rs.<strong style="color:#cc2028;">'+ don_amount.to_s + '/-</strong> towards Make A Difference. Your sponsership will directly go towards funding our projects for the children we are reaching out to, across 23 cities.</td></tr>
<tr><td style="padding:10px 20px;">A detailed mail with event details will be sent soon.</td></tr>
<tr><td style="padding:10px 20px;"><i>Little bit about Make A Difference: We are a youth run volunteer organization that  mobilizes young leaders to provide better outcomes to children living in shelter homes across India.</i></td></tr>
<tr><td style="padding:20px 20px;"><i>You can read more about us @ <a href="http://www.makeadiff.in"> www.makeadiff.in </a> | <a href="http://www.facebook.com/makeadiff"> www.facebook.com/makeadiff </a> | <a href="http://www.twitter.com/makeadiff">www.twitter.com/makeadiff</a></i></td></tr>
<tr><td style="padding:10px 20px;">Please feel free to contact us on <a href="mailto:info@makeadiff.in">info@makeadiff.in</a> for any clarifications.</td></tr>
</table>
</body>
</html>'
  end

  def confirmation_otd_mail_template(donor_name, don_amount)
    @email_text = '<html>
<head>
<title>Event Confirmation Email</title>
</head>
<body>
<table style="width: 960px;margin:0 auto;height: auto;border: 2px solid #f1f1f1;font-family:arial;font-size:20px;">
<tr><td style="vertical-align: top;"><img style="float:left;margin: 0px;" src="' + MadConstants.app_http_root_path + '/assets/mad-letterhead-left.png'.to_s + '"/><img style="margin-left: -70px;" src="' + MadConstants.app_http_root_path + '/assets/mad-letterhead-logo.png'.to_s + '"/><img style="float:right;margin:0px;" src="' + MadConstants.app_http_root_path + '/assets/mad-letterhead-right.png'.to_s + '"/></td></tr>
<tr><td style="color:#cc2028;float:right;margin:10px 20px;">31/03/2018</td></tr>
<tr><td style="padding:10px 20px;"><strong>Dear ' + donor_name + ',</strong></td></tr>
<tr><td style="padding:10px 20px;">Thanks a lot for your contribution of Rs.<strong style="color:#cc2028;">'+ don_amount.to_s + '/-</strong> towards Make A Difference. Your donation will directly go towards funding our projects for the children we are reaching out to, across 23 cities.</td></tr>
<tr><td style="padding:10px 20px;">A detailed mail with event details will be sent soon.</td></tr>
<tr><td style="padding:10px 20px;"><i>Little bit about Make A Difference: We are a youth run volunteer organization that  mobilizes young leaders to provide better outcomes to children living in shelter homes across India.</i></td></tr>
<tr><td style="padding:20px 20px;"><i>You can read more about us @ <a href="http://www.makeadiff.in"> www.makeadiff.in </a> | <a href="http://www.facebook.com/makeadiff"> www.facebook.com/makeadiff </a> | <a href="http://www.twitter.com/makeadiff">www.twitter.com/makeadiff</a></i></td></tr>
<tr><td style="padding:10px 20px;">Please feel free to contact us on <a href="mailto:info@makeadiff.in">info@makeadiff.in</a> for any clarifications.</td></tr>
</table>
</body>
</html>'
  end
  

  def confirmation_thankyou_mail_template
    @email_text = '<html>
      <head>
        <title>Thank You Placeholder</title>
      </head>
      <body>
        <p> Thank You Placeholder </p>
      </body>
    </html>'
  end


  def confirmation_mail_template_with_eighty_g(donor_name, donor_email, don_amount, don_id, product_or_event_name)
    @email_text = '<html>
<head>
<title>Confirmation Email 80 g</title>
</head>
<body>
<table style="width: 960px;margin:0 auto;height: auto;border: 2px solid #f1f1f1;font-family:arial;font-size:20px;">
<tr><td style="vertical-align: top;"><img style="float:left;margin: 0px;" src="' + MadConstants.app_http_root_path + '/assets/mad-letterhead-left.png'.to_s + '"/><img style="margin-left: -70px;" src="' + MadConstants.app_http_root_path + '/assets/mad-letterhead-logo.png'.to_s + '"/><img style="float:right;margin:0px;" src="' + MadConstants.app_http_root_path + '/assets/mad-letterhead-right.png'.to_s + '"/></td></tr>
<tr><td style="color:#cc2028;float:right;margin:10px 20px;">31/03/2018</td></tr>
<tr><td style="padding:10px 20px;"><strong>Dear ' + donor_name + ',</strong></td></tr>
<tr><td style="padding:10px 20px;">Please find attached the e-receipt containing the tax exemption certificate for the donation.</td></tr>
<tr><td style="padding:10px 20px;">Once again thanks a lot for your contribution of Rs. <strong style="color:#cc2028;">'+ don_amount.to_s + '/- </strong>towards the cause of Make A Difference.</td></tr>
<tr><td style="padding:10px 20px;">Please feel free to contact us on <a href="mailto:info@makeadiff.in">info@makeadiff.in</a> for any clarifications / corrections in the receipt.</td></tr>
<tr><td style="padding:20px 20px;"><i>You can read more about us @ <a href="http://www.makeadiff.in"> www.makeadiff.in </a> | <a href="http://www.facebook.com/makeadiff"> www.facebook.com/makeadiff </a> | <a href="http://www.twitter.com/makeadiff">www.twitter.com/makeadiff</a></i></td></tr>
<tr><td style="padding:10px 20px;">Thanks for choosing MAD.</td></tr>
</table>
</body>
</html>'
    
  end
  
  
  def confirmation_mail_template(donor_name, donor_email, don_amount, don_id, product_or_event_name)
    @email_text = '<html>
<head>
<title>Confirmation Email Non 80 g</title>
</head>
<body>
<table style="width: 960px;margin:0 auto;height: auto;border: 2px solid #f1f1f1;font-family:arial;font-size:20px;">
<tr><td style="vertical-align: top;"><img style="float:left;margin: 0px;" src="' + MadConstants.app_http_root_path + '/assets/mad-letterhead-left.png'.to_s + '"/><img style="margin-left: -70px;" src="' + MadConstants.app_http_root_path + '/assets/mad-letterhead-logo.png'.to_s + '"/><img style="float:right;margin:0px;" src="' + MadConstants.app_http_root_path + '/assets/mad-letterhead-right.png'.to_s + '"/></td></tr>
<tr><td style="color:#cc2028;float:right;margin:10px 20px;"> 31/03/2018 </td></tr>
<tr><td style="padding:10px 20px;"><strong>Dear ' + donor_name + ',</strong></td></tr>
<tr><td style="padding:10px 20px;">Please find attached the e-receipt for the donation.</td></tr>
<tr><td style="padding:10px 20px;">Once again thanks a lot for your contribution of Rs. <strong style="color:#cc2028;">' + don_amount.to_s + '/- </strong>towards the cause of Make A Difference.</td></tr>
<tr><td style="padding:10px 20px;">Please feel free to contact us on <a href="mailto:info@makeadiff.in">info@makeadiff.in</a> for any clarifications / corrections in the receipt.</td></tr>
<tr><td style="padding:20px 20px;"><i>You can read more about us @ <a href="http://www.makeadiff.in"> www.makeadiff.in </a> | <a href="http://www.facebook.com/makeadiff"> www.facebook.com/makeadiff </a> | <a href="http://www.twitter.com/makeadiff">www.twitter.com/makeadiff</a></i></td></tr>
<tr><td style="padding:10px 20px;">Thanks for choosing MAD.</td></tr>
</table>
</body>
</html>'
  end
  
  def ack_mail_template_with_eighty_g(donor_name, donor_email, don_amount, don_id, product_or_event_name)
    @email_text = '<html>
<head>
<title>Acknowledgement Email 80G</title>
</head>
<body>
<table style="width: 960px;margin:0 auto;height: auto;border: 2px solid #f1f1f1;font-family:arial;font-size:20px;">
<tr><td style="vertical-align: top;"><img style="float:left;margin: 0px;" src="' + MadConstants.app_http_root_path + '/assets/mad-letterhead-left.png'.to_s + '"/><img style="margin-left: -70px;" src="' + MadConstants.app_http_root_path + '/assets/mad-letterhead-logo.png'.to_s + '"/><img style="float:right;margin:0px;" src="' + MadConstants.app_http_root_path + '/assets/mad-letterhead-right.png'.to_s + '"/></td></tr>
<tr><td style="color:#cc2028;float:right;margin:10px 20px;"> 31/03/2018 </td></tr>
<tr><td style="padding:10px 20px;"><strong>Dear ' + donor_name + ',</strong></td></tr>
<tr><td style="padding:10px 20px;">Thanks a lot for your contribution of Rs.<strong style="color:#cc2028;">' + don_amount.to_s + '/- </strong> towards Make A Difference.</td></tr>
<tr><td style="padding:10px 20px;">This is not a donation receipt. But only an acknowledgement. We will be sending you the E-Receipt containing the tax exemption certificate for the donation within the next 45 day once the amount reaches us.</td></tr>
<tr><td style="padding:10px 20px;">The receipt will be generated in the name of <strong style="color:#cc2028;">' + donor_name + '</strong> Please contact us via mail/phone mentioned below in case there are any mistake in the above information.</td></tr>
<tr><td style="padding:10px 20px;">Please feel free to contact us on <a href="mailto:info@makeadiff.in">info@makeadiff.in</a> for any clarifications.</td></tr>
<tr><td style="padding:10px 20px;"><i>Little bit about Make A Difference: We are a youth run volunteer organization that  mobilizes young leaders to provide better outcomes to children living in shelter homes across India.</i></td></tr>
<tr><td style="padding:20px 20px;"><i>You can read more about us @ <a href="http://www.makeadiff.in"> www.makeadiff.in </a> | <a href="http://www.facebook.com/makeadiff"> www.facebook.com/makeadiff </a> | <a href="http://www.twitter.com/makeadiff">www.twitter.com/makeadiff</a></i></td></tr>
<tr><td style="color:#333231;font-size:16px;padding:0 20px;">First Floor, House no. 16C, MCHS colony, 1st B Main, 14th C Cross,</td></tr>
<tr><td style="color:#333231;font-size:16px;padding:0 20px;">HSR Layout, Sector 6, Bangalore - 560102.</td></tr>
<tr><td style="color:#333231;float:right;font-size:16px;margin:0 20px 20px;">http://www.makeadiff.in</td></tr>
</table>
</body>
</html>'
  end
  
  def ack_mail_template(donor_name, donor_email, don_amount, don_id, product_or_event_name)
    @email_text = '<html>
<head>
<title>Acknowledgement Email Non 80G</title>
</head>
<body>
<table style="width: 960px;margin:0 auto;height: auto;border: 2px solid #f1f1f1;font-family:arial;font-size:20px;">
<tr><td style="vertical-align: top;"><img style="float:left;margin: 0px;" src="' + MadConstants.app_http_root_path + '/assets/mad-letterhead-left.png'.to_s + '"/><img style="margin-left: -70px;" src="' + MadConstants.app_http_root_path + '/assets/mad-letterhead-logo.png'.to_s + '"/><img style="float:right;margin:0px;" src="' + MadConstants.app_http_root_path + '/assets/mad-letterhead-right.png'.to_s + '"/></td></tr>
<tr><td style="color:#cc2028;float:right;margin:10px 20px;"> 31/03/2018 </td></tr>
<tr><td style="padding:10px 20px;"><strong>Dear ' + donor_name + ',</strong></td></tr>
<tr><td style="padding:10px 20px;">Thanks a lot for your contribution of Rs.<strong style="color:#cc2028;">' + don_amount.to_s + '/-</strong> towards Make A Difference.</td></tr>
<tr><td style="padding:10px 20px;">This is not a donation receipt. But only an acknowledgement. We will be sending you the e-receipt for the donation within the next 30 days once the amount reaches us.</td></tr>
<tr><td style="padding:10px 20px;">Please feel free to contact us on <a href="mailto:info@makeadiff.in">info@makeadiff.in</a> for any clarifications.</td></tr>
<tr><td style="padding:10px 20px;"><i>Little bit about Make A Difference: We are a youth run volunteer organization that  mobilizes young leaders to provide better outcomes to children living in shelter homes across India.</i></td></tr>
<tr><td style="padding:20px 20px;"><i>You can read more about us @ <a href="http://www.makeadiff.in"> www.makeadiff.in </a> | <a href="http://www.facebook.com/makeadiff"> www.facebook.com/makeadiff </a> | <a href="http://www.twitter.com/makeadiff">www.twitter.com/makeadiff</a></i></td></tr>
<tr><td style="color:#333231;font-size:16px;padding:0 20px;">First Floor, House no. 16C, MCHS colony, 1st B Main, 14th C Cross,</td></tr>
<tr><td style="color:#333231;font-size:16px;padding:0 20px;">HSR Layout, Sector 6, Bangalore - 560102.</td></tr>
<tr><td style="color:#333231;float:right;font-size:16px;margin:0 20px 20px;">http://www.makeadiff.in</td></tr>
</table>
</body>
</html>'
  end
    
  
  def thankyou_mail_template(donor_name, donor_email, don_amount, don_id, product_or_event_name)
    @email_text = '<html>
<head>
<title>Thank You for your contribution</title>
</head>
<body>
<table style="width: 960px;margin:0 auto;height: auto;border: 2px solid #f1f1f1;font-family:arial;font-size:20px;">
<tr><td style="vertical-align: top;"><img style="float:left;margin: 0px;" src="' + MadConstants.app_http_root_path + '/assets/mad-letterhead-left.png'.to_s + '"/><img style="margin-left: -70px;" src="' + MadConstants.app_http_root_path + '/assets/mad-letterhead-logo.png'.to_s + '"/><img style="float:right;margin:0px;" src="' + MadConstants.app_http_root_path + '/assets/mad-letterhead-right.png'.to_s + '"/></td></tr>
<tr><td style="color:#cc2028;float:right;margin:10px 20px;"> 31/03/2018 </td></tr>
<tr><td style="padding:10px 20px;"><strong>Dear ' + donor_name + ',</strong></td></tr>
<tr><td style="padding:10px 20px;">Thanks a lot for your contribution towards Make A Difference.</td></tr>
<tr><td style="padding:10px 20px;">Please feel free to contact us on <a href="mailto:info@makeadiff.in">info@makeadiff.in</a> for any clarifications.</td></tr>
<tr><td style="padding:10px 20px;"><i>Little bit about Make A Difference: We are a youth run volunteer organization that  mobilizes young leaders to provide better outcomes to children living in shelter homes across India.</i></td></tr>
<tr><td style="padding:20px 20px;"><i>You can read more about us @ <a href="http://www.makeadiff.in"> www.makeadiff.in </a> | <a href="http://www.facebook.com/makeadiff"> www.facebook.com/makeadiff </a> | <a href="http://www.twitter.com/makeadiff">www.twitter.com/makeadiff</a></i></td></tr>
<tr><td style="color:#333231;font-size:16px;padding:0 20px;">First Floor, House no. 16C, MCHS colony, 1st B Main, 14th C Cross,</td></tr>
<tr><td style="color:#333231;font-size:16px;padding:0 20px;">HSR Layout, Sector 6, Bangalore - 560102.</td></tr>
<tr><td style="color:#333231;float:right;font-size:16px;margin:0 20px 20px;">http://www.makeadiff.in</td></tr>
</table>
</body>
</html>'
  end
end