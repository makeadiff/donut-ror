json.array!(@poctransactions) do |poctransaction|
  json.extract! poctransaction, 
  json.url poctransaction_url(poctransaction, format: :json)
end
