class Expense < Transaction
  belongs_to :expense_category
  
  validates_presence_of :paid_to
  validates_length_of :paid_to, :maximum => 255
  
  validates_presence_of :expense_category_id
  
  after_save :process_expense
    
  def detail
    self.paid_to
  end
  
  def self.between(from, to)
    where("transaction_date BETWEEN ? AND ?", from, to)
  end
  
  def process_expense
    Account.expenses_account.accept_expense self
  end
end
