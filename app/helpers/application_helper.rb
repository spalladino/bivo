module ApplicationHelper
  
  def on_document_ready(&block)
    "$(function() { #{block.call} });".html_safe
  end
  
end
