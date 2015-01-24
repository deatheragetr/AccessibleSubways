require 'httparty'
require 'csv'
namespace :populate do
  desc "Populates the database with subway equipment data"
  task :subway_equipment => :environment do
    equipment_xml = HTTParty.get('http://advisory.mtanyct.info/eedevwebsvc/allequipments.aspx')
    equipment_list = equipment_xml['NYCEquipments']['equipment']

    equipment_list.each do |eq|
      equipment = Equipment.new
      equipment.station        = eq['station']
      equipment.borough        = eq['borough']
      equipment.train_no       = eq['trainno'].gsub(/METRO-NORTH|LIRR|\//, '')
      equipment.equipment_no   = eq['equipmentno']
      equipment.equipment_type = eq['equipmenttype']
      equipment.serving        = eq['serving']
      equipment.ada            = (eq['ADA'] == 'Y')
      equipment.save!
    end
  end

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

  desc "Properly map stations to equipment list"
  task :map_entrances => :environment do
    equipment_stations_list = { "125TH ST STATION" => "125 St [A,B,C,D] && 125 St [1] && 125 St [4,5,6]" }
    equipment_stations_list.each do |equipment_station_name, entrance_station_names|
      equipment = Equipment.where(station_name: equipment_station_name)
      if entrance_station_names.match(/\s*&&\s*/)
        entrance_station_names = entrance_station_names.split(/\s*&&\s*/)
        entrance_station_names.each do |esn|
          station = Station.find_by(name: esn)
          equipment.each do |eqp|
            if (eqp.train_no.split('') - station.served_routes).empty?
              eqp.update(station: station)
            end
          end
        end
      else
        station = Station.find_by(name: entrance_station_names)
        equipment.each { |eqp| eqp.update(station: station) }
      end
    end
    # Verify no orphaned equipment
    Equipment.all.each { |eqp| fail "Equipment with id #{eqp.id} is orphaned" if eqp.station.nil? }
  end
end
