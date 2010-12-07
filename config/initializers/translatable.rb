class ActiveRecord::Base

  def self.translate(*fields)

    def translation_alias(field)
      "translation_#{self.table_name}_#{field}"
    end
   
    # Create translated scope that overrides all of this class fields with their translated values    
    self.scope :translated, lambda { |*optlang|
      lang = optlang.flatten.first || 'en'
      s = self.scoped
      fs = ["#{self.table_name}.*"]
      fields.each_with_index do |field, index|
        t = translation_alias(field)
        s = s.joins("LEFT JOIN #{Translation.table_name} AS #{t} ON #{t}.translated_type = '#{self.name}' AND #{t}.translated_field = '#{field}' AND #{t}.language = '#{lang}' AND #{t}.translated_id = #{self.table_name}.id")
        fs << "CASE #{t}.pending WHEN TRUE THEN #{self.table_name}.#{field} ELSE #{t}.value END AS #{field}"
      end
      s.select(fs.join(', '))
    }
    
    after_create do |obj|
      Language.all.each do |lang|
        fields.each do |field|
          Translation.create :translated_type => obj.class.name, 
            :translated_field => field, 
            :translated_id => obj.id, 
            :language => lang,
            :pending => true
        end
      end
      true
    end

    after_update do |obj|
      fields.select{|f| eval("#{f}_changed?")}.each do |field|
        Translation.update_all('pending = true', 
            :translated_type => obj.class.name, 
            :translated_field => field, 
            :translated_id => obj.id, )
      end
      true
    end


    define_method 'set_translation' do |locale, field, value| 
      t = Translation.where(:translated_type => self.class.name, 
            :translated_field => field, 
            :translated_id => self.id, 
            :language => locale).first
      if t
        t.pending = false
        t.value = value
        t.save
      else
        Translation.create :translated_type => self.class.name, 
            :translated_field => field, 
            :translated_id => self.id, 
            :language => locale,
            :pending => false,
            :value => value
      end
    end
    
    (class << self; self; end).instance_eval do
      define_method 'translated_fields' do
        fields
      end
      
      define_method 'translation_alias' do |field|
        "translation_#{self.table_name}_#{field}"
      end
    end
    
  end
  
end
