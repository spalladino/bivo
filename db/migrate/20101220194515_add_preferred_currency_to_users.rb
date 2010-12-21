class AddPreferredCurrencyToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :preferred_currency, :string, :default => 'GBP'
    User.update_all("preferred_currency = 'GBP'")
  end

  def self.down
    remove_column :users, :preferred_currency
  end
end
