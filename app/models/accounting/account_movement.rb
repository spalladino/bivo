# AccountMovements should be created only form Account#transfer method
class AccountMovement < ActiveRecord::Base
  default_scope :order => 'created_at ASC'

  belongs_to :account
  belongs_to :transaction
  
  validates :amount, :decimal => true
  validates :balance, :decimal => true
end
