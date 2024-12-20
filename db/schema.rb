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

ActiveRecord::Schema[7.2].define(version: 2024_12_04_212211) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "controllers", force: :cascade do |t|
    t.string "name", default: "", null: false
    t.string "esp32_mac_address", default: "", null: false
    t.datetime "last_seen_at"
    t.integer "locker_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["user_id"], name: "index_controllers_on_user_id"
  end

  create_table "gestures", force: :cascade do |t|
    t.string "name", default: "", null: false
    t.string "description", default: ""
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "model_id", null: false
    t.index ["model_id"], name: "index_gestures_on_model_id"
  end

  create_table "locker_closures", force: :cascade do |t|
    t.bigint "locker_id", null: false
    t.bigint "locker_opening_id", null: false
    t.datetime "closed_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.boolean "was_succesful", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["locker_id"], name: "index_locker_closures_on_locker_id"
    t.index ["locker_opening_id"], name: "index_locker_closures_on_locker_opening_id"
  end

  create_table "locker_openings", force: :cascade do |t|
    t.bigint "locker_id", null: false
    t.datetime "opened_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "was_succesful", default: false
    t.index ["locker_id"], name: "index_locker_openings_on_locker_id"
  end

  create_table "lockers", force: :cascade do |t|
    t.string "name", default: "", null: false
    t.string "description", default: "", null: false
    t.string "owner_email", default: "", null: false
    t.string "password", default: [], null: false, array: true
    t.boolean "is_locked", default: true, null: false
    t.datetime "last_opened_at"
    t.string "esp32_id"
    t.integer "open_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "controller_id", null: false
    t.datetime "last_closed_at"
    t.index ["controller_id"], name: "index_lockers_on_controller_id"
  end

  create_table "models", force: :cascade do |t|
    t.string "name", default: "", null: false
    t.string "description", default: "", null: false
    t.string "url", default: "", null: false
    t.string "version", default: "", null: false
    t.integer "gesture_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name", default: "", null: false
    t.boolean "is_admin", default: false, null: false
    t.string "provider"
    t.string "uid"
    t.bigint "model_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["model_id"], name: "index_users_on_model_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "controllers", "users"
  add_foreign_key "gestures", "models"
  add_foreign_key "locker_closures", "locker_openings"
  add_foreign_key "locker_closures", "lockers"
  add_foreign_key "locker_openings", "lockers"
  add_foreign_key "lockers", "controllers"
  add_foreign_key "users", "models"
end
