
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