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

ActiveRecord::Schema.define(version: 20140722070700) do

  create_table "contests", force: true do |t|
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "start"
    t.datetime "end"
    t.integer  "creator_id"
  end

  add_index "contests", ["creator_id"], name: "index_contests_on_creator_id"

  create_table "contests_participants", id: false, force: true do |t|
    t.integer "contest_id"
    t.integer "user_id"
  end

  add_index "contests_participants", ["contest_id"], name: "index_contests_participants_on_contest_id"
  add_index "contests_participants", ["user_id"], name: "index_contests_participants_on_user_id"

  create_table "contests_problems", id: false, force: true do |t|
    t.integer "contest_id"
    t.integer "problem_id"
  end

  add_index "contests_problems", ["contest_id", "problem_id"], name: "index_contests_problems_on_contest_id_and_problem_id"
  add_index "contests_problems", ["contest_id"], name: "index_contests_problems_on_contest_id"
  add_index "contests_problems", ["problem_id"], name: "index_contests_problems_on_problem_id"

  create_table "contests_users", id: false, force: true do |t|
    t.integer "contest_id"
    t.integer "user_id"
  end

  add_index "contests_users", ["contest_id"], name: "index_contests_users_on_contest_id"
  add_index "contests_users", ["user_id"], name: "index_contests_users_on_user_id"

  create_table "problems", force: true do |t|
    t.string   "title"
    t.text     "statement"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "setter_id"
    t.string   "visibility"
  end

  add_index "problems", ["setter_id"], name: "index_problems_on_setter_id"

  create_table "solved_problems", id: false, force: true do |t|
    t.integer "problem_id"
    t.integer "user_id"
  end

  add_index "solved_problems", ["problem_id"], name: "index_solved_problems_on_problem_id"
  add_index "solved_problems", ["user_id"], name: "index_solved_problems_on_user_id"

  create_table "solved_tasks", id: false, force: true do |t|
    t.integer "task_id"
    t.integer "user_id"
  end

  add_index "solved_tasks", ["task_id"], name: "index_solved_tasks_on_task_id"
  add_index "solved_tasks", ["user_id"], name: "index_solved_tasks_on_user_id"

  create_table "submissions", force: true do |t|
    t.integer  "user_id"
    t.integer  "task_id"
    t.text     "input"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "accepted"
    t.string   "code_link"
  end

  create_table "tasks", force: true do |t|
    t.text     "input"
    t.text     "output"
    t.integer  "problem_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tasks", ["problem_id"], name: "index_tasks_on_problem_id"

  create_table "users", force: true do |t|
    t.string   "email"
    t.string   "password_digest"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token"
    t.boolean  "admin",           default: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["remember_token"], name: "index_users_on_remember_token", unique: true

end
