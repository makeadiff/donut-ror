json.array!(@mobile_cfr_prods) do |mobile_cfr_prod|
  json.extract! mobile_cfr_prod, 
  json.url mobile_cfr_prod_url(mobile_cfr_prod, format: :json)
end
