xml.instruct!
xml.user do
  if @data.nil?
    
  else
    xml.id @data[:id]
    xml.is_fc @data[:is_fc]
    xml.message @data[:message]
  end
end