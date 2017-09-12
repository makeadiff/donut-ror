xml.instruct!
xml.donations do
  @donations.each do |donation|
    xml.donation do
      xml.donor_name donation.donour_user.first_name.to_s + ' ' + donation.donour_user.last_name.to_s
      xml.donor_email donation.donour_user.email_id.to_s
      xml.donor_phone donation.donour_user.phone_no
      xml.amount donation.donation_amount
      xml.status donation.donation_status.to_s
    end
  end
  
end