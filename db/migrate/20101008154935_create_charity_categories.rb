class CreateCharityCategories < ActiveRecord::Migration
  def self.up
    create_table :charity_categories do |t|
      t.string :name

      t.timestamps
    end
  end

  def self.down
    drop_table :charity_categories
  end
end
