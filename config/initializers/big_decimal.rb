
class Numeric
  def to_d
    BigDecimal.new(self.round(3).to_s)
  end
end

class String
  def to_d
    BigDecimal.new(self)
  end
end

# usage
# validates :amount, :decimal => true
class DecimalValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    record.errors[attribute] << "must be a BigDecimal" unless value.is_a? BigDecimal
  end  
end