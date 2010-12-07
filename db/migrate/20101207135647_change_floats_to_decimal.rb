class ChangeFloatsToDecimal < ActiveRecord::Migration
  def self.up
    change_column :account_movements, :amount, :decimal, :precision => 12, :scale => 3, :default => 0
    change_column :account_movements, :balance, :decimal, :precision => 12, :scale => 3, :default => 0
    
    change_column :causes, :funds_needed, :decimal, :precision => 12, :scale => 3, :default => 0
    change_column :causes, :funds_raised, :decimal, :precision => 12, :scale => 3, :default => 0
    
    change_column :transactions, :amount, :decimal, :precision => 12, :scale => 3, :default => 0
    change_column :transactions, :input_amount, :decimal, :precision => 12, :scale => 3, :default => 0
  end

  def self.down
    change_column :account_movements, :amount, :decimal
    change_column :account_movements, :balance, :decimal

    change_column :causes, :funds_needed, :float
    change_column :causes, :funds_raised, :float
    
    change_column :transactions, :amount, :float
    change_column :transactions, :input_amount, :float
  end
end
