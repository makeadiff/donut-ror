class CfrProduct < ActiveRecord::Base
  
  mount_uploader :image_logo, ImageUploader
  
  validates :name, :presence => true, :length => {:maximum => 60}
  validates :target,:presence=> true, numericality: { only_integer: true }, :length => {:maximum => 15}
  validates_presence_of :city_id
  validates :description,:presence => true, :length => {:maximum => 300}
  validates :image_logo, format: {
   with: /(\.(ANI|ANIM|APNG|ART|BEF|BMP|BSAVE|CAL|CIN|CPC|CPT|DPX|ECW|EXR|FITS|FLIC|FPX|GIF|HDRi|HEVC|ICER|ICNS|ICO|CUR|ICS|ILBM|JBIG|JBIG2|JNG|JPEG|JPG|JPEG2000|JPEG-LS|JPEG-HDR|JPEGXR|MNG|MIFF|PBM|PCX|PGF|PGM|PICtor|PNG|PPM|PSD|PSB|PSP|QTVR|RAD|RGBE|SGI|TGA|TIFF|LogluvTIFF|WBMP|WebP|XBM|XCF|XPM)$)|\A\Z/i,message: 'must be a url for gif, jpg, or png image.'}
  validates_presence_of :start_date
  validates_presence_of :end_date
  
  # Validation required for CFR product form.
  # 1. 60 character Name
  # 2. 300 lines for description
  # 3. 15 digit Target
  # 4. Validation required in start and end date.
  # 5. only image file allowed in CFR logo.
  
  # -> Method returns the name of the city to which city id
  #    is passed.
  def city_name(city_id_param)
    @city = City.find(city_id_param)
    @city[:name]
  end
  
  # -> Method returns product id
  def gen_prod_id
    @cfr_product = CfrProduct.find_by_is_other_product(0)
    @cfr_product[:id]
  end
  
end
