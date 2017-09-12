xml.instruct!
xml.cfr_products do
  if @cfr_products.nil?
    
  else
  	@cfr_products.each do |cfr_product|
    	xml.cfr_product do
		    xml.id cfr_product.id
		    xml.name cfr_product.name
		    xml.description cfr_product.description
		    xml.target cfr_product.target
		    xml.image_logo cfr_product.image_logo
		end
    end
  end
end