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

ActiveRecord::Schema.define(version: 20180627090634) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "countries", force: :cascade do |t|
    t.string "name", null: false
    t.string "iso3", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "evaluations", force: :cascade do |t|
    t.bigint "site_id"
    t.integer "metadata_id", null: false
    t.string "url", null: false
    t.integer "year", null: false
    t.string "methodology", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "source_id"
    t.index ["site_id"], name: "index_evaluations_on_site_id"
    t.index ["source_id"], name: "index_evaluations_on_source_id"
  end

  create_table "site_countries", force: :cascade do |t|
    t.bigint "site_id"
    t.bigint "country_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["country_id"], name: "index_site_countries_on_country_id"
    t.index ["site_id"], name: "index_site_countries_on_site_id"
  end

  create_table "sites", force: :cascade do |t|
    t.integer "wdpa_id", null: false
    t.string "name", null: false
    t.string "designation", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sources", force: :cascade do |t|
    t.string "data_title"
    t.string "resp_party"
    t.integer "year"
    t.string "language"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "evaluations", "sites"
  add_foreign_key "evaluations", "sources"
  add_foreign_key "site_countries", "countries"
  add_foreign_key "site_countries", "sites"
end
