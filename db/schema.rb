# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20090318220534) do

  create_table "access_matrix", :force => true do |t|
    t.integer "role_id",    :null => false
    t.string  "controller", :null => false
    t.string  "method",     :null => false
    t.boolean "allowed",    :null => false
  end

  add_index "access_matrix", ["role_id"], :name => "fk_access_matrix_roles"

  create_table "action_types", :force => true do |t|
    t.string "description", :null => false
  end

  create_table "banner_object_types", :force => true do |t|
    t.string "description", :null => false
  end

  create_table "banner_objects", :force => true do |t|
    t.string  "description", :null => false
    t.integer "type_id",     :null => false
  end

  add_index "banner_objects", ["type_id"], :name => "fk_banner_objects_banner_object_types"

  create_table "campuses", :force => true do |t|
    t.string "code",        :limit => 3, :null => false
    t.string "description",              :null => false
  end

  add_index "campuses", ["code"], :name => "index_campuses_on_code", :unique => true

  create_table "ferpas", :force => true do |t|
    t.integer  "user_id",           :null => false
    t.datetime "ferpa_sent_date"
    t.integer  "ferpa_sent_count"
    t.datetime "ferpa_action_date"
    t.boolean  "ferpa_is_approved"
  end

  create_table "form_access_types", :force => true do |t|
    t.string "code",        :limit => 1, :null => false
    t.string "description",              :null => false
  end

  add_index "form_access_types", ["code"], :name => "index_form_access_types_on_code", :unique => true

  create_table "notification_configs", :force => true do |t|
    t.datetime "last_run_date"
    t.integer  "email_batch_size",     :default => 100, :null => false
    t.integer  "first_reminder_days",  :default => 7,   :null => false
    t.integer  "second_reminder_days", :default => 8,   :null => false
  end

  create_table "reasons", :force => true do |t|
    t.string "description", :null => false
  end

  create_table "roles", :force => true do |t|
    t.string  "type",                                :null => false
    t.string  "name"
    t.integer "rank",           :default => 10,      :null => false
    t.boolean "is_system_role", :default => false,   :null => false
    t.string  "home",           :default => "index", :null => false
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id"
    t.text     "data"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "tasks", :force => true do |t|
    t.string "name",                               :null => false
    t.string "description",                        :null => false
    t.string "nature",      :default => "primary", :null => false
  end

  create_table "ticket_campuses", :id => false, :force => true do |t|
    t.integer "campus_id", :null => false
    t.integer "ticket_id", :null => false
  end

  add_index "ticket_campuses", ["campus_id", "ticket_id"], :name => "index_ticket_campuses_on_campus_id_and_ticket_id", :unique => true
  add_index "ticket_campuses", ["ticket_id"], :name => "fk_ticket_campuses_tickets"

  create_table "ticket_classes", :force => true do |t|
    t.string  "name",                         :null => false
    t.integer "ticket_id",                    :null => false
    t.integer "class_type_id", :default => 1, :null => false
  end

  add_index "ticket_classes", ["name", "ticket_id"], :name => "index_ticket_classes_on_name_and_ticket_id", :unique => true

  create_table "ticket_comments", :force => true do |t|
    t.integer  "ticket_id",                    :null => false
    t.integer  "user_id",                      :null => false
    t.integer  "user_role_id",                 :null => false
    t.datetime "date",                         :null => false
    t.string   "comment",      :limit => 2000, :null => false
  end

  add_index "ticket_comments", ["ticket_id"], :name => "fk_ticket_comments_tickets"
  add_index "ticket_comments", ["user_id"], :name => "fk_ticket_comments_users"
  add_index "ticket_comments", ["user_role_id"], :name => "fk_ticket_comments_roles"

  create_table "tickets", :force => true do |t|
    t.string   "username",                               :null => false
    t.string   "requestor_username",                     :null => false
    t.string   "copy_username"
    t.integer  "task_id",            :default => 1,      :null => false
    t.string   "state",              :default => "open", :null => false
    t.string   "description"
    t.string   "permissions"
    t.datetime "date",                                   :null => false
    t.string   "last_action"
    t.boolean  "is_urgent",          :default => true,   :null => false
    t.integer  "reason"
    t.integer  "close_task_id"
    t.boolean  "is_listserv_done"
  end

  add_index "tickets", ["task_id"], :name => "fk_tickets_tasks_a"
  add_index "tickets", ["close_task_id"], :name => "fk_tickets_tasks_b"

  create_table "users", :force => true do |t|
    t.string  "username",                :null => false
    t.integer "role_id",  :default => 3, :null => false
  end

  add_index "users", ["username"], :name => "index_users_on_username", :unique => true
  add_index "users", ["role_id"], :name => "fk_users_roles"

  create_table "users_roles", :id => false, :force => true do |t|
    t.integer "user_id", :null => false
    t.integer "role_id", :null => false
  end

  add_index "users_roles", ["user_id", "role_id"], :name => "index_users_roles_on_user_id_and_role_id", :unique => true
  add_index "users_roles", ["role_id"], :name => "fk_users_roles_roles"

end
