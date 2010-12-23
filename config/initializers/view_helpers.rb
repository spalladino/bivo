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
