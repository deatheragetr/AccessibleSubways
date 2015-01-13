class CreateEquipment < ActiveRecord::Migration
  def change
    create_table :equipment do |t|
      t.string :station
      t.string :borough
      t.string :train_no
      t.string :equipment_no
      t.string :equipment_type
      t.string :serving
      t.boolean :ada

      t.timestamps
    end
  end
end
