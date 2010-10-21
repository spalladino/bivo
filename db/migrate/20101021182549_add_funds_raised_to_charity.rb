class AddFundsRaisedToCharity < ActiveRecord::Migration
  def self.up
    add_column :users, :funds_raised, :float, :default => 0.0, :null => false
  end

  def self.down
    remove_column :users, :funds_raised
  end
end
