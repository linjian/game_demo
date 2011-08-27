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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110827023313) do

  create_table "cities", :force => true do |t|
    t.integer  "user_id",           :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "area_left_value",   :null => false
    t.integer  "area_bottom_value", :null => false
    t.string   "name"
  end

  create_table "city_resources", :force => true do |t|
    t.integer  "city_id",                             :null => false
    t.integer  "user_id",                             :null => false
    t.integer  "food",               :default => 0,   :null => false
    t.integer  "gold",               :default => 0,   :null => false
    t.integer  "population",         :default => 100, :null => false
    t.integer  "tax_rate",           :default => 20,  :null => false
    t.datetime "last_taxation_time"
    t.datetime "food_updated_time"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "login",      :null => false
    t.string   "password",   :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
