FastGettext.add_text_domain 'app', :path => 'locale', :type => :po, :ignore_fuzzy => true, :ignore_obsolete => true 
FastGettext.default_available_locales = ['en','es', 'fr']
FastGettext.default_text_domain = 'app'
FastGettext.default_locale = 'en'
