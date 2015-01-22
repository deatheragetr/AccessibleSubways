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

  task :chomp_up_new_station_names => :environment do
    review_collection = []

    dup_names = Station.all.group_by(&:name).select { |name, stations| stations.count > 1 }
    dup_names.each do |shared_name, stations|
      stations.each do |station|
        puts "#{station.id} Station Name: #{station.name}\n#{station.latitude}, #{station.longitude}"
        Launchy.open("https://www.google.com/maps/search/#{station.latitude},+#{station.longitude}/@#{station.latitude},#{station.longitude}")

        puts "New Station Name:"
        new_name = STDIN.gets.chomp
        station.update(name: new_name) if new_name != ''

        puts "Review?"
        review = STDIN.gets.chomp
        review_collection << station.name if review == 'y'
      end
    end
  end
end
