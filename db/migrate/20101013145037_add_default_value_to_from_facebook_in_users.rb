class AddDefaultValueToFromFacebookInUsers < ActiveRecord::Migration
  def self.up
    change_column_default :users, :from_facebook, false
  end

  def self.down
    change_column_default :users, :from_facebook, nil
  end
end
