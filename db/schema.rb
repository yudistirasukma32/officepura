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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20230206030303) do

  create_table "activities", :force => true do |t|
    t.integer   "trackable_id"
    t.string    "trackable_type"
    t.integer   "owner_id"
    t.string    "owner_type"
    t.string    "key"
    t.text      "parameters"
    t.integer   "recipient_id"
    t.string    "recipient_type"
    t.timestamp "created_at",     :limit => 6, :null => false
    t.timestamp "updated_at",     :limit => 6, :null => false
  end

  add_index "activities", ["owner_id", "owner_type"], :name => "index_activities_on_owner_id_and_owner_type"
  add_index "activities", ["recipient_id", "recipient_type"], :name => "index_activities_on_recipient_id_and_recipient_type"
  add_index "activities", ["trackable_id", "trackable_type"], :name => "index_activities_on_trackable_id_and_trackable_type"

  create_table "allowances", :force => true do |t|
    t.boolean   "deleted",                                                     :default => false
    t.integer   "route_id"
    t.integer   "vehiclegroup_id"
    t.integer   "gas_trip",                                                    :default => 0
    t.timestamp "created_at",      :limit => 6,                                                   :null => false
    t.timestamp "updated_at",      :limit => 6,                                                   :null => false
    t.decimal   "driver_trip",                  :precision => 19, :scale => 2, :default => 0.0
    t.decimal   "misc_allowance",               :precision => 19, :scale => 2, :default => 0.0
    t.decimal   "helper_trip",                  :precision => 19, :scale => 2, :default => 0.0
    t.decimal   "train_trip",                   :precision => 19, :scale => 2, :default => 0.0
  end

  add_index "allowances", ["route_id", "vehiclegroup_id"], :name => "allowance_routes"

  create_table "assetgroups", :id => false, :force => true do |t|
    t.integer   "id",                                               :null => false
    t.boolean   "deleted",                       :default => false
    t.string    "name"
    t.text      "description"
    t.float     "percent_decrease"
    t.timestamp "created_at",       :limit => 6,                    :null => false
    t.timestamp "updated_at",       :limit => 6,                    :null => false
  end

  create_table "assetorders", :force => true do |t|
    t.boolean   "deleted",                                                   :default => false
    t.integer   "asset_id"
    t.date      "date"
    t.integer   "quantity"
    t.string    "unit_name"
    t.text      "description"
    t.integer   "user_id"
    t.integer   "deleteuser_id"
    t.timestamp "created_at",    :limit => 6,                                                   :null => false
    t.timestamp "updated_at",    :limit => 6,                                                   :null => false
    t.decimal   "unit_price",                 :precision => 19, :scale => 2, :default => 0.0
    t.decimal   "total",                      :precision => 19, :scale => 2, :default => 0.0
  end

  create_table "assetpayments", :force => true do |t|
    t.boolean   "deleted",                                                   :default => false
    t.integer   "assetorder_id"
    t.date      "date"
    t.text      "description"
    t.integer   "user_id"
    t.integer   "deleteuser_id"
    t.timestamp "created_at",    :limit => 6,                                                   :null => false
    t.timestamp "updated_at",    :limit => 6,                                                   :null => false
    t.decimal   "total",                      :precision => 19, :scale => 2, :default => 0.0
  end

  create_table "assets", :force => true do |t|
    t.boolean   "deleted",                                                   :default => false
    t.boolean   "enabled",                                                   :default => true
    t.string    "name"
    t.date      "date_purchase"
    t.string    "amount_type"
    t.integer   "quantity"
    t.string    "asset_type"
    t.text      "description"
    t.timestamp "created_at",    :limit => 6,                                                   :null => false
    t.timestamp "updated_at",    :limit => 6,                                                   :null => false
    t.decimal   "amount",                     :precision => 19, :scale => 2, :default => 0.0
    t.integer   "assetgroup_id"
  end

  create_table "attachments", :force => true do |t|
    t.boolean   "enabled",                     :default => true
    t.string    "name"
    t.string    "file_uid"
    t.string    "file_name"
    t.boolean   "media"
    t.integer   "imageable_id"
    t.string    "imageable_type"
    t.timestamp "created_at",     :limit => 6,                   :null => false
    t.timestamp "updated_at",     :limit => 6,                   :null => false
  end

  create_table "bankexpensegroups", :force => true do |t|
    t.boolean   "deleted",                                                         :default => false
    t.boolean   "enabled",                                                         :default => true
    t.string    "name"
    t.text      "description"
    t.timestamp "created_at",          :limit => 6,                                                   :null => false
    t.timestamp "updated_at",          :limit => 6,                                                   :null => false
    t.decimal   "total",                            :precision => 19, :scale => 2, :default => 0.0
    t.boolean   "inreport",                                                        :default => false
    t.integer   "bankexpensegroup_id"
  end

  create_table "bankexpenses", :force => true do |t|
    t.boolean   "deleted",                                                       :default => false
    t.boolean   "enabled",                                                       :default => true
    t.date      "date"
    t.integer   "debitgroup_id"
    t.integer   "creditgroup_id"
    t.integer   "taxinvoice_id"
    t.text      "description"
    t.timestamp "created_at",        :limit => 6,                                                   :null => false
    t.timestamp "updated_at",        :limit => 6,                                                   :null => false
    t.decimal   "total",                          :precision => 19, :scale => 2, :default => 0.0
    t.integer   "office_id"
    t.integer   "deleteuser_id"
    t.integer   "productorder_id"
    t.integer   "bankexpense_id"
    t.integer   "productrequest_id"
    t.integer   "assetorder_id"
    t.integer   "assetpayment_id"
    t.boolean   "bankledger",                                                    :default => false
    t.boolean   "pettycashledger",                                               :default => false
    t.boolean   "money_in"
  end

  create_table "bonusreceipts", :force => true do |t|
    t.boolean   "deleted",                                                     :default => false
    t.integer   "invoice_id"
    t.integer   "quantity"
    t.text      "description"
    t.integer   "office_id"
    t.timestamp "created_at",      :limit => 6,                                                   :null => false
    t.timestamp "updated_at",      :limit => 6,                                                   :null => false
    t.decimal   "total",                        :precision => 19, :scale => 2, :default => 0.0
    t.text      "load_location"
    t.date      "load_date"
    t.text      "load_hour"
    t.text      "unload_location"
    t.date      "unload_date"
    t.text      "unload_hour"
    t.integer   "user_id"
    t.integer   "deleteuser_id"
  end

  create_table "bookings", :force => true do |t|
    t.boolean   "deleted",                    :default => false
    t.boolean   "enabled",                    :default => true
    t.date      "date"
    t.integer   "office_id"
    t.integer   "event_id"
    t.integer   "vehicle_id"
    t.string    "description"
    t.integer   "user_id"
    t.integer   "deleteuser_id"
    t.timestamp "created_at",    :limit => 6,                    :null => false
    t.timestamp "updated_at",    :limit => 6,                    :null => false
  end

  create_table "cashdailylogs", :force => true do |t|
    t.date      "date"
    t.timestamp "created_at", :limit => 6,                                                 :null => false
    t.timestamp "updated_at", :limit => 6,                                                 :null => false
    t.decimal   "total",                   :precision => 19, :scale => 2, :default => 0.0
  end

  create_table "commodities", :force => true do |t|
    t.boolean   "deleted",                                                      :default => false
    t.boolean   "enabled",                                                      :default => true
    t.string    "name"
    t.string    "description"
    t.timestamp "created_at",       :limit => 6,                                                   :null => false
    t.timestamp "updated_at",       :limit => 6,                                                   :null => false
    t.decimal   "insurance_amount",              :precision => 19, :scale => 2, :default => 0.0
  end

  create_table "companies", :force => true do |t|
    t.boolean   "deleted",                  :default => false
    t.boolean   "enabled",                  :default => true
    t.string    "name"
    t.string    "abbr"
    t.string    "description"
    t.timestamp "created_at",  :limit => 6,                    :null => false
    t.timestamp "updated_at",  :limit => 6,                    :null => false
  end

  create_table "containermemos", :force => true do |t|
    t.boolean   "deleted",                                                    :default => false
    t.boolean   "enabled",                                                    :default => true
    t.date      "date"
    t.string    "container_type"
    t.integer   "container_id"
    t.integer   "operator_id"
    t.integer   "storage_day"
    t.text      "description"
    t.timestamp "created_at",     :limit => 6,                                                   :null => false
    t.timestamp "updated_at",     :limit => 6,                                                   :null => false
    t.decimal   "container_fee",               :precision => 19, :scale => 2, :default => 0.0
    t.decimal   "additional_fee",              :precision => 19, :scale => 2, :default => 0.0
    t.decimal   "total",                       :precision => 19, :scale => 2, :default => 0.0
  end

  create_table "containers", :force => true do |t|
    t.boolean   "deleted",                      :default => false
    t.boolean   "enabled",                      :default => true
    t.string    "containernumber"
    t.timestamp "created_at",      :limit => 6,                    :null => false
    t.timestamp "updated_at",      :limit => 6,                    :null => false
    t.string    "category"
  end

  create_table "customers", :force => true do |t|
    t.boolean   "deleted",                                                              :default => false
    t.boolean   "enabled",                                                              :default => true
    t.string    "name"
    t.string    "address"
    t.string    "city"
    t.string    "contact"
    t.string    "phone"
    t.string    "mobile"
    t.string    "fax"
    t.string    "npwp"
    t.integer   "terms_of_payment_in_days"
    t.text      "description"
    t.timestamp "created_at",               :limit => 6,                                                   :null => false
    t.timestamp "updated_at",               :limit => 6,                                                   :null => false
    t.decimal   "wholesale_price",                       :precision => 19, :scale => 2, :default => 0.0
    t.string    "email"
    t.string    "email_alt"
    t.time      "load_hour",                :limit => 6
    t.time      "unload_hour",              :limit => 6
  end

  create_table "driverexpenses", :force => true do |t|
    t.boolean   "deleted",                                                   :default => false
    t.integer   "driver_id"
    t.integer   "office_id"
    t.date      "date"
    t.text      "description"
    t.integer   "deleteuser_id"
    t.timestamp "created_at",    :limit => 6,                                                   :null => false
    t.timestamp "updated_at",    :limit => 6,                                                   :null => false
    t.decimal   "total",                      :precision => 19, :scale => 2, :default => 0.0
    t.integer   "user_id"
    t.integer   "helper_id"
    t.decimal   "weight_loss",                :precision => 19, :scale => 2, :default => 0.0
    t.decimal   "accident",                   :precision => 19, :scale => 2, :default => 0.0
    t.decimal   "sparepart",                  :precision => 19, :scale => 2, :default => 0.0
    t.decimal   "bon",                        :precision => 19, :scale => 2, :default => 0.0
  end

  create_table "driverlogs", :force => true do |t|
    t.boolean   "deleted",                  :default => false
    t.boolean   "enabled",                  :default => true
    t.boolean   "ready",                    :default => false
    t.boolean   "absent",                   :default => false
    t.integer   "driver_id"
    t.text      "description"
    t.timestamp "created_at",  :limit => 6,                    :null => false
    t.timestamp "updated_at",  :limit => 6,                    :null => false
  end

  create_table "drivers", :force => true do |t|
    t.boolean   "deleted",                                                              :default => false
    t.boolean   "enabled",                                                              :default => true
    t.string    "name"
    t.string    "address"
    t.string    "city"
    t.string    "phone"
    t.string    "mobile"
    t.string    "driver_licence"
    t.date      "driver_licence_expiry"
    t.string    "id_card"
    t.date      "id_card_expiry"
    t.date      "start_working"
    t.integer   "salary"
    t.integer   "terms_of_payment_in_days"
    t.integer   "min_wages"
    t.string    "status"
    t.text      "description"
    t.timestamp "created_at",               :limit => 6,                                                   :null => false
    t.timestamp "updated_at",               :limit => 6,                                                   :null => false
    t.string    "emergency_number"
    t.decimal   "weight_loss",                           :precision => 19, :scale => 2, :default => 0.0
    t.decimal   "accident",                              :precision => 19, :scale => 2, :default => 0.0
    t.decimal   "sparepart",                             :precision => 19, :scale => 2, :default => 0.0
    t.decimal   "bon",                                   :precision => 19, :scale => 2, :default => 0.0
    t.decimal   "saving",                                :precision => 19, :scale => 2, :default => 0.0
    t.integer   "vehicle_id"
    t.string    "bank_account"
    t.string    "bank_name"
    t.integer   "bankexpensegroup_id"
  end

  create_table "eventcleaningmemos", :force => true do |t|
    t.boolean   "deleted",                       :default => false
    t.boolean   "enabled",                       :default => true
    t.date      "date"
    t.integer   "event_id"
    t.integer   "driver_id"
    t.integer   "vehicle_id"
    t.integer   "container_id"
    t.integer   "isotank_id"
    t.text      "description"
    t.text      "next_description"
    t.timestamp "created_at",       :limit => 6,                    :null => false
    t.timestamp "updated_at",       :limit => 6,                    :null => false
  end

  create_table "eventmemos", :force => true do |t|
    t.boolean   "deleted",                    :default => false
    t.boolean   "enabled",                    :default => true
    t.date      "date"
    t.integer   "event_id"
    t.integer   "driver_id"
    t.integer   "customer_id"
    t.integer   "vehicle_id"
    t.integer   "commodity_id"
    t.integer   "quantity",                   :default => 0
    t.integer   "route_id"
    t.string    "route_summary"
    t.integer   "container_id"
    t.integer   "isotank_id"
    t.string    "driver_phone"
    t.text      "description"
    t.timestamp "created_at",    :limit => 6,                    :null => false
    t.timestamp "updated_at",    :limit => 6,                    :null => false
    t.string    "platform_type"
  end

  create_table "events", :force => true do |t|
    t.boolean   "deleted",                                                        :default => false
    t.date      "start_date"
    t.date      "end_date"
    t.string    "summary"
    t.text      "description"
    t.timestamp "created_at",         :limit => 6,                                                   :null => false
    t.timestamp "updated_at",         :limit => 6,                                                   :null => false
    t.boolean   "cancelled",                                                      :default => false
    t.integer   "customer_id"
    t.boolean   "authorised",                                                     :default => false
    t.timestamp "authorised_dated",   :limit => 6
    t.string    "payments_by"
    t.integer   "qty"
    t.boolean   "invoicetrain",                                                   :default => false
    t.string    "cargo_number"
    t.string    "cargo_type"
    t.integer   "volume"
    t.integer   "office_id"
    t.boolean   "pos_sby",                                                        :default => false
    t.boolean   "pos_smg",                                                        :default => false
    t.boolean   "pos_jkt",                                                        :default => false
    t.boolean   "pos_smt",                                                        :default => false
    t.boolean   "pos_lorry",                                                      :default => false
    t.string    "vendor_name"
    t.string    "long_id"
    t.integer   "station_id"
    t.string    "route_summary"
    t.boolean   "need_vendor",                                                    :default => false
    t.integer   "user_id"
    t.integer   "commodity_id"
    t.integer   "route_id"
    t.integer   "truck_quantity"
    t.integer   "company_id"
    t.integer   "estimated_tonage"
    t.string    "tanktype"
    t.date      "load_date"
    t.date      "unload_date"
    t.integer   "operator_id"
    t.integer   "routetrain_id"
    t.decimal   "downpayment_amount",              :precision => 19, :scale => 2
    t.date      "downpayment_date"
    t.boolean   "losing",                                                         :default => false
    t.string    "price_per_type"
  end

  add_index "events", ["id", "start_date", "end_date", "customer_id"], :name => "index_events_on_customer_id"

  create_table "eventsalesorders", :force => true do |t|
    t.boolean   "deleted",                  :default => false
    t.boolean   "enabled",                  :default => true
    t.integer   "customer_id"
    t.integer   "event_id"
    t.string    "long_id"
    t.timestamp "created_at",  :limit => 6,                    :null => false
    t.timestamp "updated_at",  :limit => 6,                    :null => false
  end

  create_table "eventvendors", :force => true do |t|
    t.boolean   "deleted",                         :default => false
    t.boolean   "enabled",                         :default => true
    t.integer   "event_id"
    t.string    "name"
    t.string    "vehicle_current_id"
    t.string    "iso_cont_number"
    t.integer   "quantity"
    t.timestamp "created_at",         :limit => 6,                    :null => false
    t.timestamp "updated_at",         :limit => 6,                    :null => false
  end

  create_table "helpers", :force => true do |t|
    t.boolean   "deleted",                                                           :default => false
    t.boolean   "enabled",                                                           :default => true
    t.string    "name"
    t.string    "address"
    t.string    "city"
    t.string    "phone"
    t.string    "mobile"
    t.string    "driver_licence"
    t.date      "driver_licence_expiry"
    t.string    "id_card"
    t.date      "id_card_expiry"
    t.integer   "salary"
    t.text      "description"
    t.integer   "driver_id"
    t.timestamp "created_at",            :limit => 6,                                                   :null => false
    t.timestamp "updated_at",            :limit => 6,                                                   :null => false
    t.string    "emergency_number"
    t.decimal   "weight_loss",                        :precision => 19, :scale => 2, :default => 0.0
    t.decimal   "accident",                           :precision => 19, :scale => 2, :default => 0.0
    t.decimal   "sparepart",                          :precision => 19, :scale => 2, :default => 0.0
    t.decimal   "bon",                                :precision => 19, :scale => 2, :default => 0.0
    t.decimal   "saving",                             :precision => 19, :scale => 2, :default => 0.0
  end

  create_table "incentives", :force => true do |t|
    t.boolean   "deleted",                                                   :default => false
    t.integer   "invoice_id"
    t.integer   "quantity"
    t.text      "description"
    t.integer   "office_id"
    t.integer   "user_id"
    t.integer   "deleteuser_id"
    t.timestamp "created_at",    :limit => 6,                                                   :null => false
    t.timestamp "updated_at",    :limit => 6,                                                   :null => false
    t.decimal   "total",                      :precision => 19, :scale => 2, :default => 0.0
  end

  create_table "insuranceexpenses", :force => true do |t|
    t.boolean  "deleted",                                              :default => false
    t.boolean  "enabled",                                              :default => true
    t.date     "date"
    t.integer  "invoice_id"
    t.integer  "insurancevendor_id"
    t.text     "description"
    t.integer  "user_id"
    t.string   "expensetype",                                          :default => "Kredit"
    t.integer  "officeexpensegroup_id"
    t.integer  "bankexpensegroup_id"
    t.integer  "deleteuser_id"
    t.datetime "created_at",                                                                 :null => false
    t.datetime "updated_at",                                                                 :null => false
    t.decimal  "tsi_total",             :precision => 19, :scale => 2, :default => 0.0
    t.float    "insurance_rate",                                       :default => 0.0
    t.decimal  "total",                 :precision => 19, :scale => 2, :default => 0.0
  end

  create_table "insurancevendors", :force => true do |t|
    t.boolean  "deleted",                :default => false
    t.boolean  "enabled",                :default => true
    t.string   "name"
    t.text     "description"
    t.string   "pic"
    t.string   "phone"
    t.string   "mobile"
    t.string   "bank_name"
    t.string   "bank_account"
    t.integer  "term_of_payment_in_day"
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
  end

  create_table "invoicereturns", :force => true do |t|
    t.boolean   "deleted",                                                      :default => false
    t.date      "date"
    t.integer   "invoice_id"
    t.integer   "quantity"
    t.integer   "gas_leftover",                                                 :default => 0
    t.text      "description"
    t.integer   "office_id"
    t.timestamp "created_at",       :limit => 6,                                                   :null => false
    t.timestamp "updated_at",       :limit => 6,                                                   :null => false
    t.decimal   "driver_allowance",              :precision => 19, :scale => 2, :default => 0.0
    t.decimal   "gas_allowance",                 :precision => 19, :scale => 2, :default => 0.0
    t.decimal   "tol_fee",                       :precision => 19, :scale => 2, :default => 0.0
    t.decimal   "total",                         :precision => 19, :scale => 2, :default => 0.0
    t.decimal   "misc_allowance",                :precision => 19, :scale => 2, :default => 0.0
    t.integer   "user_id"
    t.decimal   "helper_allowance",              :precision => 19, :scale => 2, :default => 0.0
    t.integer   "deleteuser_id"
    t.decimal   "ferry_fee",                     :precision => 19, :scale => 2, :default => 0.0
    t.decimal   "premi_allowance",               :precision => 19, :scale => 2, :default => 0.0
  end

  create_table "invoices", :force => true do |t|
    t.boolean   "deleted",                                                          :default => false
    t.boolean   "enabled",                                                          :default => true
    t.date      "date"
    t.string    "ship_name"
    t.integer   "driver_id"
    t.integer   "customer_id"
    t.integer   "vehicle_id"
    t.integer   "route_id"
    t.integer   "vehiclegroup_id"
    t.integer   "quantity"
    t.integer   "gas_litre",                                                        :default => 0
    t.integer   "gas_voucher",                                                      :default => 0
    t.integer   "gas_leftover",                                                     :default => 0
    t.float     "insurance_rate",                                                   :default => 0.0
    t.string    "trip_type"
    t.text      "description"
    t.integer   "office_id"
    t.integer   "invoice_id"
    t.timestamp "created_at",           :limit => 6,                                                    :null => false
    t.timestamp "updated_at",           :limit => 6,                                                    :null => false
    t.decimal   "gas_cost",                          :precision => 19, :scale => 2, :default => 0.0
    t.decimal   "gas_allowance",                     :precision => 19, :scale => 2, :default => 0.0
    t.decimal   "driver_allowance",                  :precision => 19, :scale => 2, :default => 0.0
    t.decimal   "ferry_fee",                         :precision => 19, :scale => 2, :default => 0.0
    t.decimal   "tol_fee",                           :precision => 19, :scale => 2, :default => 0.0
    t.decimal   "price_per",                         :precision => 19, :scale => 2, :default => 0.0
    t.decimal   "insurance",                         :precision => 19, :scale => 2, :default => 0.0
    t.decimal   "total",                             :precision => 19, :scale => 2, :default => 0.0
    t.decimal   "misc_allowance",                    :precision => 19, :scale => 2, :default => 0.0
    t.integer   "user_id"
    t.decimal   "helper_allowance",                  :precision => 19, :scale => 2, :default => 0.0
    t.boolean   "need_helper",                                                      :default => false
    t.integer   "deleteuser_id"
    t.integer   "gas_start",                                                        :default => 0
    t.string    "spk_number"
    t.decimal   "incentive",                         :precision => 19, :scale => 2, :default => 0.0
    t.boolean   "invoicetrain",                                                     :default => false
    t.string    "driver_phone"
    t.integer   "isotank_id"
    t.string    "transporttype",                                                    :default => "TRUK"
    t.integer   "port_id"
    t.integer   "ship_id"
    t.decimal   "train_fee",                         :precision => 19, :scale => 2, :default => 0.0
    t.integer   "container_id"
    t.string    "tanktype"
    t.string    "container_number"
    t.string    "isotank_number"
    t.integer   "event_id"
    t.boolean   "premi",                                                            :default => false
    t.decimal   "premi_allowance",                   :precision => 19, :scale => 2, :default => 0.0
    t.integer   "routetrain_id"
    t.integer   "operator_id"
    t.integer   "shipoperator_id"
    t.integer   "routeship_id"
    t.boolean   "invoicemultimode",                                                 :default => false
    t.string    "cargo_type"
    t.string    "vehicle_duplicate"
    t.integer   "vehicle_duplicate_id"
    t.integer   "weight_gross",                                                     :default => 0
    t.date      "load_date"
    t.boolean   "is_insurance",                                                     :default => false
    t.decimal   "tsi_total",                         :precision => 19, :scale => 2, :default => 0.0
  end

  add_index "invoices", ["date", "customer_id", "event_id", "invoicetrain"], :name => "invoice_events"

  create_table "isotanks", :force => true do |t|
    t.boolean   "deleted",                    :default => false
    t.boolean   "enabled",                    :default => true
    t.string    "isotanknumber"
    t.timestamp "created_at",    :limit => 6,                    :null => false
    t.timestamp "updated_at",    :limit => 6,                    :null => false
    t.string    "category"
  end

  create_table "legalities", :force => true do |t|
    t.boolean   "deleted",                  :default => false
    t.boolean   "enabled",                  :default => true
    t.string    "name"
    t.string    "number"
    t.text      "description"
    t.date      "validity"
    t.timestamp "created_at",  :limit => 6,                    :null => false
    t.timestamp "updated_at",  :limit => 6,                    :null => false
  end

  create_table "officeexpensegroups", :force => true do |t|
    t.boolean   "deleted",                            :default => false
    t.boolean   "enabled",                            :default => true
    t.integer   "officeexpensegroup_id"
    t.string    "name"
    t.text      "description"
    t.timestamp "created_at",            :limit => 6,                    :null => false
    t.timestamp "updated_at",            :limit => 6,                    :null => false
  end

  create_table "officeexpenses", :force => true do |t|
    t.boolean   "deleted",                                                           :default => false
    t.boolean   "enabled",                                                           :default => true
    t.date      "date"
    t.string    "expensetype"
    t.text      "description"
    t.integer   "vehicle_id"
    t.integer   "officeexpensegroup_id"
    t.timestamp "created_at",            :limit => 6,                                                   :null => false
    t.timestamp "updated_at",            :limit => 6,                                                   :null => false
    t.decimal   "total",                              :precision => 19, :scale => 2, :default => 0.0
    t.integer   "office_id"
    t.integer   "deleteuser_id"
    t.integer   "bankexpense_id"
    t.integer   "bankexpensegroup_id"
    t.integer   "container_id"
    t.integer   "isotank_id"
  end

  create_table "offices", :force => true do |t|
    t.boolean   "deleted",                  :default => false
    t.boolean   "enabled",                  :default => true
    t.string    "name"
    t.string    "abbr"
    t.text      "description"
    t.timestamp "created_at",  :limit => 6,                    :null => false
    t.timestamp "updated_at",  :limit => 6,                    :null => false
  end

  create_table "operators", :force => true do |t|
    t.boolean   "deleted",                   :default => false
    t.boolean   "enabled",                   :default => true
    t.string    "name"
    t.string    "abbr"
    t.text      "description"
    t.timestamp "created_at",   :limit => 6,                    :null => false
    t.timestamp "updated_at",   :limit => 6,                    :null => false
    t.string    "operatortype"
  end

  create_table "paymentchecks", :force => true do |t|
    t.boolean   "deleted",                                                 :default => false
    t.date      "date"
    t.string    "check_no"
    t.integer   "supplier_id"
    t.timestamp "created_at",  :limit => 6,                                                   :null => false
    t.timestamp "updated_at",  :limit => 6,                                                   :null => false
    t.decimal   "total",                    :precision => 19, :scale => 2, :default => 0.0
  end

  create_table "payrollreturns", :force => true do |t|
    t.boolean   "deleted",                                                          :default => false
    t.date      "date"
    t.integer   "payroll_id"
    t.integer   "user_id"
    t.integer   "deleteuser_id"
    t.timestamp "created_at",           :limit => 6,                                                   :null => false
    t.timestamp "updated_at",           :limit => 6,                                                   :null => false
    t.decimal   "holidays_payment",                  :precision => 19, :scale => 2, :default => 0.0
    t.decimal   "non_holidays_payment",              :precision => 19, :scale => 2, :default => 0.0
    t.decimal   "weight_loss",                       :precision => 19, :scale => 2, :default => 0.0
    t.decimal   "accident",                          :precision => 19, :scale => 2, :default => 0.0
    t.decimal   "sparepart",                         :precision => 19, :scale => 2, :default => 0.0
    t.decimal   "bon",                               :precision => 19, :scale => 2, :default => 0.0
    t.decimal   "allowance",                         :precision => 19, :scale => 2, :default => 0.0
    t.decimal   "saving",                            :precision => 19, :scale => 2, :default => 0.0
    t.decimal   "saving_reduction",                  :precision => 19, :scale => 2, :default => 0.0
    t.decimal   "total",                             :precision => 19, :scale => 2, :default => 0.0
    t.decimal   "bonus",                             :precision => 19, :scale => 2, :default => 0.0
  end

  create_table "payrolls", :force => true do |t|
    t.boolean   "deleted",                                                          :default => false
    t.date      "date"
    t.date      "period_start"
    t.date      "period_end"
    t.integer   "driver_id"
    t.integer   "helper_id"
    t.integer   "vehicle_id"
    t.integer   "holidays"
    t.integer   "non_holidays"
    t.integer   "user_id"
    t.integer   "deleteuser_id"
    t.timestamp "created_at",           :limit => 6,                                                   :null => false
    t.timestamp "updated_at",           :limit => 6,                                                   :null => false
    t.decimal   "holidays_payment",                  :precision => 19, :scale => 2, :default => 0.0
    t.decimal   "non_holidays_payment",              :precision => 19, :scale => 2, :default => 0.0
    t.decimal   "holidays_fare",                     :precision => 19, :scale => 2, :default => 0.0
    t.decimal   "non_holidays_fare",                 :precision => 19, :scale => 2, :default => 0.0
    t.decimal   "weight_loss",                       :precision => 19, :scale => 2, :default => 0.0
    t.decimal   "accident",                          :precision => 19, :scale => 2, :default => 0.0
    t.decimal   "sparepart",                         :precision => 19, :scale => 2, :default => 0.0
    t.decimal   "bon",                               :precision => 19, :scale => 2, :default => 0.0
    t.decimal   "allowance",                         :precision => 19, :scale => 2, :default => 0.0
    t.decimal   "saving",                            :precision => 19, :scale => 2, :default => 0.0
    t.decimal   "saving_reduction",                  :precision => 19, :scale => 2, :default => 0.0
    t.decimal   "total",                             :precision => 19, :scale => 2, :default => 0.0
    t.decimal   "master_weight_loss",                :precision => 19, :scale => 2, :default => 0.0
    t.decimal   "master_sparepart",                  :precision => 19, :scale => 2, :default => 0.0
    t.decimal   "master_bon",                        :precision => 19, :scale => 2, :default => 0.0
    t.decimal   "master_saving",                     :precision => 19, :scale => 2, :default => 0.0
    t.decimal   "master_accident",                   :precision => 19, :scale => 2, :default => 0.0
    t.integer   "office_id"
    t.decimal   "bonus",                             :precision => 19, :scale => 2, :default => 0.0
    t.decimal   "helper_fee",                        :precision => 19, :scale => 2, :default => 0.0
  end

  create_table "ports", :force => true do |t|
    t.boolean   "deleted",                 :default => false
    t.boolean   "enabled",                 :default => true
    t.string    "name"
    t.text      "address"
    t.string    "city"
    t.timestamp "created_at", :limit => 6,                    :null => false
    t.timestamp "updated_at", :limit => 6,                    :null => false
  end

  create_table "productgroups", :force => true do |t|
    t.boolean   "deleted",                  :default => false
    t.boolean   "enabled",                  :default => true
    t.string    "name"
    t.text      "description"
    t.timestamp "created_at",  :limit => 6,                    :null => false
    t.timestamp "updated_at",  :limit => 6,                    :null => false
    t.boolean   "tire_flag",                :default => false
  end

  create_table "productorderitemreturns", :force => true do |t|
    t.integer   "productorder_id"
    t.integer   "product_id"
    t.integer   "quantity"
    t.integer   "supplier_id"
    t.boolean   "bon"
    t.timestamp "created_at",      :limit => 6,                                                 :null => false
    t.timestamp "updated_at",      :limit => 6,                                                 :null => false
    t.decimal   "price_per",                    :precision => 19, :scale => 2, :default => 0.0
    t.decimal   "total",                        :precision => 19, :scale => 2, :default => 0.0
    t.date      "date"
    t.text      "description"
  end

  create_table "productorderitems", :force => true do |t|
    t.integer   "productorder_id"
    t.integer   "productrequestitem_id"
    t.integer   "product_id"
    t.decimal   "quantity"
    t.decimal   "requestquantity"
    t.integer   "supplier_id"
    t.boolean   "bon"
    t.timestamp "created_at",            :limit => 6,                                                 :null => false
    t.timestamp "updated_at",            :limit => 6,                                                 :null => false
    t.decimal   "price_per",                          :precision => 19, :scale => 2, :default => 0.0
    t.decimal   "total",                              :precision => 19, :scale => 2, :default => 0.0
    t.integer   "paymentcheck_id"
  end

  create_table "productorders", :force => true do |t|
    t.boolean   "deleted",                                                       :default => false
    t.date      "date"
    t.text      "description"
    t.integer   "staff_id"
    t.integer   "productrequest_id"
    t.timestamp "created_at",        :limit => 6,                                                   :null => false
    t.timestamp "updated_at",        :limit => 6,                                                   :null => false
    t.decimal   "total",                          :precision => 19, :scale => 2, :default => 0.0
    t.integer   "user_id"
    t.integer   "deleteuser_id"
  end

  create_table "productpricelogs", :force => true do |t|
    t.integer   "product_id"
    t.timestamp "created_at", :limit => 6,                                                 :null => false
    t.timestamp "updated_at", :limit => 6,                                                 :null => false
    t.decimal   "old_price",               :precision => 19, :scale => 2, :default => 0.0
    t.decimal   "new_price",               :precision => 19, :scale => 2, :default => 0.0
  end

  create_table "productrequestitems", :force => true do |t|
    t.integer   "productrequest_id"
    t.integer   "product_id"
    t.decimal   "quantity"
    t.decimal   "stockgiven"
    t.boolean   "requestorder",                                                  :default => false
    t.timestamp "created_at",        :limit => 6,                                                   :null => false
    t.timestamp "updated_at",        :limit => 6,                                                   :null => false
    t.decimal   "total",                          :precision => 19, :scale => 2, :default => 0.0
  end

  create_table "productrequests", :force => true do |t|
    t.boolean   "deleted",                      :default => false
    t.date      "date"
    t.integer   "driver_id"
    t.integer   "vehicle_id"
    t.text      "description"
    t.integer   "productgroup_id"
    t.timestamp "created_at",      :limit => 6,                    :null => false
    t.timestamp "updated_at",      :limit => 6,                    :null => false
  end

  create_table "products", :force => true do |t|
    t.boolean   "deleted",                                                      :default => false
    t.boolean   "enabled",                                                      :default => true
    t.string    "name"
    t.string    "sku"
    t.string    "barcode"
    t.string    "unit_name"
    t.string    "discount_percent"
    t.string    "status"
    t.integer   "distance"
    t.text      "description"
    t.integer   "warehouse_id"
    t.decimal   "stock",                                                        :default => 0.0
    t.integer   "productgroup_id"
    t.timestamp "created_at",       :limit => 6,                                                   :null => false
    t.timestamp "updated_at",       :limit => 6,                                                   :null => false
    t.decimal   "unit_price",                    :precision => 19, :scale => 2, :default => 0.0
    t.decimal   "discount_price",                :precision => 19, :scale => 2
    t.boolean   "archive",                                                      :default => false
  end

  create_table "productsales", :force => true do |t|
    t.boolean   "deleted",                                                :default => false
    t.boolean   "onsale",                                                 :default => false
    t.string    "name"
    t.string    "unit_name"
    t.timestamp "created_at", :limit => 6,                                                   :null => false
    t.timestamp "updated_at", :limit => 6,                                                   :null => false
    t.decimal   "unit_price",              :precision => 19, :scale => 2, :default => 0.0
  end

  create_table "productstocks", :force => true do |t|
    t.boolean   "deleted",                 :default => false
    t.integer   "product_id"
    t.integer   "quantity"
    t.timestamp "created_at", :limit => 6,                    :null => false
    t.timestamp "updated_at", :limit => 6,                    :null => false
  end

  create_table "receiptdrivers", :force => true do |t|
    t.boolean   "deleted",                                                      :default => false
    t.integer   "driverexpense_id"
    t.integer   "user_id"
    t.integer   "deleteuser_id"
    t.timestamp "created_at",       :limit => 6,                                                   :null => false
    t.timestamp "updated_at",       :limit => 6,                                                   :null => false
    t.decimal   "total",                         :precision => 19, :scale => 2, :default => 0.0
    t.decimal   "weight_loss",                   :precision => 19, :scale => 2, :default => 0.0
    t.decimal   "accident",                      :precision => 19, :scale => 2, :default => 0.0
    t.decimal   "sparepart",                     :precision => 19, :scale => 2, :default => 0.0
    t.decimal   "bon",                           :precision => 19, :scale => 2, :default => 0.0
  end

  create_table "receiptexpenses", :force => true do |t|
    t.boolean   "deleted",                                                           :default => false
    t.integer   "officeexpense_id"
    t.integer   "officeexpensegroup_id"
    t.string    "expensetype"
    t.timestamp "created_at",            :limit => 6,                                                   :null => false
    t.timestamp "updated_at",            :limit => 6,                                                   :null => false
    t.decimal   "total",                              :precision => 19, :scale => 2, :default => 0.0
    t.integer   "user_id"
    t.integer   "deleteuser_id"
  end

  create_table "receiptincentives", :force => true do |t|
    t.boolean   "deleted",                                                   :default => false
    t.integer   "invoice_id"
    t.date      "date"
    t.integer   "incentive_id"
    t.integer   "user_id"
    t.integer   "deleteuser_id"
    t.timestamp "created_at",    :limit => 6,                                                   :null => false
    t.timestamp "updated_at",    :limit => 6,                                                   :null => false
    t.decimal   "total",                      :precision => 19, :scale => 2, :default => 0.0
  end

  create_table "receiptinsurances", :force => true do |t|
    t.boolean  "deleted",                                              :default => false
    t.boolean  "enabled",                                              :default => true
    t.date     "date"
    t.integer  "insuranceexpense_id"
    t.text     "description"
    t.integer  "user_id"
    t.string   "expensetype",                                          :default => "Kredit"
    t.integer  "officeexpensegroup_id"
    t.integer  "bankexpensegroup_id"
    t.datetime "created_at",                                                                 :null => false
    t.datetime "updated_at",                                                                 :null => false
    t.decimal  "tsi_total",             :precision => 19, :scale => 2, :default => 0.0
    t.float    "insurance_rate",                                       :default => 0.0
    t.decimal  "total",                 :precision => 19, :scale => 2, :default => 0.0
  end

  create_table "receiptorders", :force => true do |t|
    t.boolean   "deleted",                                                     :default => false
    t.date      "date"
    t.integer   "productorder_id"
    t.timestamp "created_at",      :limit => 6,                                                   :null => false
    t.timestamp "updated_at",      :limit => 6,                                                   :null => false
    t.decimal   "total",                        :precision => 19, :scale => 2, :default => 0.0
    t.decimal   "bon",                          :precision => 19, :scale => 2, :default => 0.0
    t.integer   "user_id"
    t.integer   "deleteuser_id"
  end

  create_table "receiptpayrollreturns", :force => true do |t|
    t.boolean   "deleted",                                                          :default => false
    t.integer   "payroll_id"
    t.integer   "user_id"
    t.integer   "deleteuser_id"
    t.timestamp "created_at",           :limit => 6,                                                   :null => false
    t.timestamp "updated_at",           :limit => 6,                                                   :null => false
    t.decimal   "holidays_payment",                  :precision => 19, :scale => 2, :default => 0.0
    t.decimal   "non_holidays_payment",              :precision => 19, :scale => 2, :default => 0.0
    t.decimal   "weight_loss",                       :precision => 19, :scale => 2, :default => 0.0
    t.decimal   "accident",                          :precision => 19, :scale => 2, :default => 0.0
    t.decimal   "sparepart",                         :precision => 19, :scale => 2, :default => 0.0
    t.decimal   "bon",                               :precision => 19, :scale => 2, :default => 0.0
    t.decimal   "allowance",                         :precision => 19, :scale => 2, :default => 0.0
    t.decimal   "saving",                            :precision => 19, :scale => 2, :default => 0.0
    t.decimal   "saving_reduction",                  :precision => 19, :scale => 2, :default => 0.0
    t.decimal   "total",                             :precision => 19, :scale => 2, :default => 0.0
    t.decimal   "bonus",                             :precision => 19, :scale => 2, :default => 0.0
  end

  create_table "receiptpayrolls", :force => true do |t|
    t.boolean   "deleted",                                                          :default => false
    t.integer   "payroll_id"
    t.integer   "user_id"
    t.integer   "deleteuser_id"
    t.timestamp "created_at",           :limit => 6,                                                   :null => false
    t.timestamp "updated_at",           :limit => 6,                                                   :null => false
    t.decimal   "holidays_payment",                  :precision => 19, :scale => 2, :default => 0.0
    t.decimal   "non_holidays_payment",              :precision => 19, :scale => 2, :default => 0.0
    t.decimal   "weight_loss",                       :precision => 19, :scale => 2, :default => 0.0
    t.decimal   "accident",                          :precision => 19, :scale => 2, :default => 0.0
    t.decimal   "sparepart",                         :precision => 19, :scale => 2, :default => 0.0
    t.decimal   "bon",                               :precision => 19, :scale => 2, :default => 0.0
    t.decimal   "allowance",                         :precision => 19, :scale => 2, :default => 0.0
    t.decimal   "saving",                            :precision => 19, :scale => 2, :default => 0.0
    t.decimal   "saving_reduction",                  :precision => 19, :scale => 2, :default => 0.0
    t.decimal   "total",                             :precision => 19, :scale => 2, :default => 0.0
    t.decimal   "bonus",                             :precision => 19, :scale => 2, :default => 0.0
  end

  create_table "receiptpremis", :force => true do |t|
    t.boolean   "deleted",                                                     :default => false
    t.integer   "invoice_id"
    t.date      "date"
    t.integer   "bonusreceipt_id"
    t.timestamp "created_at",      :limit => 6,                                                   :null => false
    t.timestamp "updated_at",      :limit => 6,                                                   :null => false
    t.decimal   "total",                        :precision => 19, :scale => 2, :default => 0.0
    t.integer   "user_id"
    t.integer   "deleteuser_id"
  end

  create_table "receiptreturns", :force => true do |t|
    t.boolean   "deleted",                                                      :default => false
    t.integer   "invoice_id"
    t.integer   "quantity"
    t.text      "description"
    t.integer   "office_id"
    t.timestamp "created_at",       :limit => 6,                                                   :null => false
    t.timestamp "updated_at",       :limit => 6,                                                   :null => false
    t.decimal   "driver_allowance",              :precision => 19, :scale => 2, :default => 0.0
    t.decimal   "gas_allowance",                 :precision => 19, :scale => 2, :default => 0.0
    t.decimal   "tol_fee",                       :precision => 19, :scale => 2, :default => 0.0
    t.decimal   "total",                         :precision => 19, :scale => 2, :default => 0.0
    t.integer   "user_id"
    t.decimal   "misc_allowance",                :precision => 19, :scale => 2, :default => 0.0
    t.decimal   "helper_allowance",              :precision => 19, :scale => 2, :default => 0.0
    t.integer   "deleteuser_id"
    t.integer   "invoicereturn_id"
    t.decimal   "ferry_fee",                     :precision => 19, :scale => 2, :default => 0.0
    t.decimal   "premi_allowance",               :precision => 19, :scale => 2, :default => 0.0
  end

  create_table "receipts", :force => true do |t|
    t.boolean   "deleted",                                                      :default => false
    t.integer   "invoice_id"
    t.integer   "quantity"
    t.text      "description"
    t.integer   "office_id"
    t.timestamp "created_at",       :limit => 6,                                                   :null => false
    t.timestamp "updated_at",       :limit => 6,                                                   :null => false
    t.decimal   "driver_allowance",              :precision => 19, :scale => 2, :default => 0.0
    t.decimal   "gas_allowance",                 :precision => 19, :scale => 2, :default => 0.0
    t.decimal   "total",                         :precision => 19, :scale => 2, :default => 0.0
    t.integer   "user_id"
    t.decimal   "misc_allowance",                :precision => 19, :scale => 2, :default => 0.0
    t.decimal   "ferry_fee",                     :precision => 19, :scale => 2, :default => 0.0
    t.decimal   "tol_fee",                       :precision => 19, :scale => 2, :default => 0.0
    t.decimal   "helper_allowance",              :precision => 19, :scale => 2, :default => 0.0
    t.integer   "deleteuser_id"
    t.decimal   "premi_allowance",               :precision => 19, :scale => 2, :default => 0.0
  end

  create_table "receiptsales", :force => true do |t|
    t.boolean   "deleted",                                                   :default => false
    t.date      "date"
    t.integer   "sale_id"
    t.integer   "user_id"
    t.timestamp "created_at",    :limit => 6,                                                   :null => false
    t.timestamp "updated_at",    :limit => 6,                                                   :null => false
    t.decimal   "total",                      :precision => 19, :scale => 2, :default => 0.0
    t.integer   "deleteuser_id"
  end

  create_table "receiptships", :force => true do |t|
    t.boolean   "deleted",                                                           :default => false
    t.boolean   "enabled",                                                           :default => true
    t.integer   "shipexpense_id"
    t.text      "description"
    t.integer   "user_id"
    t.string    "expensetype",                                                       :default => "Kredit"
    t.integer   "officeexpensegroup_id"
    t.integer   "bankexpensegroup_id"
    t.timestamp "created_at",            :limit => 6,                                                      :null => false
    t.timestamp "updated_at",            :limit => 6,                                                      :null => false
    t.decimal   "total",                              :precision => 19, :scale => 2, :default => 0.0
    t.integer   "gst_percentage",                                                    :default => 0
    t.decimal   "gst_tax",                            :precision => 19, :scale => 2, :default => 0.0
    t.decimal   "misc_total",                         :precision => 19, :scale => 2, :default => 0.0
    t.integer   "office_id"
    t.integer   "deleteuser_id"
  end

  create_table "receipttrains", :force => true do |t|
    t.boolean   "deleted",                                                           :default => false
    t.integer   "trainexpense_id"
    t.string    "description"
    t.integer   "office_id"
    t.integer   "officeexpensegroup_id"
    t.integer   "bankexpensegroup_id"
    t.string    "expensetype",                                                       :default => "Kredit"
    t.integer   "user_id"
    t.integer   "deleteuser_id"
    t.timestamp "created_at",            :limit => 6,                                                      :null => false
    t.timestamp "updated_at",            :limit => 6,                                                      :null => false
    t.decimal   "total",                              :precision => 19, :scale => 2, :default => 0.0
    t.integer   "gst_percentage",                                                    :default => 0
    t.decimal   "gst_tax",                            :precision => 19, :scale => 2, :default => 0.0
    t.decimal   "misc_total",                         :precision => 19, :scale => 2, :default => 0.0
  end

  create_table "roles", :force => true do |t|
    t.boolean   "deleted",                  :default => false
    t.boolean   "enabled",                  :default => true
    t.string    "name"
    t.text      "description"
    t.timestamp "created_at",  :limit => 6,                    :null => false
    t.timestamp "updated_at",  :limit => 6,                    :null => false
  end

  create_table "routegroups", :force => true do |t|
    t.boolean   "deleted",                  :default => false
    t.boolean   "enabled",                  :default => true
    t.string    "name"
    t.text      "description"
    t.timestamp "created_at",  :limit => 6,                    :null => false
    t.timestamp "updated_at",  :limit => 6,                    :null => false
  end

  create_table "routelocations", :force => true do |t|
    t.boolean   "deleted",                      :default => false
    t.boolean   "enabled",                      :default => true
    t.integer   "customer_id"
    t.integer   "route_id"
    t.string    "longitude_start"
    t.string    "latitude_start"
    t.string    "address_start"
    t.string    "longitude_end"
    t.string    "latitude_end"
    t.string    "address_end"
    t.integer   "status"
    t.timestamp "created_at",      :limit => 6,                    :null => false
    t.timestamp "updated_at",      :limit => 6,                    :null => false
  end

  create_table "routes", :force => true do |t|
    t.boolean   "deleted",                                                    :default => false
    t.boolean   "enabled",                                                    :default => true
    t.string    "name"
    t.integer   "distance"
    t.string    "price_per_type"
    t.string    "item_type"
    t.text      "description"
    t.integer   "customer_id"
    t.integer   "routegroup_id"
    t.timestamp "created_at",     :limit => 6,                                                    :null => false
    t.timestamp "updated_at",     :limit => 6,                                                    :null => false
    t.decimal   "bonus",                       :precision => 19, :scale => 2, :default => 0.0
    t.decimal   "tol_fee",                     :precision => 19, :scale => 2, :default => 0.0
    t.decimal   "ferry_fee",                   :precision => 19, :scale => 2, :default => 0.0
    t.decimal   "price_per",                   :precision => 19, :scale => 2, :default => 0.0
    t.boolean   "is_train",                                                   :default => false
    t.boolean   "is_sea",                                                     :default => false
    t.boolean   "is_isotank",                                                 :default => false
    t.string    "transporttype",                                              :default => "TRUK"
    t.string    "pos"
    t.integer   "route_id"
    t.integer   "estimated_hour"
    t.integer   "office_id"
    t.integer   "commodity_id"
  end

  add_index "routes", ["name", "customer_id", "office_id"], :name => "route_office"

  create_table "routeships", :force => true do |t|
    t.boolean   "deleted",                                                         :default => false
    t.boolean   "enabled",                                                         :default => true
    t.string    "name"
    t.integer   "operator_id"
    t.integer   "origin_port_id"
    t.integer   "destination_port_id"
    t.timestamp "created_at",          :limit => 6,                                                   :null => false
    t.timestamp "updated_at",          :limit => 6,                                                   :null => false
    t.decimal   "price_per",                        :precision => 19, :scale => 2, :default => 0.0
    t.integer   "tempo",                                                           :default => 0
    t.string    "description"
  end

  create_table "routetrains", :force => true do |t|
    t.boolean   "deleted",                                                            :default => false
    t.boolean   "enabled",                                                            :default => true
    t.string    "name"
    t.string    "container_type"
    t.string    "size"
    t.integer   "operator_id"
    t.integer   "origin_station_id"
    t.integer   "destination_station_id"
    t.timestamp "created_at",             :limit => 6,                                                   :null => false
    t.timestamp "updated_at",             :limit => 6,                                                   :null => false
    t.decimal   "price_per",                           :precision => 19, :scale => 2, :default => 0.0
    t.decimal   "gst_tax",                             :precision => 19, :scale => 2
    t.decimal   "total",                               :precision => 19, :scale => 2
  end

  create_table "saleitems", :force => true do |t|
    t.integer   "sale_id"
    t.integer   "productsale_id"
    t.integer   "quantity"
    t.timestamp "created_at",     :limit => 6,                                                 :null => false
    t.timestamp "updated_at",     :limit => 6,                                                 :null => false
    t.decimal   "price_per",                   :precision => 19, :scale => 2, :default => 0.0
    t.decimal   "total",                       :precision => 19, :scale => 2, :default => 0.0
  end

  create_table "sales", :force => true do |t|
    t.boolean   "deleted",                                                   :default => false
    t.date      "date"
    t.text      "description"
    t.integer   "user_id"
    t.timestamp "created_at",    :limit => 6,                                                   :null => false
    t.timestamp "updated_at",    :limit => 6,                                                   :null => false
    t.decimal   "total",                      :precision => 19, :scale => 2, :default => 0.0
    t.integer   "deleteuser_id"
  end

  create_table "settings", :force => true do |t|
    t.boolean   "editable",                 :default => true
    t.boolean   "enabled",                  :default => true
    t.string    "group"
    t.string    "name"
    t.string    "value"
    t.text      "description"
    t.timestamp "created_at",  :limit => 6,                   :null => false
    t.timestamp "updated_at",  :limit => 6,                   :null => false
  end

  create_table "shipexpenses", :force => true do |t|
    t.boolean   "deleted",                                                           :default => false
    t.boolean   "enabled",                                                           :default => true
    t.date      "date"
    t.integer   "routeship_id"
    t.integer   "invoice_id"
    t.text      "description"
    t.integer   "user_id"
    t.string    "expensetype",                                                       :default => "Kredit"
    t.integer   "officeexpensegroup_id"
    t.integer   "bankexpensegroup_id"
    t.integer   "deleteuser_id"
    t.timestamp "created_at",            :limit => 6,                                                      :null => false
    t.timestamp "updated_at",            :limit => 6,                                                      :null => false
    t.decimal   "total",                              :precision => 19, :scale => 2, :default => 0.0
    t.integer   "gst_percentage",                                                    :default => 0
    t.decimal   "gst_tax",                            :precision => 19, :scale => 2, :default => 0.0
    t.decimal   "price_per",                          :precision => 19, :scale => 2, :default => 0.0
    t.decimal   "misc_total",                         :precision => 19, :scale => 2, :default => 0.0
  end

  create_table "ships", :force => true do |t|
    t.boolean   "deleted",                    :default => false
    t.boolean   "enabled",                    :default => true
    t.string    "name"
    t.string    "imo"
    t.string    "number"
    t.string    "builder"
    t.integer   "year_of_build"
    t.text      "description"
    t.timestamp "created_at",    :limit => 6,                    :null => false
    t.timestamp "updated_at",    :limit => 6,                    :null => false
  end

  create_table "staffs", :force => true do |t|
    t.boolean   "deleted",                               :default => false
    t.boolean   "enabled",                               :default => true
    t.string    "email"
    t.string    "name"
    t.string    "address"
    t.string    "city"
    t.string    "phone"
    t.string    "mobile"
    t.string    "driver_licence"
    t.date      "driver_licence_expiry"
    t.string    "id_card"
    t.date      "id_card_expiry"
    t.date      "start_working"
    t.integer   "salary"
    t.integer   "terms_of_payment_in_days"
    t.integer   "min_wages"
    t.string    "status"
    t.text      "description"
    t.timestamp "created_at",               :limit => 6,                    :null => false
    t.timestamp "updated_at",               :limit => 6,                    :null => false
    t.integer   "office_id"
  end

  create_table "stations", :id => false, :force => true do |t|
    t.integer   "id",                                          :null => false
    t.boolean   "deleted",                  :default => false
    t.boolean   "enabled",                  :default => true
    t.string    "name"
    t.string    "abbr"
    t.string    "description"
    t.timestamp "created_at",  :limit => 6,                    :null => false
    t.timestamp "updated_at",  :limit => 6,                    :null => false
  end

  create_table "supplierpayments", :force => true do |t|
    t.boolean   "deleted",                                                 :default => false
    t.date      "date"
    t.date      "due_date"
    t.integer   "supplier_id"
    t.string    "no_giro"
    t.timestamp "created_at",  :limit => 6,                                                   :null => false
    t.timestamp "updated_at",  :limit => 6,                                                   :null => false
    t.decimal   "total",                    :precision => 19, :scale => 2, :default => 0.0
  end

  create_table "suppliers", :force => true do |t|
    t.boolean   "deleted",                               :default => false
    t.boolean   "enabled",                               :default => true
    t.string    "name"
    t.string    "address"
    t.string    "city"
    t.string    "contact"
    t.string    "phone"
    t.string    "mobile"
    t.string    "fax"
    t.string    "npwp"
    t.integer   "terms_of_payment_in_days"
    t.text      "description"
    t.timestamp "created_at",               :limit => 6,                    :null => false
    t.timestamp "updated_at",               :limit => 6,                    :null => false
  end

  create_table "taxgenericitems", :force => true do |t|
    t.boolean   "deleted",                                                   :default => false
    t.integer   "taxinvoice_id"
    t.integer   "customer_id"
    t.integer   "office_id"
    t.integer   "vehicle_id"
    t.string    "sku_id"
    t.string    "description"
    t.date      "date"
    t.date      "load_date"
    t.date      "unload_date"
    t.integer   "weight_gross",                                              :default => 0
    t.integer   "weight_net",                                                :default => 0
    t.integer   "deleteuser_id"
    t.timestamp "created_at",    :limit => 6,                                                   :null => false
    t.timestamp "updated_at",    :limit => 6,                                                   :null => false
    t.decimal   "price_per",                  :precision => 19, :scale => 2, :default => 0.0
    t.decimal   "total",                      :precision => 19, :scale => 2, :default => 0.0
  end

  create_table "taxinvoiceitems", :force => true do |t|
    t.boolean   "deleted",                                                     :default => false
    t.date      "date"
    t.string    "sku_id"
    t.integer   "weight_gross",                                                :default => 0
    t.integer   "weight_net",                                                  :default => 0
    t.text      "description"
    t.integer   "invoice_id"
    t.integer   "customer_id"
    t.integer   "taxinvoice_id"
    t.integer   "office_id"
    t.timestamp "created_at",      :limit => 6,                                                   :null => false
    t.timestamp "updated_at",      :limit => 6,                                                   :null => false
    t.decimal   "price_per",                    :precision => 19, :scale => 2, :default => 0.0
    t.decimal   "total",                        :precision => 19, :scale => 2, :default => 0.0
    t.date      "load_date"
    t.date      "unload_date"
    t.boolean   "is_wholesale",                                                :default => false
    t.decimal   "wholesale_price",              :precision => 19, :scale => 2, :default => 0.0
    t.boolean   "is_gross",                                                    :default => false
    t.boolean   "is_net",                                                      :default => false
    t.integer   "user_id"
    t.string    "note"
    t.boolean   "rejected",                                                    :default => false
    t.string    "reject_reason"
  end

  create_table "taxinvoices", :force => true do |t|
    t.boolean   "deleted",                                                      :default => false
    t.date      "date"
    t.string    "long_id"
    t.string    "ship_name"
    t.text      "description"
    t.integer   "customer_id"
    t.integer   "office_id"
    t.timestamp "created_at",       :limit => 6,                                                   :null => false
    t.timestamp "updated_at",       :limit => 6,                                                   :null => false
    t.decimal   "total",                         :precision => 19, :scale => 2, :default => 0.0
    t.decimal   "gst_tax",                       :precision => 19, :scale => 2, :default => 0.0
    t.decimal   "price_tax",                     :precision => 19, :scale => 2, :default => 0.0
    t.date      "duedate"
    t.date      "paiddate"
    t.date      "period_start"
    t.date      "period_end"
    t.string    "product_name"
    t.string    "spk_no"
    t.string    "po_no"
    t.string    "tank_name"
    t.decimal   "extra_cost",                    :precision => 19, :scale => 2, :default => 0.0
    t.text      "extra_cost_info"
    t.text      "total_in_words"
    t.string    "price_by"
    t.boolean   "is_weightlost"
    t.string    "spo_no"
    t.date      "sentdate"
    t.boolean   "generic",                                                      :default => false
    t.decimal   "downpayment",                   :precision => 19, :scale => 2, :default => 0.0
    t.date      "downpayment_date"
    t.string    "so_no"
    t.string    "sto_no"
    t.string    "do_no"
    t.string    "waybill"
    t.date      "confirmeddate"
    t.float     "gst_percentage",                                               :default => 0.0
    t.text      "remarks"
    t.decimal   "insurance_cost",                :precision => 19, :scale => 2, :default => 0.0
    t.decimal   "claim_cost",                    :precision => 19, :scale => 2, :default => 0.0
    t.integer   "company_id"
    t.integer   "user_id"
  end

  create_table "tirebudgets", :force => true do |t|
    t.boolean   "deleted",                      :default => false
    t.integer   "vehicle_id"
    t.integer   "productgroup_id"
    t.integer   "budget"
    t.timestamp "created_at",      :limit => 6,                    :null => false
    t.timestamp "updated_at",      :limit => 6,                    :null => false
  end

  create_table "trainexpenses", :force => true do |t|
    t.boolean   "deleted",                                                           :default => false
    t.boolean   "enabled",                                                           :default => true
    t.date      "date"
    t.integer   "routetrain_id"
    t.integer   "invoice_id"
    t.text      "description"
    t.integer   "user_id"
    t.timestamp "created_at",            :limit => 6,                                                      :null => false
    t.timestamp "updated_at",            :limit => 6,                                                      :null => false
    t.decimal   "total",                              :precision => 19, :scale => 2, :default => 0.0
    t.string    "expensetype",                                                       :default => "Kredit"
    t.integer   "officeexpensegroup_id"
    t.integer   "bankexpensegroup_id"
    t.integer   "deleteuser_id"
    t.integer   "gst_percentage",                                                    :default => 0
    t.decimal   "gst_tax",                            :precision => 19, :scale => 2, :default => 0.0
    t.decimal   "price_per",                          :precision => 19, :scale => 2, :default => 0.0
    t.decimal   "misc_total",                         :precision => 19, :scale => 2, :default => 0.0
  end

  create_table "transporttypes", :force => true do |t|
    t.boolean   "deleted",                 :default => false
    t.boolean   "enabled",                 :default => true
    t.string    "name"
    t.timestamp "created_at", :limit => 6,                    :null => false
    t.timestamp "updated_at", :limit => 6,                    :null => false
  end

  create_table "userroles", :force => true do |t|
    t.integer   "user_id"
    t.integer   "role_id"
    t.timestamp "created_at", :limit => 6, :null => false
    t.timestamp "updated_at", :limit => 6, :null => false
  end

  create_table "users", :force => true do |t|
    t.boolean   "deleted",                             :default => false
    t.boolean   "enabled",                             :default => true
    t.string    "username"
    t.string    "password"
    t.string    "role"
    t.integer   "count_login"
    t.timestamp "last_login",             :limit => 6
    t.integer   "office_id"
    t.integer   "staff_id"
    t.boolean   "adminrole",                           :default => false
    t.timestamp "created_at",             :limit => 6,                    :null => false
    t.timestamp "updated_at",             :limit => 6,                    :null => false
    t.string    "email",                               :default => "",    :null => false
    t.string    "encrypted_password",                  :default => "",    :null => false
    t.string    "reset_password_token"
    t.timestamp "reset_password_sent_at", :limit => 6
    t.timestamp "remember_created_at",    :limit => 6
    t.integer   "sign_in_count",                       :default => 0
    t.timestamp "current_sign_in_at",     :limit => 6
    t.timestamp "last_sign_in_at",        :limit => 6
    t.string    "current_sign_in_ip"
    t.string    "last_sign_in_ip"
    t.boolean   "owner",                               :default => false
  end

  create_table "vehiclegroups", :force => true do |t|
    t.boolean   "deleted",                  :default => false
    t.boolean   "enabled",                  :default => true
    t.string    "name"
    t.text      "description"
    t.timestamp "created_at",  :limit => 6,                    :null => false
    t.timestamp "updated_at",  :limit => 6,                    :null => false
  end

  create_table "vehicleincentivegroups", :force => true do |t|
    t.boolean   "deleted",                                                 :default => false
    t.boolean   "enabled",                                                 :default => true
    t.string    "name"
    t.text      "description"
    t.timestamp "created_at",  :limit => 6,                                                   :null => false
    t.timestamp "updated_at",  :limit => 6,                                                   :null => false
    t.decimal   "incentive",                :precision => 19, :scale => 2, :default => 0.0
  end

  create_table "vehiclelogs", :force => true do |t|
    t.boolean   "deleted",                  :default => false
    t.boolean   "enabled",                  :default => true
    t.boolean   "ready",                    :default => false
    t.boolean   "broken",                   :default => false
    t.integer   "vehicle_id"
    t.text      "description"
    t.timestamp "created_at",  :limit => 6,                    :null => false
    t.timestamp "updated_at",  :limit => 6,                    :null => false
  end

  create_table "vehiclepositions", :force => true do |t|
    t.boolean   "deleted",                  :default => false
    t.boolean   "enabled",                  :default => true
    t.date      "date"
    t.integer   "hour"
    t.integer   "event_id"
    t.integer   "invoice_id"
    t.integer   "vehicle_id"
    t.integer   "driver_id"
    t.integer   "route_id"
    t.string    "longitude"
    t.string    "latitude"
    t.string    "description"
    t.integer   "status"
    t.timestamp "created_at",  :limit => 6,                    :null => false
    t.timestamp "updated_at",  :limit => 6,                    :null => false
  end

  create_table "vehicles", :force => true do |t|
    t.boolean   "deleted",                                                              :default => false
    t.boolean   "enabled",                                                              :default => true
    t.string    "current_id"
    t.string    "previous_id"
    t.date      "id_expiry"
    t.string    "registration"
    t.string    "vehicle_type"
    t.string    "year_made"
    t.integer   "tank_capacity"
    t.integer   "gas_capacity"
    t.integer   "gas_leftover",                                                         :default => 0
    t.string    "tire_size"
    t.date      "next_checkup_date"
    t.date      "next_registration_date"
    t.date      "next_tax_date"
    t.string    "machine_serial"
    t.string    "skel_bar_serial"
    t.string    "skel_bar_serial_2"
    t.string    "barcode"
    t.text      "description"
    t.integer   "vehiclegroup_id"
    t.timestamp "created_at",               :limit => 6,                                                   :null => false
    t.timestamp "updated_at",               :limit => 6,                                                   :null => false
    t.date      "date_purchase"
    t.decimal   "amount",                                :precision => 19, :scale => 2, :default => 0.0
    t.string    "tank_type"
    t.date      "siup"
    t.date      "next_checkup_date_second"
    t.date      "next_tera_date"
    t.boolean   "generic",                                                              :default => false
    t.integer   "tire_target",                                                          :default => 0
    t.string    "plat_type"
    t.integer   "vehicleincentivegroup_id"
    t.integer   "office_id"
    t.string    "platform_type"
    t.integer   "gps_number"
  end

  create_table "warehouses", :id => false, :force => true do |t|
    t.integer   "id",                                          :null => false
    t.boolean   "deleted",                  :default => false
    t.boolean   "enabled",                  :default => true
    t.string    "name"
    t.string    "address"
    t.string    "city"
    t.string    "phone"
    t.text      "description"
    t.timestamp "created_at",  :limit => 6,                    :null => false
    t.timestamp "updated_at",  :limit => 6,                    :null => false
  end

end
