ActiveRecord::Schema.define(version: 0) do
  create_table "chars", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false

    t.index "name", unique: false
  end

  create_table "char_arousals", force: :cascade do |t|
    t.integer  "char_id", null: false
    t.integer  "effect_id", null: false
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false

    t.index "char_id", unique: false
  end

  create_table "char_skills", force: :cascade do |t|
    t.integer  "char_id", null: false
    t.string   "name", null: false
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false

    t.index "char_id", unique: true
  end

  create_table "char_skill_effects", force: :cascade do |t|
    t.integer  "char_skill_id", null: false
    t.integer  "value", null: false
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false

    t.index "char_skill_id", unique: false
  end
end

