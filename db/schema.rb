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

ActiveRecord::Schema.define(version: 20140311201626) do

  create_table "bookmarks", force: true do |t|
    t.integer  "user_id",     null: false
    t.string   "document_id"
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "user_type"
  end

  create_table "languages", force: true do |t|
    t.string "uri"
    t.string "code"
    t.string "label"
  end

  create_table "metadata_sources", force: true do |t|
    t.string "label"
    t.string "uri"
    t.string "media_type"
  end

  create_table "pul_store_lae_genres", force: true do |t|
    t.string "pul_label"
    t.string "tgm_label"
    t.string "lcsh_label"
    t.string "uri"
    t.text   "scope_note"
  end

  create_table "pul_store_lae_subjects", force: true do |t|
    t.string "value"
  end

  add_index "pul_store_lae_subjects", ["value"], name: "index_pul_store_lae_subjects_on_value", unique: true, using: :btree

  create_table "pul_store_lae_subjects_topics", force: true do |t|
    t.integer "topic_id"
    t.integer "subject_id"
  end

  create_table "pul_store_lae_topics", force: true do |t|
    t.string "value"
  end

  add_index "pul_store_lae_topics", ["value"], name: "index_pul_store_lae_topics_on_value", unique: true, using: :btree

  create_table "searches", force: true do |t|
    t.text     "query_params"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "user_type"
  end

  add_index "searches", ["user_id"], name: "index_searches_on_user_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "guest",                  default: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
