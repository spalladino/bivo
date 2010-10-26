recaptcha_config_file = File.join(Rails.root,'config','recaptcha.yml')
unless File.exists? recaptcha_config_file
  raise "#{recaptcha_config_file} is missing!"
end
recaptcha_config = YAML.load_file(recaptcha_config_file)[Rails.env].symbolize_keys

ENV['RECAPTCHA_PUBLIC_KEY']  = recaptcha_config[:PublicKey]
ENV['RECAPTCHA_PRIVATE_KEY'] = recaptcha_config[:PrivateKey]
