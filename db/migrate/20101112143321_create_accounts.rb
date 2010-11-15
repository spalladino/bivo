class CreateAccounts < ActiveRecord::Migration
  def self.up
    create_table :accounts do |t|
      t.string :type
      t.string :name
      t.decimal :balance, :precision => 12, :scale => 3, :default => 0

      t.timestamps
    end
  end

  def self.down
    drop_table :accounts
  end
end
