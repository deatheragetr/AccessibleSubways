class Entrance < ActiveRecord::Base
  belongs_to :station

  def routes
    super.split('')
  end
end