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

ActiveRecord::Schema[8.1].define(version: 2026_02_15_111929) do
  create_table "messages", force: :cascade do |t|
    t.string "content", null: false
    t.datetime "created_at", null: false
    t.integer "direction", default: 1, null: false
    t.integer "rpc_log_id", null: false
    t.string "session_id", null: false
    t.datetime "updated_at", null: false
    t.index ["rpc_log_id"], name: "index_messages_on_rpc_log_id"
    t.index ["session_id"], name: "index_messages_on_session_id"
  end

  create_table "operations", force: :cascade do |t|
    t.string "command"
    t.datetime "created_at", null: false
    t.string "directory"
    t.datetime "updated_at", null: false
  end

  create_table "rpc_logs", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.json "data", null: false
    t.integer "direction", default: 1, null: false
    t.string "rpc_id"
    t.string "session_id", null: false
    t.datetime "updated_at", null: false
    t.index ["session_id"], name: "index_rpc_logs_on_session_id"
  end

  create_table "rpc_messages", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "direction", default: 1, null: false
    t.json "error"
    t.integer "message_type", default: 1, null: false
    t.string "method"
    t.json "params"
    t.json "result"
    t.string "rpc_id"
    t.string "session_id", null: false
    t.datetime "updated_at", null: false
    t.index ["session_id"], name: "index_rpc_messages_on_session_id"
  end

  create_table "sessions", id: :string, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "model", null: false
    t.datetime "updated_at", null: false
  end
end
