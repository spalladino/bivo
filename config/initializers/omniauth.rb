facebook_config_file = File.join(Rails.root,'config','facebook.yml')
unless File.exists? facebook_config_file
  raise "#{facebook_config_file} is missing!"
end
facebook_config = YAML.load_file(facebook_config_file)[Rails.env].symbolize_keys

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, facebook_config[:APIKey], facebook_config[:ApplicationSecret]
end
