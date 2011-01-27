class CreatePendingMails < ActiveRecord::Migration
  def self.up
    create_table :pending_mails do |t|
      t.string :method
      t.text :data
      t.integer :retries

      t.timestamps
    end
  end

  def self.down
    drop_table :pending_mails
  end
end

