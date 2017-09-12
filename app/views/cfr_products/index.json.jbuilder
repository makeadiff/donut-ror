json.array!(@cfr_products) do |cfr_product|
  json.extract! cfr_product, :name, :description, :target, :city_id, :image_logo
  json.url cfr_product_url(cfr_product, format: :json)
end
