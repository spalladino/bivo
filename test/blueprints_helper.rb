module BlueprintsClassMethods
  def make_or_get(max = 5, attributes = {})
    if self.count < max then self.make(attributes) else self.all[rand(max)] end
  end
  
  def make_many(count,attributes={})
    list = []
    count.times do
      item = self.make(attributes)
      yield item if block_given? 
      list << item        
    end
    return list
  end
  
end

class << Cause
  def make_with_votes(attributes = {})
    votes_count = attributes[:votes_count] || rand(10)
    attributes.delete(:votes_count)
    
    Cause.make({:status => :active}.merge(attributes)) do |cause|
      votes_count.to_i.times { cause.votes.make }
    end
  end
end

# Add helper blueprints methods to all model objects
ActiveRecord::Base.extend BlueprintsClassMethods