class Station < ActiveRecord::Base
  has_many :entrances
  has_many :equipments

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
