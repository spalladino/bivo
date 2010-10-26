class CreateComissions < ActiveRecord::Migration
  def self.up
    create_table :comissions do |t|
      t.float :value
      t.string :kind, :limit => 255
      t.string :details, :limit => 255
      t.boolean :recurrent
      t.references :shop

      t.timestamps
    end
  end

  def self.down
    drop_table :comissions
  end
end
