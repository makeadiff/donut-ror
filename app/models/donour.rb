class Donour < ActiveRecord::Base
  has_many :donations

  validates :first_name, presence: true
  #validates :email_id, presence: true
  validates_format_of :email_id, :with => /\A[^@]+@([^@\.]+\.)+[^@\.]+\z/, :allow_blank => true
  #validates :phone_no, presence: true
  
  # -> Method returns the first Donour match with the 
  #    phone number and email arguments passed.
  def self.find_unique(phone_no, email)
  	return self.where(:phone_no=> phone_no, :email_id=>email).first
  end

  # -> Override the rails default 'column' attribute
  def first_name
    capitalize_by_space_and_period(self.read_attribute(:first_name).to_s)
  end

  # -> Override the rails default 'column' attribute
  def last_name
    capitalize_by_space_and_period(self.read_attribute(:last_name).to_s)
  end

  private

  def capitalize_by_space_and_period(name)
    # -> If name contains a word of 2 or more capitals
    #    OR name contains the strings space+MAD or MAD+space
    #    then leave it as it is.
    # -> If not, then split the name by periods or by spaces,
    #    capitalize each split sub-word and then join by spaces.
    name = name.split(/\s|\./).map {|w| w.capitalize}.join(' ') unless name =~ /\b\p{Lu}{2,}\b|[0-9]/u || name.include?('MAD ') || name.include?(' MAD')
    name
  end
end
