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

ActiveRecord::Schema.define(version: 20151123144424) do

  create_table "users", force: :cascade do |t|
    t.string   "name",               limit: 255
    t.string   "gender",             limit: 255
    t.integer  "age",                limit: 4
    t.integer  "status",             limit: 4
    t.boolean  "present"
    t.float    "pref_temperature",   limit: 24
    t.integer  "credit_temperature", limit: 4
    t.float    "pref_humidity",      limit: 24
    t.integer  "credit_humidity",    limit: 4
    t.boolean  "pref_light0"
    t.integer  "credit_light0",      limit: 4
    t.boolean  "pref_light1"
    t.integer  "credit_light1",      limit: 4
    t.boolean  "pref_light2"
    t.integer  "credit_light2",      limit: 4
    t.boolean  "pref_light3"
    t.integer  "credit_light3",      limit: 4
    t.datetime "moment"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

end
