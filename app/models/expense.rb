class Expense < Transaction
  belongs_to :expense_category
  
  validates_presence_of :paid_to
  validates_length_of :paid_to, :maximum => 255
  
  validates_presence_of :expense_category_id
  
  
end