# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Bivo::Application.initialize!

#ActionView::Base.field_error_proc = Proc.new { |input, instance| "<span class=\"fieldWithErrors\">#{input}</span>".html_safe }

