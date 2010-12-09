class ShopTranslation < ActiveRecord::Base
end
=begin
Language.all.reject{|l| l.id == Language::DefaultLanguage}.each do |lang|
  str = "
    class ShopTranslation#{lang.id.capitalize.to_s} < ActiveRecord::Base
      set_table_name 'shop_translations_#{lang.id.to_s}'
      belongs_to :shop
      index('translated', '#{lang.english_name}') do
        name
        description
      end
      
      def language
        return '#{lang.id.to_s}'
      end
    end"
  eval(str)
end
=end
