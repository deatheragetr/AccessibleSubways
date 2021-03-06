# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150126031955) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "entrances", force: true do |t|
    t.string   "division"
    t.string   "line"
    t.string   "station_name"
    t.float    "station_latitude"
    t.float    "station_longitude"
    t.string   "routes"
    t.string   "entrance_type"
    t.boolean  "entry"
    t.boolean  "exit_only"
    t.boolean  "vending"
    t.string   "staffing"
    t.string   "staff_hours"
    t.boolean  "ada"
    t.text     "ada_notes"
    t.boolean  "free_crossover"
    t.string   "north_south_street"
    t.string   "east_west_street"
    t.string   "corner"
    t.float    "entrance_latitude"
    t.float    "entrance_longitude"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "station_id"
  end

  create_table "equipment", force: true do |t|
    t.string   "station_name"
    t.string   "borough"
    t.string   "train_no"
    t.string   "equipment_no"
    t.string   "equipment_type"
    t.string   "serving"
    t.boolean  "ada"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "station_id"
  end

  add_index "equipment", ["station_id"], name: "index_equipment_on_station_id", using: :btree

  create_table "stations", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "latitude"
    t.float    "longitude"
    t.boolean  "ada"
  end

end
