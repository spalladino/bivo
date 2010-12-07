class ActiveRecord::Base

  #TODO: Use Globalize2 gem
  def self.translate(*fields)

    # Create translated scope that overrides all of this class fields with their translated values    
    self.scope :translated, lambda { |lang|
      s = self.scoped
      fs = ["#{self.table_name}.*"]
      fields.each_with_index do |field, index|
        s = s.joins("LEFT JOIN #{Translation.table_name} AS T#{index} ON T#{index}.translated_type = '#{self.name}' AND T#{index}.translated_field = '#{field}' AND T#{index}.language = '#{lang}' AND T#{index}.translated_id = #{self.table_name}.id")
        fs << "CASE T#{index}.pending WHEN TRUE THEN #{self.table_name}.#{field} ELSE T#{index}.value END AS #{field}"
      end
      
      s.select(fs.join(', '))
    }
    
  end
  
end
