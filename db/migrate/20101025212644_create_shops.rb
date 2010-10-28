class CreateShops < ActiveRecord::Migration
  def self.up
    create_table :shops do |t|
      t.string :name, :limit => 255
      t.string :short_url, :limit => 255
      t.string :url, :limit => 255
      t.string :redirection, :limit => 255
      t.string :description, :limit => 255
      t.boolean :worldwide
      t.string :affiliate_code

      t.timestamps
    end
  end

  def self.down
    drop_table :shops
  end
end
