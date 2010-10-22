class RemoveFundsRaisedFromCharity < ActiveRecord::Migration
  def self.up
    remove_column :users, :funds_raised
  end

  def self.down
    add_column :users, :funds_raised, :float, :default => 0.0, :null => false
  end
end
