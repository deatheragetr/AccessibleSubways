class Entrance < ActiveRecord::Base
  def routes
    super.split('')
  end
end