class AddFullyFundedAtToCauses < ActiveRecord::Migration
  def self.up
    add_column :causes, :fully_funded_at, :datetime
  end

  def self.down
    remove_column :causes, :fully_funded_at
  end
end
