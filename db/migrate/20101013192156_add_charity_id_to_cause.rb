class AddCharityIdToCause < ActiveRecord::Migration
  def self.up
    add_column :causes, :charity_id, :integer
  end

  def self.down
    remove_column :causes, :charity_id
  end
end
