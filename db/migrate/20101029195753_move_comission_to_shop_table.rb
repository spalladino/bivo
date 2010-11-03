class MoveComissionToShopTable < ActiveRecord::Migration

  def self.up
    drop_table :comissions
    
    add_column :shops, :comission_value, :float
    add_column :shops, :comission_kind, :string, :limit => 255
    add_column :shops, :comission_details, :string, :limit => 255
    add_column :shops, :comission_recurrent, :boolean
  end

  def self.down
    create_table :comissions do |t|
      t.float :value
      t.string :kind, :limit => 255
      t.string :details, :limit => 255
      t.boolean :recurrent
      t.references :shop

      t.timestamps
    end
    
    remove_column :shops, :comission_value
    remove_column :shops, :comission_kind
    remove_column :shops, :comission_details
    remove_column :shops, :comission_recurrent
  end
  
end
