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

ActiveRecord::Schema.define(:version => 20101109213954) do

  create_table "cause_categories", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "causes", :force => true do |t|
    t.string   "name"
    t.string   "url"
    t.integer  "cause_category_id"
    t.float    "funds_needed"
    t.integer  "country_id"
    t.string   "city"
    t.string   "description"
    t.float    "funds_raised"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "votes_count",       :default => 0
    t.integer  "charity_id"
  end

  create_table "charity_categories", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "charity_follows", :force => true do |t|
    t.integer  "user_id"
    t.integer  "charity_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "comments", :force => true do |t|
    t.integer  "commentable_id",                 :default => 0
    t.string   "commentable_type", :limit => 15, :default => ""
    t.string   "title",                          :default => ""
    t.text     "body",                           :default => ""
    t.string   "subject",                        :default => ""
    t.integer  "user_id",                        :default => 0,  :null => false
    t.integer  "parent_id"
    t.integer  "lft"
    t.integer  "rgt"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comments", ["commentable_id"], :name => "index_comments_on_commentable_id"
  add_index "comments", ["user_id"], :name => "index_comments_on_user_id"

  create_table "countries", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "country_shops", :force => true do |t|
    t.integer  "country_id"
    t.integer  "shop_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "expense_categories", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "follows", :force => true do |t|
    t.integer  "user_id"
    t.integer  "cause_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "income_categories", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "shop_categories", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "parent_id"
  end

  create_table "shop_categories_shops", :id => false, :force => true do |t|
    t.integer "shop_category_id"
    t.integer "shop_id"
  end

  create_table "shops", :force => true do |t|
    t.string   "name"
    t.string   "short_url"
    t.string   "url"
    t.string   "redirection"
    t.string   "description"
    t.boolean  "worldwide"
    t.string   "affiliate_code"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.string   "status"
    t.float    "comission_value"
    t.string   "comission_kind"
    t.string   "comission_details"
    t.boolean  "comission_recurrent"
  end

  create_table "transactions", :force => true do |t|
    t.integer  "user_id"
    t.date     "transaction_date"
    t.float    "amount"
    t.string   "description"
    t.integer  "income_category_id"
    t.integer  "expense_category_id"
    t.string   "paid_to"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type"
    t.integer  "shop_id"
    t.string   "details"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                                         :default => "",    :null => false
    t.string   "encrypted_password",             :limit => 128, :default => "",    :null => false
    t.string   "password_salt",                                 :default => "",    :null => false
    t.string   "reset_password_token"
    t.string   "remember_token"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                                 :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "rpx_identifier"
    t.string   "type"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "nickname"
    t.date     "birthday"
    t.string   "gender"
    t.string   "about_me"
    t.string   "charity_name"
    t.string   "charity_website"
    t.string   "short_url"
    t.integer  "charity_category_id"
    t.string   "charity_type"
    t.string   "tax_reg_number"
    t.string   "rating"
    t.string   "rating_url"
    t.integer  "country_id"
    t.string   "city"
    t.string   "description"
    t.boolean  "active"
    t.boolean  "notice_all_funds_raised"
    t.boolean  "notice_status_change"
    t.boolean  "notice_status_update_published"
    t.boolean  "notice_comment_added"
    t.boolean  "send_me_news"
    t.boolean  "auto_approve_comments"
    t.boolean  "from_facebook",                                 :default => false
    t.boolean  "eula_accepted"
    t.string   "status"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  create_table "votes", :force => true do |t|
    t.integer  "user_id"
    t.integer  "cause_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
