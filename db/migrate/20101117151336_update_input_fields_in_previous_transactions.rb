class UpdateInputFieldsInPreviousTransactions < ActiveRecord::Migration
  def self.up
    Transaction.update_all "input_amount = amount, input_currency = '#{Transaction::DefaultCurrency}'"
  end

  def self.down
    Transaction.update_all "input_amount = NULL, input_currency = NULL"
  end
end
