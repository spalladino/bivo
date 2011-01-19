class AddIsoCodeToCountries < ActiveRecord::Migration
  def self.up
    add_column :countries, :iso, :string
  end

  def self.down
    remove_column :countries, :iso
  end
end
