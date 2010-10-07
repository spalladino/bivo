class CreateCauseCategories < ActiveRecord::Migration
  def self.up
    create_table :cause_categories do |t|
      t.string :name, :limit => 255

      t.timestamps
    end
  end

  def self.down
    drop_table :cause_categories
  end
end
