class CreateAccountMovements < ActiveRecord::Migration
  def self.up
    create_table :account_movements do |t|
      t.integer :account_id
      t.string :description
      t.decimal :amount
      t.decimal :balance

      t.timestamps
    end
  end

  def self.down
    drop_table :account_movements
  end
end
