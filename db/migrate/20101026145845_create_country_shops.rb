class CreateCountryShops < ActiveRecord::Migration
  def self.up
    create_table :country_shops do |t|
      t.references :country
      t.references :shop

      t.timestamps
    end
  end

  def self.down
    drop_table :country_shops
  end
end
