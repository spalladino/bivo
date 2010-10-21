class AddEulaAcceptedToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :eula_accepted, :boolean
  end

  def self.down
    remove_column :users, :eula_accepted
  end
end
