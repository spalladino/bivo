class Transaction < ActiveRecord::Base
  belongs_to :user
  
  validates_numericality_of :amount
  
  validates_presence_of :user_id, :amount, :transaction_date, :types
  
  validates_length_of :description, :maximum => 255
  
end
