class CreateCauses < ActiveRecord::Migration
  def self.up
    create_table :causes do |t|
      t.string :name, :limit => 255
      t.string :url, :limit => 255
      t.references :cause_category
      t.float :funds_needed
      t.references :country
      t.string :city, :limit => 255
      t.string :description, :limit => 255
      t.float :funds_raised
      t.string :status

      t.timestamps
    end
  end

  def self.down
    drop_table :causes
  end
end
