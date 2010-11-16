class AddTransactionToAccountMovements < ActiveRecord::Migration
  def self.up
    add_column :account_movements, :transaction_id, :integer
  end

  def self.down
    remove_column :account_movements, :transaction_id
  end
end
