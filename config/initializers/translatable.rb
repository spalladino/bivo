class ActiveRecord::Base

  def self.translate(fields)
  
    translate_fields = fields[:translate] || []
    search_fields = fields[:index] || []
    all_fields = fields[:all] = translate_fields | search_fields
    
    # Setup search index
    eval("self.index do
      #{search_fields.join('; ')}
    end") unless search_fields.empty?
  
    # Create class getter for fields to be translated or searched and translation classes
    (class << self; self; end).instance_eval do
      cattr_accessor :translated_fields
      
      define_method 'translation_class' do |lang_id|
        "::#{self.name}Translation#{lang_id.capitalize.to_s}".constantize
      end
      
      define_method 'translation_classes' do
        Language.non_defaults.map { |lang| self.translation_class(lang.id) }
      end
    end
    
    # Set translated fields
    self.translated_fields = fields
    
    # Create classes for translations
    Language.non_defaults.each do |lang|
      str = "
        class ::#{self.name}Translation#{lang.id.capitalize.to_s} < ActiveRecord::Base
          set_table_name '#{self.table_name.singularize}_translations_#{lang.id.to_s}'
          belongs_to :#{self.table_name.singularize}
          
          index('#{lang.id}', '#{lang.english_name}') do
            #{search_fields.join("; ")}
          end
          
          index(nil, 'english') do
            #{search_fields.join("; ")}
          end
          
          def self.create_for(referenced)
            self.create :referenced_id => referenced.id, #{all_fields.map{|f| ':' + f.to_s + ' => referenced[:' + f.to_s + ']'}.join(', ')}
          end
          
          def self.language
            return '#{lang.id.to_s}'
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
      return self.scoped if not Language.non_defaults.map(&:id).include? lang
      
      table = "#{self.table_name.singularize}_translations_#{lang}"
      self.joins("LEFT JOIN #{table} ON #{table}.referenced_id = #{self.table_name}.id").select(translate_fields.map{|f| "#{table}.#{f} AS #{f}"}.insert(0, "#{self.table_name}.*").join(', '))
    }
    
    # Scope for obtaining entities pending translation
    self.scope :translation_pending, lambda { |*optlang| 
      lang = optlang.flatten.first || I18n.locale
      table = "#{self.table_name.singularize}_translations_#{lang}"
      self.joins("LEFT JOIN #{table} ON #{table}.referenced_id = #{self.table_name}.id").where("#{table}.pending = true")  
    }
    
    # Search translated fields using english dictionary
    self.scope :search_translated, lambda { |*args|
      term = args.flatten.first
      lang = args.flatten.second || I18n.locale
      return self.search(term) if not Language.non_defaults.map(&:id).include? lang
      
      table = "#{self.table_name.singularize}_translations_#{lang}"
      index_name = self.translation_class(lang).full_text_indexes.second.to_s
      
      term = term.scan(/"([^"]+)"|(\S+)/).flatten.compact.map do |lex|
        lex =~ /(.+)\*\s*$/ ? "'#{$1}':*" : "'#{lex}'"
      end.join(' & ') # Code duplicated from texticle gem :(
      
      fields = translate_fields.map{|f| "#{table}.#{f} AS #{f}"}.insert(0, "#{self.table_name}.*").push("ts_rank_cd((#{index_name}), to_tsquery(#{connection.quote(term)})) as rank")
      
      s = self.joins("LEFT JOIN #{table} ON #{table}.referenced_id = #{self.table_name}.id")
      s = s.select(fields.join(', '))
      s = s.where("#{index_name} @@ to_tsquery(?)", term)
    }
    
    # Search translated fields using a specific locale 
    self.scope :search_localized, lambda { |*args|
      term = args.flatten.first
      lang = args.flatten.second || I18n.locale
      return self.search(term) if not Language.non_defaults.map(&:id).include? lang
      
      table = "#{self.table_name.singularize}_translations_#{lang}"
      index_name = self.translation_class(lang).full_text_indexes.first.to_s
      
      term = term.scan(/"([^"]+)"|(\S+)/).flatten.compact.map do |lex|
        lex =~ /(.+)\*\s*$/ ? "'#{$1}':*" : "'#{lex}'"
      end.join(' & ') # Code duplicated from texticle gem :(
      
      fields = translate_fields.map{|f| "#{table}.#{f} AS #{f}"}.insert(0, "#{self.table_name}.*").push("ts_rank_cd((#{index_name}), to_tsquery(#{connection.quote(term)})) as rank")
      
      s = self.joins("LEFT JOIN #{table} ON #{table}.referenced_id = #{self.table_name}.id")
      s = s.select(fields.join(', '))
      s = s.where("#{index_name} @@ to_tsquery(?)", term)
    }
    
    # Save translation instance method
    define_method 'save_translation' do |lang, args|
      translation = self.class.translation_class(lang).find_by_referenced_id(self.id)
      translation.update_attributes(args.merge(:pending => false))
    end
    
    # Return translation instance
    define_method 'translation' do |lang_id|
      self.class.translation_class(lang_id).find_by_referenced_id(self.id)
    end
    
    # Return all translation instances
    define_method 'translations' do
      Language.non_defaults.map { |lang| self.translation(lang.id) }
    end
   
    # Create translation in all languages for new item
    after_create do |obj|
      obj.class.translation_classes.each{|c| c.create_for(obj)}
    end
    
    # Mark translation as pending in all languages for updated item
    after_update do |obj|
      ts = obj.translations
      obj.class.translated_fields[:all].each do |field|
        ts.each do |t|
          t[field] = self[field]
        end if eval("#{field}_changed?")
      end
      
      ts.select(&:changed?).each do |t| 
        t.pending = true
        t.save
      end
    end
    
  end  
end
