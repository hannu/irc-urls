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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110109171352) do

  create_table "channels", :force => true do |t|
    t.string   "name"
    t.integer  "network_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status"
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["locked_by"], :name => "delayed_jobs_locked_by"
  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "loggings", :force => true do |t|
    t.string   "sent_from"
    t.string   "publicity"
    t.integer  "user_id"
    t.integer  "occurrence_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "networks", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "nicks", :force => true do |t|
    t.string   "name"
    t.string   "ident"
    t.string   "host"
    t.integer  "network_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "occurrences", :force => true do |t|
    t.integer  "channel_id"
    t.integer  "nick_id"
    t.integer  "url_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "public",     :default => false
  end

  create_table "permissions", :force => true do |t|
    t.integer  "user_id"
    t.integer  "tracking_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "trackings", :force => true do |t|
    t.string   "publicity"
    t.integer  "is_new",     :default => 0
    t.integer  "user_id"
    t.integer  "channel_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "url_images", :force => true do |t|
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.string   "image_hash"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "urls", :force => true do |t|
    t.string   "url"
    t.string   "title"
    t.string   "status"
    t.string   "message"
    t.string   "content"
    t.string   "type"
    t.datetime "last_polled"
    t.string   "content_type"
    t.datetime "last_modified"
    t.integer  "url_image_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "md5"
  end

  add_index "urls", ["md5"], :name => "index_urls_on_md5"
  add_index "urls", ["type"], :name => "index_urls_on_type"

  create_table "users", :force => true do |t|
    t.string   "email",                :limit => 100
    t.string   "encrypted_password",   :limit => 128
    t.string   "password_salt",        :limit => 128
    t.string   "login",                :limit => 40
    t.string   "name",                 :limit => 100, :default => ""
    t.date     "birthdate"
    t.string   "country"
    t.string   "location"
    t.string   "homepage"
    t.string   "secret_key"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "reset_password_token"
    t.string   "remember_token"
    t.datetime "remember_created_at"
  end

  add_index "users", ["email"], :name => "index_users_on_email"
  add_index "users", ["login"], :name => "index_users_on_login", :unique => true

end
