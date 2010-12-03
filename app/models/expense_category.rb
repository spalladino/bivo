class ExpenseCategory < ActiveRecord::Base
  default_scope :order => :name
  
  validates_presence_of :name
  
  has_many :expenses

  def self.stats(from, to)
    # left join and transaction_date IS NULL is required for categories without expenses in that period
    res = joins("LEFT JOIN #{Expense.table_name} ON #{self.table_name}.id = #{Expense.table_name}.expense_category_id")\
      .where("#{Expense.table_name}.transaction_date IS NULL OR #{Expense.table_name}.transaction_date BETWEEN ? AND ?", from, to)\
      .group(self.column_names.map{|c| "#{self.table_name}.#{c}"})\
      .select("#{self.table_name}.*, SUM(#{Expense.table_name}.amount) AS amount")\
    
    # fix data type of the SUM, it is a string
    res.each { |row| row.amount = (row.amount || 0).to_f }
    
    res
  end
end
