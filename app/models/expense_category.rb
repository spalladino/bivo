class ExpenseCategory < ActiveRecord::Base
  
  validates_presence_of :name
  
end
