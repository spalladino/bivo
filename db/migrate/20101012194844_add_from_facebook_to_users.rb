class AddFromFacebookToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :from_facebook, :boolean
  end

  def self.down
    remove_column :users, :from_facebook
  end
end
