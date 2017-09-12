json.array!(@events) do |event|
  json.extract! event, :event_name, :image_url, :ticket_price, :description, :date_range_from, :date_range_to, :venue_address, :venue_address1, :city_id, :state_id
  json.url event_url(event, format: :json)
end
