class AddCauseIdToCauseAccount < ActiveRecord::Migration
  def self.up
    add_column :accounts, :cause_id, :integer
  end

  def self.down
    remove_column :accounts, :cause_id
  end
end
