class ActiveRecord::Base

  def self.translate(fields)
  
    translate_fields = fields[:translate] || []
    search_fields = fields[:index] || []
    all_fields = fields[:all] = translate_fields | search_fields
    
    # Setup search index
    eval("self.index do
      #{search_fields.join('; ')}
    end") unless search_fields.empty?
  
    # Create class getter for fields to be translated or searched
    (class << self; self; end).instance_eval do
      define_method 'translated_fields' do
        fields
      end
      
      define_method 'translation_class' do |lang_id|
        "ActiveRecord::Base::#{self.name}Translation#{lang_id.capitalize.to_s}".constantize
      end
    end
    
    # Create classes for translations
    Language.non_defaults.each do |lang|
      str = "
        class #{self.name}Translation#{lang.id.capitalize.to_s} < ActiveRecord::Base
          set_table_name '#{self.table_name.singularize}_translations_#{lang.id.to_s}'
          belongs_to :#{self.table_name.singularize}
          
          index('#{lang.id}', '#{lang.english_name}') do
            #{search_fields.join("; ")}
          end
          
          def language
            return '#{lang.id.to_s}'
          end
        end"
      eval(str)
    end
   
    # Create translated scope that overrides all of this class fields with their translated values    
    self.scope :translated, lambda { |*args|
      lang = args.flatten.first || I18n.locale
      return self.scoped if not lang in Language.non_defaults.map(&:id)
      table = "#{self.table_name.singularize}_translations_#{lang}"
      self.joins("LEFT JOIN #{table} ON #{table}.#{self.table_name.singularize}_id = #{self.table_name}.id").select(translate_fields.map{|f| "#{table}.#{f} AS #{f}"}.insert(0, "#{self.table_name}.*").join(', '))
    }
    
    # Search using a specific locale 
    self.scope :search_translated, lambda { |*args|
      term = args.flatten.first
      lang = args.flatten.second || I18n.locale
      return self.search(term) if not lang in Language.non_defaults.map(&:id)
      
      table = "#{self.table_name.singularize}_translations_#{lang}"
      index_name = self.translation_class(lang).full_text_indexes.first.to_s
      term = term.scan(/"([^"]+)"|(\S+)/).flatten.compact.map do |lex|
        lex =~ /(.+)\*\s*$/ ? "'#{$1}':*" : "'#{lex}'"
      end.join(' & ') # Code duplicated from texticle gem :(
      self.joins("LEFT JOIN #{table} ON #{table}.#{self.table_name.singularize}_id = #{self.table_name}.id").select(translate_fields.map{|f| "#{table}.#{f} AS #{f}"}.insert(0, "#{self.table_name}.*").join(', ')).where("#{index_name} @@ to_tsquery(?)", term)
    }
    
  end  
end
