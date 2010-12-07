class Translation < ActiveRecord::Base
  index do
    value
  end
  
  scope for_entity, lambda {|obj, field|
    where(:translated_type => obj.class.name, :translated_id => obj.id, :translated_field => field)
  }
  
end
