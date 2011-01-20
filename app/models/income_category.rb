class IncomeCategory < ActiveRecord::Base
  default_scope :order => :name
  validates_presence_of :name

  has_many :incomes

  ShopName = 'shop'

  def self.get_shop_category
    self.find_or_create_by_name ShopName
  end

  def self.stats(from, to)
    # required for categories without incomes in that period
    categories = all

    amounts = Income.between(from, to).group(:income_category_id)\
      .select("income_category_id, SUM(amount) AS amount")\
      .inject({}) { |res,row| res.merge!({ row.income_category_id => row.amount.to_d }) }

    # fix data type of the SUM, it is a string
    categories.each do |row|
      row.define_accessor :revenue_amount, Income.to_revenue(amounts[row.id] || 0.to_d)
    end

    categories
  end

end

