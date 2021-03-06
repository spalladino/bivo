module ApplicationHelper
  include UrlHelper

  def cause_funds_completed(cause)
    "#{cause.funds_raised} (#{cause_funds_percentage_completed(cause)} #{_('complete')})"
  end

  def back_button(text)
    return orange_link_to text, "javascript:history.back()"
  end
  
  # Wraps the js code within a document ready initializer
  def on_document_ready(&block)
    "$(function() { #{block.call} });".html_safe
  end

  def submit_form
    "$(this).closest('form').submit();"
  end

  # Trims the text to up to max_words and adds a read more link
  def read_more(text, url, max_words = 30)
    return '' if text.blank?
    parts = text.split(/\s/, max_words+1)
    if parts.size == max_words+1
      text = parts[0...-1].join(' ')
      if url
        "#{link_to(h(text), url)} #{link_to _('Read more'), url, :class => 'chariTxtRead'}".html_safe
      else
        "#{text}..."
      end
    else
      text
    end
  end

  # Admin only action to change charity status
  # * Deactivate button:  All children causes are deactivated as well.
  # * Activate button: Displayed only when the charity is deactivated.
  def active_deactive_charity_button(charity)
    if current_user && current_user.is_admin_user
      label = if charity.status_inactive? then _("Activate") else _("Deactivate") end
      action = if charity.status_inactive? then "activate" else "deactivate" end
      return orange_button_to(label,
        {:action => action, :controller=>"charities", :id => charity.id },
        :remote => true,
        :onclick => 'disableAndContinue(this,"Submitting...")',
        :id => "submit_active_btn_" + charity.id.to_s
      )
    end
  end

  def gallery(entity)
    render :partial => 'galleries/view', :locals => { :gallery => Gallery.for_entity(entity), :edit => false }
  end

  def edit_gallery_link(entity)
    if eval("#{entity.class}::GalleryRules").can_edit?(current_user, entity)
      orange_link_to _('Edit Gallery'), edit_gallery_path(entity.class.name, entity.id)
    end
  end

  # Appends a category parameter with the specified id to the current query string
  def category_filter_url(category, controller=@controller_name, action=@action_name)
    url_for({
      :action => action,
      :controller => controller,
      :sorting  => params['sorting'],
      :category => category.id
    })
  end

  def comments(entity)
    return render :partial => "comments/comments", :locals => {:entity => entity,:comment => @comment}
  end


  # Uses the Like functionality of Facebook.
  def facebook_like
    content_tag :iframe, nil, :src => "http://www.facebook.com/plugins/like.php?href=#{CGI::escape(request.url)}&layout=button_count&show_faces=true&width=450&action=like&font=arial&colorscheme=light&height=80", :scrolling => 'no', :frameborder => '0', :allowtransparency => true, :id => :facebook_like
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

  # escape as javascript safe enough to be included inside an html attribute
  # i.e. single quotes as \x27 and double quotes as \x22
  def attr_escape_javascript(s)
    escape_javascript(s).gsub(/\\'/,'\x27').gsub(/\\"/,'\x22')
  end

  def nl2br(s)
     s.gsub(/\n/, '<br>')
  end

  def link_to_cause(cause)
    link_to cause.name, url_cause(cause)
  end

  def url_cause(cause)
    { :controller => "causes", :action => "details", :url => cause.url }
  end

  def link_to_charity(charity)
    link_to charity.charity_name, url_charity(charity)
  end

  def url_charity(charity)
    { :controller => "charities", :action => "details", :url => charity.short_url, :subdomain => 'www' }
  end

  def shop_home_path(shop)
    { :controller => "shops", :action => "home", :short_url => shop.short_url, :subdomain => 'shop' }
  end

  def shop_details_path(shop)
    { :controller => "shops", :action => "details", :short_url => shop.short_url, :subdomain => 'shop' }
  end

  def styled_will_paginate(collection, atts={})
    will_paginate collection, {:previous_label => image_tag('pegiarL.png'), :next_label => image_tag('pegiarR.png'), :class => 'pegi', :inner_window => 0, :outer_window => 0}.merge(atts)
  end

  def all_shops_path
    { :controller => "/shops", :action => "index", :subdomain => 'shop' }
  end

  # Returns javascript snippet for submitting first parent form
  def submit_parent_form
    "$(this).parents('form:first').submit(); return false;"
  end

  def set_window_location(location)
    "window.location = '#{location.html_safe}'; return false;"
  end

  def gray_button_to(name, options = {}, html_options = {})
    html = Hpricot(button_to(name, options, html_options))
    html.search('//input[@type=submit]').wrap('<div class="buttonMainGra"></div>')
    html.search('//input[@type=submit]').add_class 'buttonMidGra'
    gra = html.search('.buttonMainGra')
    gra.prepend('<div class="graBtnSt"></div>')
    gra.append('<div class="graBtnEn"></div><br class="spacer"/>')

    html.to_html.html_safe
  end

  def gray_link_to(*args, &block)
    html = Hpricot(link_to(*args, &block))
    html.search('a').wrap('<div class="buttonMainGra"></div>')
    html.search('a').add_class 'buttonMidGra'
    gra = html.search('.buttonMainGra')
    gra.prepend('<div class="graBtnSt"></div>')
    gra.append('<div class="graBtnEn"></div><br class="spacer"/>')

    html.to_html.html_safe
  end

  def orange_button(obj)
     ('<div class="buttonMainVote"><div class="buttonSide accBtnSt"></div>' + obj + '<div class="buttonSide accBtnEn"></div><br class="spacer" /></div>').html_safe
  end

  def orange_button_to(name, options = {}, html_options = {})
    html = Hpricot(button_to(name, options, html_options))
    html.search('//input[@type=submit]').wrap('<div class="buttonMainFloat"></div>')
    html.search('//input[@type=submit]').add_class 'buttonMid accBtnMi'
    gra = html.search('.buttonMainFloat')
    gra.prepend('<div class="buttonSide accBtnSt"></div>')
    gra.append('<div class="buttonSide accBtnEn"></div><br class="spacer"/>')

    html.to_html.html_safe
  end

  def orange_submit_tag(name, options = {})
    html = Hpricot(submit_tag(name, options))
    html.search('//input[@type=submit]').wrap('<div class="buttonMainFloat"></div>')
    html.search('//input[@type=submit]').add_class 'buttonMid accBtnMi'
    gra = html.search('.buttonMainFloat')
    gra.prepend('<div class="buttonSide accBtnSt"></div>')
    gra.append('<div class="buttonSide accBtnEn"></div><br class="spacer"/>')

    html.to_html.html_safe
  end

  def orange_link_to(*args, &block)
    html = Hpricot(link_to(*args, &block))
    html.search('a').wrap('<div class="buttonMainFloat"></div>')
    html.search('a').add_class 'buttonMid accBtnMi'
    gra = html.search('.buttonMainFloat')
    gra.prepend('<div class="buttonSide accBtnSt"></div>')
    gra.append('<div class="buttonSide accBtnEn"></div><br class="spacer"/>')

    html.to_html.html_safe
  end

  def orange_link_to_function(*args, &block)
    html = Hpricot(link_to_function(*args, &block))
    html.search('a').wrap('<div class="buttonMainFloat"></div>')
    html.search('a').add_class 'buttonMid accBtnMi'
    gra = html.search('.buttonMainFloat')
    gra.prepend('<div class="buttonSide accBtnSt"></div>')
    gra.append('<div class="buttonSide accBtnEn"></div><br class="spacer"/>')

    html.to_html.html_safe
  end

  def inline_orange_link_to(*args, &block)
    html = Hpricot(link_to(*args, &block))
    html.search('a').wrap('<span class="buttonMainFloat"></span>')
    html.search('a').add_class 'buttonSide accBtnMi'
    html.search('a').set "style", "width: auto;"
    gra = html.search('.buttonMainFloat')
    gra.prepend('<span class="buttonSide accBtnSt"></span>')
    gra.append('<span class="buttonSide accBtnEn"></span>')

    gra.wrap('<span style= "float:right; display: inline;"></span>')

    html.to_html.html_safe
  end

  def pop_up_single_block(title, &block)
    content_tag :div, :class => "inbodyM" do
      content_tag :div, :class => "bodyInSmPopUp" do
        '<div class="GrTSm"><h2>' + title + '</h2></div>' + '<div class="boxMainPopUp">' + content_tag(:div, &block) + '<div class="bodyBot"></div></div>'
      end
    end
  end

  def single_block(title, &block)
    content_tag :div, :class => "inbodyM" do
      content_tag :div, :class => "bodyInSm" do
        '<div class="GrTSm"><h2>' + title + '</h2></div>' + '<div class="boxMainSm">' + content_tag(:div, &block) + '<div class="bodyBot"></div></div>'
      end
    end
  end

  def large_single_block(title, &block)
    content_tag :div, :class => "inbodyM" do
      content_tag :div, :class => "bodyInner" do
        '<div class="statGrT"><h2>' + title + '</h2></div>' + '<div class="boxMain">' + content_tag(:div, &block) + '<div class="bodyBot"></div></div>'
      end
    end
  end

  def bivo_form_for(record_or_name_or_array, *args, &proc)
    options = args.extract_options!
    form_for(record_or_name_or_array, *(args << options.merge(:builder => BivoFormBuilder)), &proc)
  end

  def set_zebra_style_to_table(table_class, even_class, odd_class)
    "$(document).ready(function() {
       $('.#{table_class.to_s} tr:has(td):even').addClass('#{even_class.to_s}');
       $('.#{table_class.to_s} tr:has(td):odd').addClass('#{odd_class.to_s}');
     });"
  end

  def charity_short_url_prefix
    request.protocol + request.host + request.port_string + '/charity/'
  end

  def cause_short_url_prefix
    request.protocol + request.host + request.port_string + '/cause/'
  end

  def static_page(id)
    { :controller => '/home', :action => :about, :id => id, :subdomain => 'www' }
  end

  def feedback_url
    "http://bivo.uservoice.com/"
  end

  def pipe_li
    "<li class=\"rpPipe\">|</li>"
  end
end

