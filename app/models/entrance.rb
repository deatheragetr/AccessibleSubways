class Entrance < ActiveRecord::Base
  belongs_to :station

  def routes
    super.split('').sort
  end
end