class AddLanguageToPendingMails < ActiveRecord::Migration
  def self.up
    add_column :pending_mails, :language, :string
  end

  def self.down
    remove_column :pending_mails, :language
  end
end
