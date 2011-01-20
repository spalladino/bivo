class Currency
  attr_accessor :id, :name, :html_symbol

  def initialize(id, data)
    self.id = id
    self.name = data[:name]
    self.html_symbol = data[:html_symbol]
  end

  def self.all
    result = []
    Bivo::Application.config.currencies.each_pair do |key, value|
      result << new(key, value)
    end
    result
  end

  def self.by_id(id)
    if id && Bivo::Application.config.currencies.include?(id.to_sym)
      new(id.to_sym, Bivo::Application.config.currencies[id.to_sym])
    else
      nil
    end
  end
  
  def self.from_geo(zone, country)
    case zone
      when 'SA'
        'ARS'
      when 'NA'
        country == 'CA' ? 'CAD' : 'USD'
      when 'EU'
        country == 'GB' ? 'GBP' : 'EUR'
      else
        'GBP'
    end    
  end
end
