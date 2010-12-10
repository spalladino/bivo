class Transaction < ActiveRecord::Base
  DefaultCurrency = :GBP
  belongs_to :user

  validates_numericality_of :input_amount  
  validates_presence_of :user_id, :input_amount, :transaction_date, :type
  validates :input_amount, :decimal => true
  validates :amount, :decimal => true
  
  validates_length_of :description, :maximum => 255
  
  validates_inclusion_of :type, :in => %w(Income Expense), :message => "%{value} should be either Income or Expense"

  validate :check_convertion_to_currency

  def check_convertion_to_currency
    begin
      if (input_currency.to_sym != DefaultCurrency)
        self.amount = CurrencyExchange.instance.get_conversion_rate(
          input_amount, input_currency.to_sym, DefaultCurrency
        )
        self.input_currency = DefaultCurrency
      else
        # TODO add test that ensures this
        self.amount = input_amount
      end
    rescue Exception => e
      errors.add(:currency, e.message)
    end
  end
  
end
