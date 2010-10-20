module ApplicationHelper
  
  def on_document_ready(&block)
    "$(function() { #{block.call} });".html_safe
  end
  
  def read_more(text, url, max_words = 30)
    parts = text.split(/\s/, max_words+1)
    if parts.size == max_words+1
      text = parts[0...-1].join(' ')
      if url
        "#{h text} #{link_to _('read more...'), url}".html_safe
      else
        "#{text}..."
      end
    else
      text
    end
  end
  
end
