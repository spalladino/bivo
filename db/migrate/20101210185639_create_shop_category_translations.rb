class CreateShopCategoryTranslations < ActiveRecord::Migration
  def self.up
  
    Language.non_defaults.map(&:id).reject{|lang| self.table_exists?("shop_category_translations_#{lang}")}.each do |lang|

      create_table "shop_category_translations_#{lang}" do |t|
        t.string :name
        t.integer :referenced_id
        t.boolean :pending, :default => true
      end 
      
      ShopCategory.all.each do |s|
        ShopCategory.translation_class(lang).create_for(s)
      end
      
    end
    
  end

  def self.down
    self.tables.each do |table|
      drop_table table if table =~ /^shop_category_translations/
    end
  end
end
