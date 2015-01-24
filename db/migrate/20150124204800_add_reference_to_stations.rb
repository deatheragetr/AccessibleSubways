class AddReferenceToStations < ActiveRecord::Migration
  def change
    add_reference :equipment, :station, index: true
    rename_column :equipment, :station, :station_name
  end
end
