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

ActiveRecord::Schema.define(version: 2019_02_16_124804) do
  create_table "accounts", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "addresses", force: :cascade do |t|
    t.integer "account_id"
    t.string "city"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "answers", force: :cascade do |t|
    t.integer "question_id"
    t.text "body"
    t.integer "sequential_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["question_id"], name: "index_answers_on_question_id"
    t.index ["sequential_id"], name: "index_answers_on_sequential_id"
  end

  create_table "comments", force: :cascade do |t|
    t.integer "question_id"
    t.text "body"
    t.integer "sequential_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["question_id"], name: "index_comments_on_question_id"
  end

  create_table "concurrent_badgers", force: :cascade do |t|
    t.integer "sequential_id", null: false
    t.integer "burrow_id"
    t.index ["sequential_id", "burrow_id"], name: "unique_concurrent", unique: true
  end

  create_table "doppelgangers", force: :cascade do |t|
    t.integer "sequential_id_one"
    t.integer "sequential_id_two"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "emails", force: :cascade do |t|
    t.string "emailable_type"
    t.integer "emailable_id"
    t.integer "sequential_id"
    t.string "address"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "invoices", force: :cascade do |t|
    t.integer "amount"
    t.integer "sequential_id"
    t.integer "account_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["account_id"], name: "index_invoices_on_account_id"
  end

  create_table "monsters", force: :cascade do |t|
    t.integer "sequential_id"
    t.string "type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "orders", force: :cascade do |t|
    t.string "product"
    t.integer "account_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "policemen", force: :cascade do |t|
    t.integer "sequential_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "products", force: :cascade do |t|
    t.integer "account_id"
    t.integer "sequential_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "questions", force: :cascade do |t|
    t.string "summary"
    t.text "body"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ratings", force: :cascade do |t|
    t.integer "comment_id"
    t.integer "score"
    t.integer "sequential_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "subscriptions", force: :cascade do |t|
    t.string "plan"
    t.integer "sequential_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: :cascade do |t|
    t.integer "account_id"
    t.string "name"
    t.integer "custom_sequential_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["account_id"], name: "index_users_on_account_id"
  end

  create_table "with_custom_primary_keys", primary_key: "legacy_id", force: :cascade do |t|
    t.integer "sequential_id"
    t.integer "account_id"
    t.index ["account_id"], name: "index_with_custom_primary_keys_on_account_id"
  end
end
