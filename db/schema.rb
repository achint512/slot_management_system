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

ActiveRecord::Schema.define(version: 2021_01_16_194508) do

  create_table "interview_slots", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "interviewer_id", null: false
    t.integer "status", default: 0, null: false
    t.datetime "start_datetime", null: false
    t.datetime "end_datetime", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["end_datetime"], name: "index_interview_slots_on_end_datetime"
    t.index ["interviewer_id"], name: "index_interview_slots_on_interviewer_id"
    t.index ["start_datetime"], name: "index_interview_slots_on_start_datetime"
    t.index ["status"], name: "index_interview_slots_on_status"
  end

  create_table "interviews", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "interviewee_id", null: false
    t.integer "interview_slot_id", null: false
    t.integer "grade"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "status", default: 0, null: false
    t.index ["interviewee_id", "grade"], name: "index_interviews_on_interviewee_id_and_grade"
    t.index ["interviewee_id"], name: "index_interviews_on_interviewee_id"
    t.index ["status"], name: "index_interviews_on_status"
  end

  create_table "users", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "email", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email"
  end

end
