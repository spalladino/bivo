class CreateExpenseCategories < ActiveRecord::Migration
  def self.up
    create_table :expense_categories do |t|
      t.string :name, :limit => 255

      t.timestamps
    end
  end

  def self.down
    drop_table :expense_categories
  end
end
