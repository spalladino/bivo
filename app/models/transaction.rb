class Transaction < ActiveRecord::Base
  belongs_to :user
  
  validates_numericality_of :amount
end
