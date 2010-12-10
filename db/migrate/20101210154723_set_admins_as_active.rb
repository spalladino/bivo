class SetAdminsAsActive < ActiveRecord::Migration
  def self.up
    User.with_deleted.where(:type => 'Admin').each do |admin|
      admin.status = :active
      admin.save!
    end
  end

  def self.down
  end
end
