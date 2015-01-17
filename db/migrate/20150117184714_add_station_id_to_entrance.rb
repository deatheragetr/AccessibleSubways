class AddStationIdToEntrance < ActiveRecord::Migration
  def change
    add_column :entrances, :station_id, :integer
  end
end
