class ActiveRecord::Migration

  def self.table_exists?(name)
    ActiveRecord::Base.connection.tables.include?(name)
  end
  
  def self.tables
    ActiveRecord::Base.connection.tables
  end
  
  def self.full_text_index_name(table_name, name)
    [table_name, name, 'fts_idx'].compact.join('_')
  end
  
  def self.create_translated_full_text_indexes(table_name, fields)
    self.create_full_text_index table_name, fields
    Language.non_defaults.each do |lang|
      self.create_full_text_index "#{table_name.to_s.singularize}_translations_#{lang.id}", fields
      self.create_full_text_index "#{table_name.to_s.singularize}_translations_#{lang.id}", fields, lang.id, lang.english_name
    end
  end
  
  def self.create_full_text_index(table_name, fields, name=nil, language='english')
    drop_full_text_index(table_name, name)
    vector = fields.map{|field| "coalesce(""#{table_name}"".""#{field}"", '')"}.join(" || ' ' || ")
    execute(
"CREATE index #{full_text_index_name(table_name, name)}
ON #{table_name}
USING gin((to_tsvector('#{language}', #{vector})))")
  end
  
  def self.drop_translated_full_text_indexes(table_name, fields)
    self.drop_full_text_index table_name
    Language.non_defaults.each do |lang|
      self.drop_full_text_index "#{table_name.to_s.singularize}_translations_#{lang.id}"
      self.drop_full_text_index "#{table_name.to_s.singularize}_translations_#{lang.id}", lang.id
    end
  end
  
  def self.drop_full_text_index(table_name, name=nil)
    execute(
"DROP index IF EXISTS #{full_text_index_name(table_name, name)}")
  end
end
