class Account < ActiveRecord::Base

  has_many :movements, :class_name => "AccountMovement"

  def self.transfer(from, to, amount, description = nil)
    Account.transaction do
      from.lock!
      to.lock!
            
      from.balance -= amount
      from.save!
      from_line = AccountMovement.new :description => description, :amount => -amount, :balance => from.balance
      from.movements << from_line
      
      to.balance += amount
      to.save!
      to_line = AccountMovement.new :description => description, :amount => amount, :balance => to.balance
      to.movements << to_line
    end
  end
end
