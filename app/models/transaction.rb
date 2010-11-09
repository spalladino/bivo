class Transaction < ActiveRecord::Base
  belongs_to :user
  
  validates_numericality_of :amount
  
  validates_presence_of :user_id, :amount, :transaction_date, :type
  
  validates_length_of :description, :maximum => 255
  
  validates_inclusion_of :type, :in => %w(Income Expense), :message => "%{value} should be either Income or Expense" 
end
