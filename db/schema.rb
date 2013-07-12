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

ActiveRecord::Schema.define(version: 20130712015450) do

  create_table "cards", force: true do |t|
    t.string   "name"
    t.string   "set"
    t.boolean  "kingdom"
    t.boolean  "treasure"
    t.boolean  "victory"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "game_cards", force: true do |t|
    t.integer  "game_id"
    t.integer  "card_id"
    t.integer  "remaining"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "game_cards", ["card_id"], name: "index_game_cards_on_card_id", using: :btree
  add_index "game_cards", ["game_id"], name: "index_game_cards_on_game_id", using: :btree

  create_table "game_players", force: true do |t|
    t.integer  "game_id"
    t.integer  "player_id"
    t.integer  "turn_order"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "accepted",   default: false
  end

  add_index "game_players", ["game_id"], name: "index_game_players_on_game_id", using: :btree
  add_index "game_players", ["player_id"], name: "index_game_players_on_player_id", using: :btree

  create_table "games", force: true do |t|
    t.integer  "turn"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "proposer_id"
  end

  create_table "player_cards", force: true do |t|
    t.integer  "game_player_id"
    t.integer  "card_id"
    t.integer  "card_order"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "state"
  end

  add_index "player_cards", ["card_id"], name: "index_player_cards_on_card_id", using: :btree
  add_index "player_cards", ["game_player_id"], name: "index_player_cards_on_game_player_id", using: :btree

  create_table "players", force: true do |t|
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
    t.string   "username"
    t.boolean  "lobby"
    t.datetime "last_response_at"
    t.boolean  "online",                 default: false
    t.integer  "current_game"
  end

  add_index "players", ["email"], name: "index_players_on_email", unique: true, using: :btree
  add_index "players", ["reset_password_token"], name: "index_players_on_reset_password_token", unique: true, using: :btree

end
