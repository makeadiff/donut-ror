class City < ActiveRecord::Base
  validates_presence_of :state_id
  validates :name, uniqueness: true, :presence=> true
  belongs_to :state
  
  def state_name
    State.find(state_id)
  end
  
end
