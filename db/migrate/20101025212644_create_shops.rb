class CreateShops < ActiveRecord::Migration
  def self.up
    create_table :shops do |t|
      t.string :name
      t.string :short_url
      t.string :url
      t.string :redirection
      t.string :description
      t.boolean :worldwide
      t.string :affiliate_code

      t.timestamps
    end
  end

  def self.down
    drop_table :shops
  end
end
