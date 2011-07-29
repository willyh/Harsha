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

ActiveRecord::Schema.define(:version => 20110729130811) do

  create_table "menu_items", :force => true do |t|
    t.string   "name"
    t.float    "price"
    t.string   "description"
    t.string   "category"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "photo_file_name"
    t.string   "photo_content_type"
    t.integer  "photo_file_size"
    t.datetime "photo_updated_at"
    t.boolean  "out_of_stock"
  end

  add_index "menu_items", ["name"], :name => "index_menu_items_on_name", :unique => true

  create_table "orders", :force => true do |t|
    t.string   "customer_name"
    t.string   "pickup_time"
    t.float    "price"
    t.string   "items"
    t.string   "instructions"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "completed"
  end

  add_index "orders", ["pickup_time"], :name => "index_orders_on_pickup_time", :unique => true

end
