class CreateShopCategoryFullTextIndexes < ActiveRecord::Migration
  def self.up
    self.create_translated_full_text_indexes :shop_categories, [:name]
  end

  def self.down
    self.drop_translated_full_text_indexes :shop_categories
  end
end
