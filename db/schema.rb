# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_04_29_212000) do
  create_table "geolocation_records", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "lookup_type", null: false
    t.string "lookup_value", null: false
    t.json "payload", default: {}, null: false
    t.string "provider_name", null: false
    t.string "resolved_ip", null: false
    t.datetime "updated_at", null: false
    t.index ["lookup_value"], name: "index_geolocation_records_on_lookup_value", unique: true
  end
end
