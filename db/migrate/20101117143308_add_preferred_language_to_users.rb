class AddPreferredLanguageToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :preferred_language, :string
  end

  def self.down
    remove_column :users, :preferred_language
  end
end
