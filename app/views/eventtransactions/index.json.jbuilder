json.array!(@event_transactions) do |event_transaction|
  json.extract! event_transaction, 
  json.url event_transaction_url(event_transaction, format: :json)
end
