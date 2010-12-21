# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Bivo::Application.initialize!

ActionView::Base.field_error_proc = Proc.new do |html_tag, instance|
  if html_tag =~ /<(input|label|textarea|select)/
    error_class = 'error'
    nodes = Hpricot(html_tag)
    nodes.each_child { |node| node[:class] = node.classes.push(error_class).join(' ') unless !node.elem? || node[:type] == 'hidden' || node.classes.include?(error_class) }
    nodes.to_html.html_safe
  else
    html_tag
  end
end