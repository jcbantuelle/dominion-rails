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

ActiveRecord::Schema.define(version: 20131231145757) do

  create_table "cards", force: true do |t|
    t.string   "name"
    t.string   "set"
    t.boolean  "kingdom"
    t.boolean  "treasure"
    t.boolean  "victory"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "supply",     default: true
    t.string   "type"
  end

  create_table "game_cards", force: true do |t|
    t.integer  "game_id"
    t.integer  "card_id"
    t.integer  "remaining"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "has_trade_route_token", default: false
  end

  add_index "game_cards", ["card_id"], name: "index_game_cards_on_card_id", using: :btree
  add_index "game_cards", ["game_id"], name: "index_game_cards_on_game_id", using: :btree

  create_table "game_players", force: true do |t|
    t.integer  "game_id"
    t.integer  "player_id"
    t.integer  "turn_order"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "accepted",       default: false
    t.integer  "victory_tokens", default: 0
  end

  add_index "game_players", ["game_id"], name: "index_game_players_on_game_id", using: :btree
  add_index "game_players", ["player_id"], name: "index_game_players_on_player_id", using: :btree

  create_table "game_prizes", force: true do |t|
    t.integer "game_id"
    t.integer "card_id"
  end

  add_index "game_prizes", ["card_id"], name: "index_game_prizes_on_card_id", using: :btree
  add_index "game_prizes", ["game_id"], name: "index_game_prizes_on_game_id", using: :btree

  create_table "game_trashes", force: true do |t|
    t.integer "game_id"
    t.integer "card_id"
  end

  add_index "game_trashes", ["card_id"], name: "index_game_trashes_on_card_id", using: :btree
  add_index "game_trashes", ["game_id"], name: "index_game_trashes_on_game_id", using: :btree

  create_table "games", force: true do |t|
    t.integer  "turn_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "proposer_id"
    t.boolean  "finished"
    t.string   "bane_card"
    t.boolean  "has_trade_route",    default: false
    t.integer  "trade_route_tokens", default: 0
  end

  create_table "mixed_game_cards", force: true do |t|
    t.integer "game_card_id"
    t.integer "card_id"
    t.integer "card_order"
    t.string  "card_type"
  end

  add_index "mixed_game_cards", ["card_id"], name: "index_mixed_game_cards_on_card_id", using: :btree
  add_index "mixed_game_cards", ["game_card_id"], name: "index_mixed_game_cards_on_game_card_id", using: :btree

  create_table "player_cards", force: true do |t|
    t.integer  "game_player_id"
    t.integer  "card_id"
    t.integer  "card_order"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "state"
    t.boolean  "band_of_misfits", default: false
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

  create_table "turn_actions", force: true do |t|
    t.boolean "finished",       default: false
    t.text    "response"
    t.text    "sent_json"
    t.integer "game_id"
    t.integer "game_player_id"
    t.string  "action"
    t.integer "affected_id"
  end

  add_index "turn_actions", ["game_id"], name: "index_turn_actions_on_game_id", using: :btree
  add_index "turn_actions", ["game_player_id"], name: "index_turn_actions_on_game_player_id", using: :btree

  create_table "turns", force: true do |t|
    t.integer "game_id"
    t.integer "game_player_id"
    t.integer "actions",         default: 1
    t.integer "buys",            default: 1
    t.integer "coins",           default: 0
    t.integer "turn"
    t.string  "phase",           default: "action"
    t.integer "potions",         default: 0
    t.integer "coppersmith",     default: 0
    t.integer "global_discount", default: 0
    t.integer "played_actions",  default: 0
    t.integer "tacticians",      default: 0
    t.boolean "lighthouse",      default: false
    t.boolean "outpost",         default: false
    t.integer "action_discount", default: 0
    t.integer "hoards",          default: 0
    t.integer "talismans",       default: 0
    t.integer "crossroads",      default: 0
    t.integer "minions",         default: 0
    t.integer "bought_cards",    default: 0
    t.integer "mercenaries",     default: 0
    t.integer "rogues",          default: 0
    t.integer "fools_gold",      default: 0
    t.integer "schemes",         default: 0
    t.integer "hagglers",        default: 0
  end

  add_index "turns", ["game_id"], name: "index_turns_on_game_id", using: :btree
  add_index "turns", ["game_player_id"], name: "index_turns_on_game_player_id", using: :btree

end
