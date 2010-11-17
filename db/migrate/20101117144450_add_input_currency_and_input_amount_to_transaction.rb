class AddInputCurrencyAndInputAmountToTransaction < ActiveRecord::Migration
  def self.up
    add_column :transactions, :input_currency, :string
    add_column :transactions, :input_amount, :float
  end

  def self.down
    remove_column :transactions, :input_amount
    remove_column :transactions, :input_currency
  end
end
