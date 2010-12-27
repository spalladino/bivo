module ActionView
  module Helpers
    module FormTagHelper
      
      def submit_tag_with_ie_fix(value = "Save changes", options = {})
        if options.include?(:disable_with) && iexplorer?
          options[:onclick] = "disableAndContinue(this,\"#{options[:disable_with]}\")"
          options.delete :disable_with
        end
        submit_tag_without_ie_fix value, options
      end
      alias_method_chain :submit_tag, :ie_fix
      
      protected
      
      def iexplorer?
        return request.env['HTTP_USER_AGENT'] =~ /MSIE/
      end

    end
  end
end