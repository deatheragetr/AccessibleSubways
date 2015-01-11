class CreateEntrances < ActiveRecord::Migration
  def change
    create_table :entrances do |t|
      t.string  :division
      t.string  :line
      t.string  :station_name
      t.float   :station_latitude
      t.float   :station_longitude
      t.string  :routes
      t.string  :entrance_type
      t.boolean :entry
      t.boolean :exit_only
      t.boolean :vending
      t.string  :staffing
      t.string  :staff_hours
      t.boolean :ada
      t.text    :ada_notes
      t.boolean :free_crossover
      t.string  :north_south_street
      t.string  :east_west_street
      t.string  :corner
      t.float   :entrance_latitude
      t.float   :entrance_longitude
      t.timestamps
    end
  end
end
