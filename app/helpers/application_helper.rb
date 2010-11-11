module ApplicationHelper

  # Wraps the js code within a document ready initializer
  def on_document_ready(&block)
    "$(function() { #{block.call} });".html_safe
  end

  # Trims the text to up to max_words and adds a read more link
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

  def reply_comment_button(comment)
   return content_tag :div, button(_("Reply"),
:onclick=>"showComments();reply(#{comment.id})")

  end

  def edit_comment_button(comment)

    return content_tag :div,
      button_to(_("Edit"),
        {:action => "edit_comment",:controller => "application", :id => comment.id },
        :remote => true,
        :id => "follow_cause_btn"
      )
  end

  def delete_comment_button(comment)

    return content_tag :div,
      button_to(_("Delete"),
        {:action => "delete_comment", :controller => "application",:id => comment.id },
        :remote => true,
        :id => "follow_cause_btn"
      )
  end

  # Uses the Like functionality of Facebook.
  def facebook_like
    content_tag :iframe, nil, :src => "http://www.facebook.com/plugins/like.php?href=#{CGI::escape(request.url)}&layout=standard&show_faces=true&width=450&action=like&font=arial&colorscheme=light&height=80", :scrolling => 'no', :frameborder => '0', :allowtransparency => true, :id => :facebook_like
  end


  # Remove link for a child
  def remove_link_unless_new_record(fields)
    out = ''
    out << fields.hidden_field(:_delete)  unless fields.object.new_record?
    out << link_to("remove", "##{fields.object.class.name.underscore}", :class => 'remove')
    out
  end

  # This method demonstrates the use of the :child_index option to render a
  # form partial for, for instance, client side addition of new nested
  # records.
  #
  # This specific example creates a link which uses javascript to add a new
  # form partial to the DOM.
  #
  #   <% form_for @obj do |obj_form| %>
  #     <div id="children">
  #       <% obj_form.fields_for :children do |child_form| %>
  #         <%= render :partial => 'child', :locals => { :f => child_form } %>
  #       <% end %>
  #     </div>
  #   <% end %>
  def generate_html(form_builder, method, options = {})
    options[:object] ||= form_builder.object.class.reflect_on_association(method).klass.new
    options[:partial] ||= method.to_s.singularize
    options[:form_builder_local] ||= :f

    form_builder.fields_for(method, options[:object], :child_index => 'NEW_RECORD') do |f|
      render(:partial => options[:partial], :locals => { options[:form_builder_local] => f })
    end
  end

  def generate_template(form_builder, method, options = {})
    escape_javascript generate_html(form_builder, method, options)
  end

end

