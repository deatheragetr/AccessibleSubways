namespace :temp do
  task :normalize_db => :environment do
    Entrance.all.each do |entrance|
      station = Station.find_or_create_by(:name => entrance.station_name)
      entrance.station_id = station.id
      entrance.save!
    end
  end

  task :count_station_lats => :environment do
    station_name_count = Entrance.all.map(&:station_name).uniq.count
    station_lat_count  = Entrance.all.map(&:station_latitude).uniq.count

    print "name count: #{station_name_count} \n station_lat_count: #{station_lat_count}"
  end

  task :count_number_of_multis => :environment do
    stations = {}
    Entrance.all.each do |ent|
      stations[ent.station_name] ||= []
      stations[ent.station_name] << ent.station_longitude
    end
    stations.map(&:uniq)
  end
end
