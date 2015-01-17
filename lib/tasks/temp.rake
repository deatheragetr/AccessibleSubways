namespace :temp do
  task :normalize_db => :environment do
    Entrance.all.each do |entrance|
      station = Station.find_or_create_by(:name => entrance.station_name)
      entrance.station_id = station.id
      entrance.save!
    end
  end
end