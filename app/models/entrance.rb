class Entrance < ActiveRecord::Base
  belongs_to :station

  def as_json(options={})
    {
      id: id,
      station_name: name,
      station_longitude: longitude,
      station_latitude: latitude,
      served_routes: served_routes
    }
  end


  def routes
    super.split('')
  end
end
