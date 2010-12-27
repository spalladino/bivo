class Language
  DefaultLanguage = :en
  attr_accessor :id, :name, :english_name

  def initialize(id, data)
    self.id = id
    self.name = data[:name]
    self.english_name = data[:english_name]
  end

  def self.all
    result = []
    Bivo::Application.config.languages.each_pair do |key, value|
      result << new(key, value)
    end
    result
  end

  def self.default
    DefaultLanguage
  end

  def self.non_defaults
    self.all.reject{|l| l.id == DefaultLanguage}
  end

  def self.by_id(id)
    if id && Bivo::Application.config.languages.include?(id.to_sym)
      new(id.to_sym, Bivo::Application.config.languages[id.to_sym])
    else
      nil
    end
  end
  
  #get the first language from the accepted languages that is available.
  #if there isnt one, it use the default language
  #note: may be its convenient to extend the module for request.
  def self.preferred(data)
    begin
      lang_selected = nil
      user_preferred_languages = data.split(/\s*,\s*/).collect do |l|
        l += ';q=1.0' unless l =~ /;q=\d+\.\d+$/
        l.split(';q=')
      end.sort do |x,y|
        raise "Not correctly formatted" unless x.first =~ /^[a-z\-]+$/i
        y.last.to_f <=> x.last.to_f
      end.each do |l|
        temp_lang = l.first.downcase.gsub(/-[a-z]+$/i) { |x| x.upcase }
        if (Bivo::Application.config.languages.keys.include?(temp_lang.to_sym) && !lang_selected)
          lang_selected = new(temp_lang.to_sym, Bivo::Application.config.languages[temp_lang.to_sym])
        end
      end
      lang_selected || new(DefaultLanguage, Bivo::Application.config.languages[DefaultLanguage])
    rescue # Just rescue anything if the browser messed up badly.
      new(DefaultLanguage, Bivo::Application.config.languages[DefaultLanguage])
    end
  end
end
