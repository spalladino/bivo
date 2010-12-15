class ShopFullTextIndexesWithUrls < ActiveRecord::Migration
   def self.up
    Language.non_defaults.map(&:id).each do |lang|
      add_column "shop_translations_#{lang}".to_sym, :url, :string
      add_column "shop_translations_#{lang}".to_sym, :short_url, :string
    end
    
    self.create_translated_full_text_indexes :shops, [:name, :description, :url, :short_url]
  end

  def self.down
    Language.non_defaults.map(&:id).each do |lang|
      remove_column "shop_translations_#{lang}".to_sym, :url
      remove_column "shop_translations_#{lang}".to_sym, :short_url
    end
  
    self.drop_translated_full_text_indexes :shops
  end
end
