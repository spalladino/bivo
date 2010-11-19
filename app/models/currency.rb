class Currency
  attr_accessor :id, :name

  def initialize(id, name)
    self.id = id
    self.name = name
  end

  def self.all
    result = []
    Bivo::Application.config.currencies.each_pair { |key, value|
      result << new(key, value)
    }
    result
  end

  def self.by_id(id)
    if (Bivo::Application.config.currencies.include? id)
      new(id, Bivo::Application.config.currencies[id])
    else
      nil
    end
  end
end
