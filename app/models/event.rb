class Event < ActiveRecord::Base
  mount_uploader :image_url, ImageUploader
  has_many :event_ticket_type
  
  attr_accessor :volunteer_ids, :volunteers

  validates :event_name, :presence=> true, :length => {:maximum => 60}
  validates :date_range_from, :presence=> true
  validates :date_range_to, :presence=> true
  validates :city_id, :presence=> true
  validates :state_id, :presence=> true
  validates :description,:presence => true, :length => {:maximum => 300}
  validates :venue_address,:presence => true, :length => {:maximum => 200}
  validates :image_url, format: {
   with: /(\.(ANI|ANIM|APNG|ART|BEF|BMP|BSAVE|CAL|CIN|CPC|CPT|DPX|ECW|EXR|FITS|FLIC|FPX|GIF|HDRi|HEVC|ICER|ICNS|ICO|CUR|ICS|ILBM|JBIG|JBIG2|JNG|JPEG|JPG|JPEG2000|JPEG-LS|JPEG-HDR|JPEGXR|MNG|MIFF|PBM|PCX|PGF|PGM|PICtor|PNG|PPM|PSD|PSB|PSP|QTVR|RAD|RGBE|SGI|TGA|TIFF|LogluvTIFF|WBMP|WebP|XBM|XCF|XPM)$)|\A\Z/i,message: 'must be a url for gif, jpg, or png image.'}
  
  # -> Method returns the ticket type of the calling
  #    event object.
  def ticket_type
	  @ticket_type = EventTicketType.where(:event_id => id)
  end
	
  # -> Method returns the name of the city where the 
  #    calling event object is being held.
  def city_name
    @city = City.find(city_id)
    @city[:name]
  end
  
  # -> Method returns the name of the state where the
  #    calling event object is being held.
  def state_name
    @state = State.find(state_id)
    @state[:name]
  end
end
