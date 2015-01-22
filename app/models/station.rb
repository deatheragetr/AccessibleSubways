class Station < ActiveRecord::Base
  has_many :entrances

  def lat_long
    "#{latitude}, #{longitude}"
  end

  def served_routes
    entrances.map(&:routes).uniq.flatten.sort
  end
end
