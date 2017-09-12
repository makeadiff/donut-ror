xml.instruct!
xml.approvals do
  if @donations.nil?
    
  else
  	@donations.each do |donation|
    	xml.approval do
		    xml.id 				donation.id
		    xml.donation_type	donation.donation_type
		    xml.fundraiser_id	donation.fundraiser_id
		    xml.fundraiser_name donation.fundraiser_user.name
   		    xml.donor_id		donation.donour_id
		    xml.donor_name		donation.donour_user.first_name + " " + donation.donour_user.last_name
		    xml.created_at		donation.created_at
		    xml.donation_amount	donation.donation_amount
		    xml.eighty_g_required	donation.eighty_g_required
		    xml.product_id		donation.product_id
		end
    end
  end
end