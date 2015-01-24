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
    equipment_stations_list = STATIONS_EQUIPMENT_MAP
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
    orphaned = []
    Equipment.all.each { |eqp| orphaned << eqp if eqp.station.nil? }
    puts orphaned.collect(&:id)
  end
end

STATIONS_EQUIPMENT_MAP = {
  "125TH ST STATION" => "125 St [A,B,C,D] && 125 St [1] && 125 St [4,5,6]",
  "135TH ST STATION" => "135 St [2,3]",
  "145TH ST STATION" => "145 St [A,B,C,D]",
  "149TH ST - 3RD AVENUE STATION" =>  "149th St-3rd Av",
  "14TH ST - UNION SQ STATION" => "14 St - Union Sq",
  "14TH ST STATION" =>  "14 St [A,C,E]",
  "161 ST - YANKEE STADIUM STATION" =>  "161 St - Yankee Stadium [4,B,D]",
  "168TH ST STATION" => "168th St",
  "175TH ST STATION" => "175th St",
  "179TH ST - JAMAICA STATION" => "Jamaica-179th St",
  "181 ST STATION" => "181 St [A] && 181 St [1]",
  "190TH ST STATION" => "190th St",
  "191 ST STATION" => "191st St",
  "205TH ST - NORWOOD STATION" => "Norwood-205th St",
  "207TH ST - INWOOD STATION" =>  "Inwood - 207th St",
  "21ST ST - QUEENSBRIDGE STATION" => "21 St - Queensbridge [F]",
  "231ST ST STATION" => "231st St",
  "233RD ST" => "233rd St",
  "34TH ST - HERALD SQ STATION" =>  "34 St - Herald Sq [B,D,F,M,N,Q,R]",
  "34TH ST - PENN STATION" => "34 St - Penn Station [A,C,E] && 34 St - Penn Station [1,2,3]",
  "42ND ST - BRYANT PARK STATION" =>  "42 St - Bryant Pk [B,D,F,M]",
  "42ND ST - GRAND CENTRAL STATION" =>  "Grand Central - 42 St [4,5,6,7,S]",
  "42ND ST - PORT AUTHORITY BUS TERM" =>  "42 St - Port Authority Bus Terminal [A,C,E]",
  "47-50TH ST - ROCKEFELLER CTR STATION" => "47-50th Sts Rockefeller Center",
  "50 ST" =>  "50 St [C,E]",
  "50TH ST STATION" =>  "50 St [C,E]",
  "51ST ST STATION" =>  "51st St",
  "57TH ST - 7TH AV STATION" => "57th St",
  "599 LEXINGTON AVENUE" => "Lexington Av-53rd St",
  "59TH ST - COLUMBUS CIR STATION" => "59 St - Columbus Circle",
  "59TH STREET" =>  "Lexington Av/59 St [4,5,6,N,Q,R]",
  "5TH AVE / 53RD ST STATION" =>  "5th Av-53rd St",
  "61 ST - WOODSIDE" => "Woodside Av-61st St",
  "66TH ST - LINCOLN CENTER STATION" => "66th St-Lincoln Center",
  "72ND ST STATION" =>  "72nd St",
  "7TH AVE STATION" =>  "7 Av [B,D,E]",
  "8TH AVENUE" => "8 Av [L]",
  "96TH ST STATION" =>  "96 St [1,2,3]",
  "ATLANTIC AV-BARCLAYS CTR" => "Atlantic Av - Barclays Ctr",
  "BAY PARKWAY STATION" =>  "Bay Parkway",
  "BOROUGH HALL STATION" => "Borough Hall [2,3,4,5]",
  "BOWERY STATION" => "Bowery",
  "BOWLING GREEN" =>  "Bowling Green",
  "BRIGHTON BEACH STATION" => "Brighton Beach",
  "BROADWAY JUNCTION STATION" =>  "Broadway Junction-East New York",
  "BROOKLYN BRIDGE - CITY HALL STATION" =>  "Brooklyn Bridge-City Hall",
  "Broadway-Lafayette/Bleecker St" => "Broadway-Lafayette St",
  "CANAL ST STATION" => "Canal St [6,J,Z,N,Q,R]",
  "CARROLL ST STATION" => "Carroll St",
  "CHAMBERS ST STATION" =>  "Chambers St [1,2,3]",
  "CHURCH AVE STATION" => "Church Av [F,G] && Church Av [2,5]",
  "CLARK ST STATION" => "Clark St",
  "COLUMBUS CIRCLE" =>  "59th St-Columbus Circle",
  "CONEY ISLAND STILLWELL AVE STATION" => "Stillwell Av",
  "COURT SQUARE" => "Long Island City-Court Square",
  "COURT SQUARE - 23RD STREET" => "Long Island City-Court Square",
  "COURT ST STATION" => "Court St",
  "CROWN HTS - UTICA AVE STATION" =>  "Crown Hts - Utica Av [3,4,5]",
  "DEKALB AVE STATION" => "DeKalb Av [B,Q,R]",
  "DELANCEY ST ESSEX ST STATION" => "Delancey St",
  "DYCKMAN ST QUARTERS" =>  "Dyckman St",
  "DYCKMAN ST STATION" => "Dyckman St",
  "EAST 180TH STREET STATION" =>  "East 180th St",
  "EAST BROADWAY STATION" =>  "East Broadway",
  "EUCLID AVE STATION" => "Euclid Av",
  "FAR ROCKAWAY MOTT AVE STATION" =>  "Far Rockaway-Mott Av",
  "FLATBUSH AVE BROOKLYN COLLEGE STATION" =>  "Flatbush Av-Brooklyn College",
  "FLUSHING AV STATION" =>  "Flushing Av [J,M]",
  "FLUSHING MAIN ST STATION" => "Flushing-Main St",
  "FORDHAM RD STATION" => "Fordham Rd [4]",
  "FOREST HILLS - 71 AV STATION" => "Forest Hills-71st Av",
  "FRANKLIN AVE STATION" => "Franklin Av [C,S]",
  "FULTON ST STATION" =>  "Fulton St [2,3,4,5,A,C,J,Z]",
  "GUN HILL RD STATION" =>  "Gun Hill Rd [2,5]",
  "HIGH ST STATION" =>  "High St",
  "HOWARD BEACH" => "Howard Beach",
  "HUNTS POINT STATION" =>  "Hunts Point Av",
  "INTERVALE AV STATION" => "Intervale Av",
  "JACKSON HTS - ROOSEVELT AVE STATION" =>  "Jackson Heights-Roosevelt Ave",
  "JAMAICA CENTER PARSONS/ARCHER" =>  "Parsons Blvd-Archer Av - Jamaica Center",
  "JAMAICA VAN WYCK STATION" => "Jamaica-Van Wyck",
  "JAY ST - METROTECH" => "Jay St - Borough Hall",
  "JAY ST - METROTECH STATION" => "Jay St - Borough Hall",
  "JAY ST METROTECH" => "Jay St - Borough Hall",
  "JUNCTION BLVD STATION" =>  "Junction Blvd",
  "KEW GARDENS / UNION TPK STATION" =>  "Kew Gardens-Union Turnpike",
  "KINGS HIGHWAY" =>  "Kings Hwy [B,Q]",
  "KINGSBRIDGE ROAD" => "Kingsbridge Rd [B,D]",
  "LEXINGTON AVE / 53RD ST STATION" =>  "Lexington Av-53rd St",
  "LEXINGTON AVE / 59TH ST STATION" =>  "Lexington Av/59 St [4,5,6,N,Q,R]",
  "LEXINGTON AVE / 63RD ST STATION" =>  "Lexington Av/63 St [F]",
  "LEXINGTON AVENUE (3RD AVENUE)" =>  "Lexington Av-53rd St",
  "MARCY AV STATION" => "Marcy Av",
  "MYRTLE AVE / WYCKOFF AVE STATION" => "Myrtle - Wyckoff Avs",
  "PARK PLACE STATION" => "Park Pl [2,3]",
  "PARKCHESTER STATION" =>  "Parkchester-East 177th St",
  "PELHAM BAY PARK STATION" =>  "Pelham Bay Park",
  "PELHAM PKWY STATION" =>  "Pelham Pkwy [2,5]",
  "PRESIDENT ST STATION" => "President St",
  "PROSPECT PARK STATION" =>  "Prospect Park",
  "QUEENS PLAZA STATION" => "Queens Plaza",
  "ROCKAWAY PARK - BEACH 116TH ST STATION" => "Rockaway Park-Beach 116th",
  "ROOSEVELT ISLAND STATION" => "Roosevelt Island",
  "SIMPSON ST STATION" => "Simpson St",
  "SMITH - 9TH STS STATION" =>  "Smith-9th St",
  "SOUTH FERRY STATION" =>  "South Ferry",
  "SUTPHIN BLVD - ARCHER AVE - JFK AIRPORT STATION" =>  "Sutphin Blvd-Archer Av - JFK",
  "TIMES SQ - 42 ST" => "Times Sq - 42 St [1,2,3,7,N,Q,R]",
  "UTICA AVE STATION" =>  "Utica Av [A,C]",
  "WALL STREET STATION" =>  "Wall St [2,3]",
  "WEST 4TH ST - WASHINGTON SQ STATION" =>  "West 4th St",
  "WEST 8 ST - NY AQUARIUM STATION" =>  "West 8th St",
  "WEST FARMS SQ - E TREMONT AVE STATION" =>  "East Tremont Av-West Farms Sq",
  "WHITEHALL ST - SOUTH FERRY STATION" => "Whitehall St"
}
