json.array!(@donations) do |donation|
  json.extract! donation, :donation_type, :version, :fundraiser_id, :donour_id, :donation_status, :eighty_g_required, :product_id, :donation_amount
  json.url donation_url(donation, format: :json)
end
