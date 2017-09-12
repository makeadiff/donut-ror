xml.instruct!
xml.events do
  if @events.nil?
    
  else
  	@events.each do |event|
    	xml.event do
			stuff = ""
		    xml.id event.id
		    xml.name event.event_name
		    xml.description event.description
		    xml.ticket_price event.ticket_price
		    xml.venue event.venue_address
		    xml.date_range_from event.date_range_from
		    xml.date_range_to event.date_range_to
		    xml.image_logo event.image_url
		    event.ticket_type.each do |type|
				stuff = stuff + type.id.to_s + "#" + type.name + "#" + type.ticket_price.to_s + ";"
		    end
		    xml.ticket_details stuff
		    event.ticket_type.each do |type|
				xml.ticket_type do
					xml.name type.name
					xml.price type.ticket_price
					xml.id type.id
				end
			end
		end
    end
  end
end