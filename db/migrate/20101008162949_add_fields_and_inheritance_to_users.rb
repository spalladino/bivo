class AddFieldsAndInheritanceToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :type, :string, :limit => 255 #for inheritance
    
    #personal user fields
    add_column :users, :first_name, :string, :limit => 255
    add_column :users, :last_name, :string, :limit => 255
    add_column :users, :nickname, :string, :limit => 255
    add_column :users, :birthday, :date
    add_column :users, :gender, :string, :limit => 255
    add_column :users, :about_me, :string, :limit => 255
    
    #charity fields
    add_column :users, :charity_name, :string, :limit => 255
    add_column :users, :charity_website, :string, :limit => 255
    add_column :users, :short_url, :string, :limit => 255
    add_column :users, :charity_category_id, :integer
    add_column :users, :charity_type, :string, :limit => 255
    add_column :users, :tax_reg_number, :string, :limit => 255
    add_column :users, :rating, :string, :limit => 255
    add_column :users, :rating_url, :string, :limit => 255
    add_column :users, :country_id, :integer
    add_column :users, :city, :string, :limit => 255
    add_column :users, :description, :string, :limit => 255
    add_column :users, :active, :boolean
    
    #notifications for both
    add_column :users, :notice_all_funds_raised, :boolean
    add_column :users, :notice_status_change, :boolean
    add_column :users, :notice_status_update_published, :boolean
    add_column :users, :notice_comment_added, :boolean
    add_column :users, :send_me_news, :boolean
    
    #notifications for charity
    add_column :users, :auto_approve_comments, :boolean
  end

  def self.down
    remove_column :users, :auto_approve_comments
    remove_column :users, :send_me_news
    remove_column :users, :notice_comment_added
    remove_column :users, :notice_status_update_published
    remove_column :users, :notice_status_change
    remove_column :users, :notice_all_funds_raised
    remove_column :users, :active
    remove_column :users, :description
    remove_column :users, :city
    remove_column :users, :country
    remove_column :users, :rating_url
    remove_column :users, :rating
    remove_column :users, :tax_reg_number
    remove_column :users, :charity_type
    remove_column :users, :charity_category
    remove_column :users, :short_url
    remove_column :users, :charity_website
    remove_column :users, :charity_name
    remove_column :users, :about_me
    remove_column :users, :gender
    remove_column :users, :birthday
    remove_column :users, :nickname
    remove_column :users, :last_name
    remove_column :users, :first_name
    remove_column :users, :type
  end
end
