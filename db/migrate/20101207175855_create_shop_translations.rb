class CreateShopTranslations < ActiveRecord::Migration

  def self.up
  
    Language.non_defaults.map(&:id).reject{|lang| self.table_exists?("shop_translations_#{lang}")}.each do |lang|

      create_table "shop_translations_#{lang}" do |t|
        t.string :name
        t.string :description
        t.integer :referenced_id
        t.boolean :pending, :default => true
      end 
      
      Shop.all.each do |s|
        Shop.translation_class(lang).create_for(s)
      end
      
    end
  
  end

  def self.down
    self.tables.each do |table|
      drop_table table if table =~ /^shop_translations/
    end
  end

end
