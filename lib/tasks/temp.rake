namespace :temp do
  task :normalize_db => :environment do
    Entrance.all.each do |entrance|
      station = Station.find_or_create_by(:name => entrance.station_name)
      entrance.station_id = station.id
      entrance.save!
    end
  end

  task :lat_long_stations => :environment do
    Entrance.all.each do |entrance|
      station = Station.where(:name => entrance.station_name)
                        .where(:latitude => entrance.station_latitude)
                        .where(:longitude => entrance.station_longitude)
                        .first

      unless station
        station = Station.create(
          :name => entrance.station_name,
          :latitude => entrance.station_latitude,
          :longitude => entrance.station_longitude
          )
      end

      entrance.station_id = station.id
      entrance.save!
    end
  end
end