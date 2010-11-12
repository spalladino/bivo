
class Numeric
  def to_d
    BigDecimal.new(self.to_s)
  end
end

class String
  def to_d
    BigDecimal.new(self)
  end
end