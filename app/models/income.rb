class Income < Transaction
  belongs_to :income_category
  belongs_to :shop
end