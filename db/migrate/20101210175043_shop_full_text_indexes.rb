class ShopFullTextIndexes < ActiveRecord::Migration
  def self.up
    self.create_full_text_index :shops, [:name, :description]
    
    self.create_full_text_index :shop_translations_es, [:name, :description], 'es', 'spanish'
    self.create_full_text_index :shop_translations_es, [:name, :description]

    self.create_full_text_index :shop_translations_fr, [:name, :description], 'fr', 'french'
    self.create_full_text_index :shop_translations_fr, [:name, :description]
  end

  def self.down
    self.drop_full_text_index :shops
    
    self.drop_full_text_index :shop_translations_es, 'es'
    self.drop_full_text_index :shop_translations_es
    
    self.drop_full_text_index :shop_translations_fr, 'fr'
    self.drop_full_text_index :shop_translations_fr  
  end
end
