class CreateTranslations < ActiveRecord::Migration
  def self.up
    create_table :translations do |t|
      t.string  :translated_type,  :null => false
      t.string  :translated_field, :null => false
      t.integer :translated_id,    :null => false
      t.string  :language,         :null => false
      t.string  :value
      t.boolean :pending,          :default => true

      t.timestamps
    end
  end

  def self.down
    drop_table :translations
  end
end
