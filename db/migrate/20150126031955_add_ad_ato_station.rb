class AddAdAtoStation < ActiveRecord::Migration
  def change
    add_column :stations, :ada, :boolean
  end
end
