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

ActiveRecord::Schema.define(:version => 20120807201500) do

  create_table "categories", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "display_order"
  end

  create_table "menu_items", :force => true do |t|
    t.string   "name"
    t.float    "price"
    t.string   "description"
    t.integer  "category_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "photo_file_name"
    t.string   "photo_content_type"
    t.integer  "photo_file_size"
    t.datetime "photo_updated_at"
    t.boolean  "out_of_stock"
    t.integer  "display_order"
  end

  add_index "menu_items", ["name"], :name => "index_menu_items_on_name", :unique => true

  create_table "menu_items_options", :id => false, :force => true do |t|
    t.integer "menu_item_id"
    t.integer "option_id"
  end

  create_table "options", :force => true do |t|
    t.string   "name"
    t.float    "price"
    t.boolean  "out_of_stock"
    t.integer  "menu_item_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "options_selections", :id => false, :force => true do |t|
    t.integer "option_id"
    t.integer "selection_id"
  end

  create_table "orders", :force => true do |t|
    t.string   "customer_name"
    t.time     "pickup_time"
    t.float    "price"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "completed"
    t.string   "secret"
  end

  create_table "payment_notifications", :force => true do |t|
    t.text     "params"
    t.integer  "order_id"
    t.string   "status"
    t.string   "transaction_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "posts", :force => true do |t|
    t.string   "question"
    t.string   "response"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "selections", :force => true do |t|
    t.integer  "order_id"
    t.integer  "menu_item_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "settings", :force => true do |t|
    t.datetime "opens_at"
    t.datetime "closes_at"
    t.string   "home_page_text"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "paypal_email"
    t.integer  "interval"
    t.integer  "max_per_slot"
    t.datetime "last_activation_date"
    t.integer  "feature"
    t.string   "photo_file_name"
    t.string   "photo_content_type"
    t.integer  "photo_file_size"
    t.datetime "photo_updated_at"
  end

end
