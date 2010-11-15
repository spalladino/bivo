# AccountMovements should be created only form Account#transfer method
class AccountMovement < ActiveRecord::Base
  default_scope :order => 'created_at ASC'

  belongs_to :account
end
