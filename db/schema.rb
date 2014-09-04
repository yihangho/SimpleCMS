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

ActiveRecord::Schema.define(version: 20140904141006) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "announcements", force: true do |t|
    t.string   "title"
    t.text     "message"
    t.integer  "sender_id"
    t.integer  "contest_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "announcements", ["contest_id"], name: "index_announcements_on_contest_id", using: :btree

  create_table "contests", force: true do |t|
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "start"
    t.datetime "end"
    t.integer  "creator_id"
    t.string   "visibility"
    t.string   "participation"
    t.text     "instructions"
  end

  add_index "contests", ["creator_id"], name: "index_contests_on_creator_id", using: :btree

  create_table "contests_participants", id: false, force: true do |t|
    t.integer "contest_id"
    t.integer "user_id"
  end

  add_index "contests_participants", ["contest_id"], name: "index_contests_participants_on_contest_id", using: :btree
  add_index "contests_participants", ["user_id"], name: "index_contests_participants_on_user_id", using: :btree

  create_table "contests_problems", id: false, force: true do |t|
    t.integer "contest_id"
    t.integer "problem_id"
  end

  add_index "contests_problems", ["contest_id", "problem_id"], name: "index_contests_problems_on_contest_id_and_problem_id", using: :btree
  add_index "contests_problems", ["contest_id"], name: "index_contests_problems_on_contest_id", using: :btree
  add_index "contests_problems", ["problem_id"], name: "index_contests_problems_on_problem_id", using: :btree

  create_table "contests_users", id: false, force: true do |t|
    t.integer "contest_id"
    t.integer "user_id"
  end

  add_index "contests_users", ["contest_id"], name: "index_contests_users_on_contest_id", using: :btree
  add_index "contests_users", ["user_id"], name: "index_contests_users_on_user_id", using: :btree

  create_table "feedbacks", force: true do |t|
    t.string   "email"
    t.text     "message"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "permalinks", force: true do |t|
    t.string   "url"
    t.integer  "linkable_id"
    t.string   "linkable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "permalinks", ["linkable_type", "linkable_id"], name: "index_permalinks_on_linkable_type_and_linkable_id", using: :btree
  add_index "permalinks", ["url"], name: "index_permalinks_on_url", unique: true, using: :btree

  create_table "problems", force: true do |t|
    t.string   "title"
    t.text     "statement"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "setter_id"
    t.boolean  "contest_only", default: true
    t.text     "stub"
  end

  add_index "problems", ["setter_id"], name: "index_problems_on_setter_id", using: :btree

  create_table "seeds", force: true do |t|
    t.string   "seed"
    t.integer  "user_id"
    t.integer  "task_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "seeds", ["task_id", "user_id"], name: "index_seeds_on_task_id_and_user_id", unique: true, using: :btree
  add_index "seeds", ["user_id", "task_id"], name: "index_seeds_on_user_id_and_task_id", unique: true, using: :btree

  create_table "sessions", force: true do |t|
    t.string   "remember_token"
    t.integer  "user_id"
    t.string   "user_agent"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["remember_token", "user_id"], name: "index_sessions_on_remember_token_and_user_id", using: :btree
  add_index "sessions", ["remember_token"], name: "index_sessions_on_remember_token", unique: true, using: :btree
  add_index "sessions", ["user_id", "remember_token"], name: "index_sessions_on_user_id_and_remember_token", using: :btree

  create_table "solved_problems", id: false, force: true do |t|
    t.integer "problem_id"
    t.integer "user_id"
  end

  add_index "solved_problems", ["problem_id"], name: "index_solved_problems_on_problem_id", using: :btree
  add_index "solved_problems", ["user_id"], name: "index_solved_problems_on_user_id", using: :btree

  create_table "solved_tasks", id: false, force: true do |t|
    t.integer "task_id"
    t.integer "user_id"
  end

  add_index "solved_tasks", ["task_id"], name: "index_solved_tasks_on_task_id", using: :btree
  add_index "solved_tasks", ["user_id"], name: "index_solved_tasks_on_user_id", using: :btree

  create_table "submissions", force: true do |t|
    t.integer  "user_id"
    t.integer  "task_id"
    t.text     "input"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "accepted"
    t.text     "code",       default: ""
  end

  add_index "submissions", ["accepted"], name: "index_submissions_on_accepted", using: :btree
  add_index "submissions", ["created_at"], name: "index_submissions_on_created_at", using: :btree
  add_index "submissions", ["task_id"], name: "index_submissions_on_task_id", using: :btree
  add_index "submissions", ["user_id"], name: "index_submissions_on_user_id", using: :btree

  create_table "tasks", force: true do |t|
    t.text     "input_generator"
    t.text     "grader"
    t.integer  "problem_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "point",           default: 0
    t.integer  "tokens",          default: 0
    t.integer  "order",           default: 0
    t.string   "label",           default: ""
  end

  add_index "tasks", ["problem_id"], name: "index_tasks_on_problem_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "email"
    t.string   "password_digest"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "admin",           default: false
    t.string   "username"
    t.string   "school"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["school"], name: "index_users_on_school", using: :btree
  add_index "users", ["username"], name: "index_users_on_username", unique: true, using: :btree

end
