class AddShopIdToShopAccount < ActiveRecord::Migration
  def self.up
    add_column :accounts, :shop_id, :integer
  end

  def self.down
    remove_column :accounts, :shop_id
  end
end
