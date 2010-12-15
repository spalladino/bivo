module Translatable
  extend ActiveSupport::Concern
  
  included do
    class_attribute :translated_fields
    class_attribute :lazy_translation
    class_attribute :lazy_translation_language
  end
  
  module ClassMethods
  
    def translation_class(lang_id=nil)
      lang_id ||= I18n.locale
      return self if lang_id == :en
      "::#{self.name}Translation#{lang_id.to_s.capitalize}".constantize
    end

    def translation_classes
      Language.non_defaults.map do |lang| 
        self.translation_class(lang.id)
      end
    end
    
    def translation_table(lang_id=nil)
      self.translation_class(lang_id).table_name
    end
    
    def with_lazy_translation(lang_id=nil, &block)
      old_value = self.lazy_translation
      self.lazy_translation = true
      self.lazy_translation_language = lang_id
      yield ensure self.lazy_translation = old_value
    end
  
  end
  
  module InstanceMethods
    
    def save_translation(lang, args)
      translation = self.class.translation_class(lang).find_by_referenced_id(self.id)
      translation.update_attributes(args.merge(:pending => false))
    end
    
    def translation (lang_id=nil)
      lang_id ||= I18n.locale
      return self if lang_id == :en
      self.class.translation_class(lang_id).find_by_referenced_id(self.id)
    end
    
    def translations
      Language.non_defaults.map { |lang| self.translation(lang.id) }
    end
    
  end

end

class ActiveRecord::Base

  def self.translate(fields)
  
    self.send :include, Translatable
  
    # Initialize fields
    fields = fields.clone
    translate_fields = (fields[:translate] || []).clone
    search_fields = (fields[:index] || []).clone
    all_fields = (fields[:all] = translate_fields | search_fields).clone
    
    self.translated_fields = fields
    
    # Setup search index
    eval("self.index do
      #{search_fields.join('; ')}
    end") unless search_fields.empty?
    
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
    # Most of the code duplicated from texticle gem :(
    # Arguments: 
    # - term
    # - language (optional, default I18n.locale)
    # - additional_filter (optional, extra filter added to where clause, use for OR conditions)
    unless search_fields.empty?
      self.scope :search_translated, lambda { |*args|
        term = args.flatten.first
        lang = args.flatten.second || I18n.locale
        additional_filter = args.flatten.third || ''
        
        term = term.scan(/"([^"]+)"|(\S+)/).flatten.compact.map { |lex| \
          lex =~ /(.+)\*\s*$/ ? "'#{$1}':*" : "'#{lex}'" \
        }.join(' & ') 

        if Language.non_defaults.map(&:id).include?(lang)
        
          table = "#{self.table_name.singularize}_translations_#{lang}"
          index_localized, index_english = self.translation_class(lang).full_text_indexes.map{|idx| idx.to_s}
          
          fields = translate_fields.map{|f| "#{table}.#{f} AS #{f}"}\
              .insert(0, "#{self.table_name}.*")\
              .push("(ts_rank_cd((#{index_localized}), to_tsquery(#{connection.quote(term)})) + ts_rank_cd((#{index_english}), to_tsquery(#{connection.quote(term)})))as rank")\
              .push("not #{table}.pending AS is_translated")
          
          s = self.joins("LEFT JOIN #{table} ON #{table}.referenced_id = #{self.table_name}.id")
          s = s.select(fields.join(', '))
          s = s.where("((#{index_localized} @@ to_tsquery(?)) OR (#{index_english} @@ to_tsquery(?))) #{additional_filter}", term, term)

        else
          
          index_name = full_text_indexes.first.to_s
          s = self.select("#{self.table_name}.*, ts_rank_cd((#{index_name}), to_tsquery(#{connection.quote(term)})) as rank").where("#{index_name} @@ to_tsquery(?) #{additional_filter}", term)
        
        end
      }
    end
    
    # Lazy translate
    translate_fields.each do |field|
      define_method field do
        locale = self.class.lazy_translation_language || I18n.locale
        if self.class.lazy_translation && locale != :en
          self.translation(locale).send(field.intern) 
        else 
          read_attribute(field) 
        end
      end
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
      eval(ActiveSupport::Inflector.camelize(file[file.rindex('/') + 1 .. -4])) rescue nil
    end
    
    # Return models that have translations
    ActiveRecord::Base.subclasses.select{|x| x.respond_to? :translated_fields}
  end
end
