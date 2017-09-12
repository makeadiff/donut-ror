xml.instruct!
xml.approvals do
  if @subordinates.nil?
    
  else
  	@subordinates.each do |subordinate|
    	xml.poc do
		    xml.id				subordinate.id
		    xml.name 			subordinate.first_name + ' ' + subordinate.last_name
		    xml.total_amount	subordinate.total_donation_amount
		    subordinate.donations.each do |donation|
		    	if donation.donation_status == Donation.get_approval_status_by_role(@approver.current_role)[:current_status]
			    	xml.donation do
				    	xml.donation_id		donation.id
				    	xml.created_at		donation.created_at.to_formatted_s(:long)
				    	xml.donor_name		donation.donour_user.first_name+" "+donation.donour_user.last_name
				    	xml.amount 			donation.donation_amount
				    end
				end
			end
		end
    end
end
end
