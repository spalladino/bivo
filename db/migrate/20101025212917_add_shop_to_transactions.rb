class AddShopToTransactions < ActiveRecord::Migration
  def self.up
    add_column :transactions, :shop_id, :integer
  end

  def self.down
    remove_column :transactions, :shop_id
  end
end
