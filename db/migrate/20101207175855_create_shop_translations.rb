class CreateShopTranslations < ActiveRecord::Migration
  def self.up
    Language.non_defaults.each do |lang|
      create_table "shop_translations_#{lang.id}" do |t|
        t.string :name
        t.string :description
        t.references :shop
        t.boolean :pending, :default => true
      end unless self.table_exists?("shop_translations_#{lang.id}")
    end
  end

  def self.down
    self.tables.each do |table|
      drop_table table if table =~ /^shop_translations/
    end
  end
end
