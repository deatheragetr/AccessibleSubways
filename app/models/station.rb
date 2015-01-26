class Station < ActiveRecord::Base
  has_many :entrances
  has_many :equipments

  def as_json(options={})
    {
      id: id,
      station_name: name,
      station_longitude: longitude,
      station_latitude: latitude,
      served_routes: served_routes
    }
  end

  def lat_long
    "#{latitude}, #{longitude}"
  end

  def served_routes
    entrances.map(&:routes).uniq.flatten.sort
  end

  def accessible_routes
    equipments.map(&:routes).uniq.flatten.sort
  end
end
