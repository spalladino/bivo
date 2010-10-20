class CreateIncomeCategories < ActiveRecord::Migration
  def self.up
    create_table :income_categories do |t|
      t.string :name, :limit => 255

      t.timestamps
    end
  end

  def self.down
    drop_table :income_categories
  end
end
