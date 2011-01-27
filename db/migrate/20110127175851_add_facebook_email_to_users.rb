class AddFacebookEmailToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :facebook_email, :string
    User.with_deleted.where(:from_facebook => true).each do |person|
      person.facebook_email = person.email
      person.save!
    end
  end

  def self.down
     remove_column :users, :facebook_email
  end
end

