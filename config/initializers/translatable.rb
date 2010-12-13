class ActiveRecord::Base

  def self.translate(fields)
  
    # Initialize fields
    fields = fields.clone
    translate_fields = (fields[:translate] || []).clone
    search_fields = (fields[:index] || []).clone
    all_fields = (fields[:all] = translate_fields | search_fields).clone
    
    # Setup search index
    eval("self.index do
      #{search_fields.join('; ')}
    end") unless search_fields.empty?
    
    cattr_accessor :translated_fields
    self.translated_fields = fields
  
    # Create class getter for fields to be translated or searched and translation classes
    (class << self; self; end).instance_eval do
      define_method 'translation_class' do |*lang_id|
        lang_id = lang_id.flatten.first || I18n.locale
        "::#{self.name}Translation#{lang_id.to_s.capitalize}".constantize
      end
      
      define_method 'translation_table' do |*lang_id|
        lang_id = lang_id.flatten.first || I18n.locale
        return self.table_name if lang_id == :en
        "::#{self.name}Translation#{lang_id.to_s.capitalize}".constantize.table_name
      end
      
      define_method 'translation_classes' do
        Language.non_defaults.map { |lang| self.translation_class(lang.id) }
      end
    end
        
    # Create classes for translations
    Language.non_defaults.each do |lang|
      indxs = "
          index('#{lang.id}', '#{lang.english_name}') do
            #{search_fields.join("; ")}
          end
          
          index(nil, 'english') do
            #{search_fields.join("; ")}
          end
      "
      
      str = "
        class ::#{self.name}Translation#{lang.id.to_s.capitalize} < ActiveRecord::Base
          set_table_name '#{self.table_name.singularize}_translations_#{lang.id.to_s}'
          belongs_to :#{self.table_name.singularize}
          
          #{indxs unless search_fields.empty?}
                    
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
      self.joins("LEFT JOIN #{table} ON #{table}.referenced_id = #{self.table_name}.id").select(translate_fields.map{|f| "#{table}.#{f} AS #{f}"}.insert(0, "#{self.table_name}.*").push("not #{table}.pending AS is_translated").join(', '))
    }
    
    # Scope for obtaining entities pending translation
    self.scope :translation_pending, lambda { |*optlang| 
      lang = optlang.flatten.first || I18n.locale
      table = "#{self.table_name.singularize}_translations_#{lang}"
      self.joins("LEFT JOIN #{table} ON #{table}.referenced_id = #{self.table_name}.id").where("#{table}.pending = true")  
    }
    
    # Search translated fields using english and localized dictionary
    unless search_fields.empty?
      [[:search_translated, 1], [:search_localized, 0]].each do |scope_name, idx|
        self.scope scope_name, lambda { |*args|
          term = args.flatten.first
          lang = args.flatten.second || I18n.locale
          return self.search(term) if not Language.non_defaults.map(&:id).include? lang
          
          table = "#{self.table_name.singularize}_translations_#{lang}"
          index_name = self.translation_class(lang).full_text_indexes[idx].to_s
          
          term = term.scan(/"([^"]+)"|(\S+)/).flatten.compact.map { |lex| \
            lex =~ /(.+)\*\s*$/ ? "'#{$1}':*" : "'#{lex}'"}.join(' & ') # Code duplicated from texticle gem :(
          
          fields = translate_fields.map{|f| "#{table}.#{f} AS #{f}"}.insert(0, "#{self.table_name}.*").push("ts_rank_cd((#{index_name}), to_tsquery(#{connection.quote(term)})) as rank").push("not #{table}.pending AS is_translated")
          
          s = self.joins("LEFT JOIN #{table} ON #{table}.referenced_id = #{self.table_name}.id")
          s = s.select(fields.join(', '))
          s = s.where("#{index_name} @@ to_tsquery(?)", term)
        }
      end
    end
    
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
    
    # Delete all translations on delete
    after_destroy do |obj|
      obj.translations.each do |t|
        t.destroy
      end
    end
    
  end
  
  def self.translated_classes
    # Load all models
    Dir.glob("#{Rails.root}/app/models/**/*.rb").each do |file|
      eval(ActiveSupport::Inflector.camelize(file[file.rindex('/') + 1 .. -4]))
    end
    
    # Return models that have translations
    ActiveRecord::Base.subclasses.select{|x| x.respond_to? :translated_fields}
  end
end
