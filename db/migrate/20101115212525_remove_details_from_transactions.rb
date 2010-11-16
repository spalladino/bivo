class RemoveDetailsFromTransactions < ActiveRecord::Migration
  def self.up
    remove_column :transactions, :details
  end

  def self.down
    add_column :transactions, :details, :string
  end
end
