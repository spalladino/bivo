class AddParentIdToShopCategory < ActiveRecord::Migration
  def self.up
    add_column :shop_categories, :parent_id, :integer
  end

  def self.down
    remove_column :shop_categories, :parent_id
  end
end
