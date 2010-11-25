class AddEntitiesToNews < ActiveRecord::Migration
  def self.up
    add_column :news, :newsable_id, :integer
    add_column :news, :newsable_type, :string
  end

  def self.down
    remove_column :news, :newsable_type
    remove_column :news, :newsable_id
  end
end

