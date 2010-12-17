class ExpenseCategory < ActiveRecord::Base
  default_scope :order => :name
  
  validates_presence_of :name
  
  has_many :expenses

  def self.stats(from, to)
    # required for categories without expenses in that period
    categories = all
    
    amounts = Expense.between(from, to).group(:expense_category_id)\
      .select("expense_category_id, SUM(amount) AS amount")\
      .inject({}) { |res,row| res.merge!({ row.expense_category_id => row.amount.to_d }) }
    
    # fix data type of the SUM, it is a string
    categories.each { |row| row.define_accessor :amount, (amounts[row.id] || 0.to_d) }
    
    categories
  end
end
