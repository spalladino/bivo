class Symbol
  def to_pascal_case
    to_s.split('_').each{|word| word.capitalize!}.join(' ')
  end
end
