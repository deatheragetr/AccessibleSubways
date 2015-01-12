require 'httparty'
require 'csv'
namespace :populate do
  desc "Populates the database with subway entrance/exit data"
  task :subway_entrances => :environment do
    entrances_csv    = HTTParty.get('http://web.mta.info/developers/data/nyct/subway/StationEntrances.csv')
    parsed_entrances = CSV.parse(entrances_csv)
    parsed_entrances.each_with_index do |ent, i|
      next if i.zero?
      Entrance.create(
        division: ent.first,
        line: ent[1],
        station_name: ent[2],
        station_latitude: ent[3],
        station_longitude: ent[4],
        routes: ent[5..15].compact.to_s.gsub(/\W/, ''),
        entrance_type: ent[16],
        entry: ent[17],
        exit_only: ent[18],
        vending: ent[19],
        staffing: ent[20],
        staff_hours: ent[21],
        ada: ent[22],
        ada_notes: ent[23],
        free_crossover: ent[24],
        north_south_street: ent[25],
        east_west_street: ent[26],
        corner: ent[27],
        entrance_latitude: ent[28],
        entrance_longitude: ent[29]
      )
    end
  end
end
