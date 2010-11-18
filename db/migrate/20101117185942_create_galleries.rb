class CreateGalleries < ActiveRecord::Migration
  def self.up
    create_table :galleries do |t|
      t.integer :entity_id
      t.string :entity_type

      t.timestamps
    end
  end

  def self.down
    drop_table :galleries
  end
end

