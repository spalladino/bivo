class CreateCharityFollows < ActiveRecord::Migration
  def self.up
    create_table :charity_follows do |t|

      t.references :user
      t.references :charity
      t.timestamps
    end
  end

  def self.down
    drop_table :charity_follows
  end
end

