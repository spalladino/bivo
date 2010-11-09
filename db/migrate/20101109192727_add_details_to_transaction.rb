class AddDetailsToTransaction < ActiveRecord::Migration
  def self.up
    add_column :transactions, :details, :string
  end

  def self.down
    remove_column :transactions, :details
  end
end
