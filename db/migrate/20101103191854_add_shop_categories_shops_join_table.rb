class AddShopCategoriesShopsJoinTable < ActiveRecord::Migration
  def self.up
    create_table :shop_categories_shops , :id => false do |t|
      t.integer :shop_category_id
      t.integer :shop_id
    end
  end

  def self.down
    drop_table :shop_categories_shops
  end
end
