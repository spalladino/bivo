require File.expand_path('../boot', __FILE__)

require 'rails/all'

# If you have a Gemfile, require the gems listed there, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env) if defined?(Bundler)

module Bivo
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths += %W(#{config.root}/app/models/accounting)

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # JavaScript files you want as :defaults (application.js is always included).
    # config.action_view.javascript_expansions[:defaults] = %w(jquery rails)

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]
    
    # Configure generator options
    config.generators do |g|
      g.fixture :false
    end

    config.currencies = {
      :DZD => "Algerian Dinar (DZD)",
      :ARS => "Argentine Peso (ARS)",
      :AUD => "Australian Dollar (AUD)",
      :BHD => "Bahraini Dinar (BHD)",
      :BDT => "Bangladeshi Taka (BDT)",
      :BOB => "Bolivian Boliviano (BOB)",
      :BWP => "Botswanan Pula (BWP)",
      :BRL => "Brazilian Real (BRL)",
      :GBP => "British Pound Sterling (GBP)",
      :BND => "Brunei Dollar (BND)",
      :BGN => "Bulgarian Lev (BGN)",
      :CAD => "Canadian Dollar (CAD)",
      :KYD => "Cayman Islands Dollar (KYD)",
      :XOF => "CFA Franc BCEAO (XOF)",
      :CLP => "Chilean Peso (CLP)",
      :CNY => "Chinese Yuan Renminbi (CNY)",
      :COP => "Colombian Peso (COP)",
      :CRC => "Costa Rican Colon (CRC)",
      :HRK => "Croatian Kuna (HRK)",
      :CZK => "Czech Republic Koruna (CZK)",
      :DKK => "Danish Krone (DKK)",
      :DOP => "Dominican Peso (DOP)",
      :EGP => "Egyptian Pound (EGP)",
      :EEK => "Estonian Kroon (EEK)",
      :EUR => "Euro (EUR)",
      :FJD => "Fijian Dollar (FJD)",
      :HNL => "Honduran Lempira (HNL)",
      :HKD => "Hong Kong Dollar (HKD)",
      :HUF => "Hungarian Forint (HUF)",
      :ISK => "Icelandic Krona (ISK)",
      :INR => "Indian Rupee (INR)",
      :IDR => "Indonesian Rupiah (IDR)",
      :ILS => "Israeli New Sheqel (ILS)",
      :JMD => "Jamaican Dollar (JMD)",
      :JPY => "Japanese Yen (JPY)",
      :JOD => "Jordanian Dinar (JOD)",
      :KZT => "Kazakhstan Tenge (KZT)",
      :KES => "Kenyan Shilling (KES)",
      :KWD => "Kuwaiti Dinar (KWD)",
      :LVL => "Latvian Lats (LVL)",
      :LBP => "Lebanese Pound (LBP)",
      :LTL => "Lithuanian Litas (LTL)",
      :MKD => "Macedonian Denar (MKD)",
      :MYR => "Malaysian Ringgit (MYR)",
      :MVR => "Maldivian Rufiyaa (MVR)",
      :MUR => "Mauritian Rupee (MUR)",
      :MXN => "Mexican Peso (MXN)",
      :MDL => "Moldovan Leu (MDL)",
      :MAD => "Moroccan Dirham (MAD)",
      :NAD => "Namibian Dollar (NAD)",
      :NPR => "Nepalese Rupee (NPR)",
      :ANG => "Netherlands Antillean Guilder (ANG)",
      :TWD => "New Taiwan Dollar (TWD)",
      :NZD => "New Zealand Dollar (NZD)",
      :NIO => "Nicaraguan Cordoba Oro (NIO)",
      :NGN => "Nigerian Naira (NGN)",
      :NOK => "Norwegian Krone (NOK)",
      :OMR => "Omani Rial (OMR)",
      :PKR => "Pakistani Rupee (PKR)",
      :PGK => "Papua New Guinean Kina (PGK)",
      :PYG => "Paraguayan Guarani (PYG)",
      :PEN => "Peruvian Nuevo Sol (PEN)",
      :PHP => "Philippine Peso (PHP)",
      :PLN => "Polish Zloty (PLN)",
      :QAR => "Qatari Rial (QAR)",
      :RON => "Romanian Leu (RON)",
      :RUB => "Russian Ruble (RUB)",
      :SVC => "Salvadoran Colon (SVC)",
      :SAR => "Saudi Riyal (SAR)",
      :RSD => "Serbian Dinar (RSD)",
      :SCR => "Seychellois Rupee (SCR)",
      :SLL => "Sierra Leonean Leone (SLL)",
      :SGD => "Singapore Dollar (SGD)",
      :SKK => "Slovak Koruna (SKK)",
      :ZAR => "South African Rand (ZAR)",
      :KRW => "South Korean Won (KRW)",
      :LKR => "Sri Lanka Rupee (LKR)",
      :SEK => "Swedish Krona (SEK)",
      :CHF => "Swiss Franc (CHF)",
      :TZS => "Tanzanian Shilling (TZS)",
      :THB => "Thai Baht (THB)",
      :TTD => "Trinidad and Tobago Dollar (TTD)",
      :TND => "Tunisian Dinar (TND)",
      :TRY => "Turkish Lira (TRY)",
      :UGX => "Ugandan Shilling (UGX)",
      :UAH => "Ukrainian Hryvnia (UAH)",
      :AED => "United Arab Emirates Dirham (AED)",
      :UYU => "Uruguayan Peso (UYU)",
      :USD => "US Dollar (USD)",
      :UZS => "Uzbekistan Som (UZS)",
      :VEF => "Venezuelan Bolivar Fuerte (VEF)",
      :VND => "Vietnamese Dong (VND)",
      :YER => "Yemeni Rial (YER)",
      :ZMK => "Zambian Kwacha (ZMK)"
    }
  end
end
