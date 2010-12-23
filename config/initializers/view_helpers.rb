module ActionView
  module Helpers
  
    class DateTimeSelector
      def translated_date_order
        begin
          order = I18n.translate(:'date.order', :locale => @options[:locale])
          if order.respond_to?(:to_ary)
            order
          else
            [:year, :month, :day]
          end
        end
      end
    end
  
  end
end

module ActionView
 module Helpers
   module NumberHelper
   
     alias :old_number_to_currency :number_to_currency
     def number_to_currency(number, options={})
       old_number_to_currency number, {:unit => @current_currency.html_symbol}.merge(options)
     end
   
   end
 end
end
