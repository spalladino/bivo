module ApplicationHelper
  
  def on_document_ready(&block)
    "$(function() { #{block.call} });".html_safe
  end
  
  def read_more(text, url, max_words = 30)
    return '' if text.blank?
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
  
  # Appends a category parameter with the specified id to the current query string
  def category_filter_url(category, controller=@controller_name, action=@action_name)
    query = CGI.parse(request.query_string).symbolize_keys
    query.each {|k,v| query[k] = v.first}
    query[:category] = category.id
    url_for({:action => action, :controller => controller}.merge(query))
  end

  
end
