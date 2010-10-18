class Transaction < ActiveRecord::Base
  belongs_to :user
  belongs_to :income_category
  belongs_to :expense_category
  
  validates_numericality_of :amount
end
