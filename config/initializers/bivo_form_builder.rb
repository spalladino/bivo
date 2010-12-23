
class BivoFormBuilder < ActionView::Helpers::FormBuilder
  def label(method, text = nil, options = {})
    ('<p class="accfilTxt">' + super + '</p>').html_safe
  end
  
  def text_field(method, options = {})
    normal_input(super)
  end

  def password_field(method, options = {})
    normal_input(super)
  end

  def select(method, choices, options = {}, html_options = {})
    normal_input(super, 'accChoo')
  end
  
  def file_field(method, options = {})
    normal_input(super)
  end
  
  def text_area(method, options = {})
    normal_input(super, 'accMess')
  end
  
  def submit(value = "Save changes", options = {})
    BivoFormBuilder.orange_button_wrap(super)
  end
  
  def self.orange_button_wrap(original)
    html = Hpricot(original)
    html.search('//input[@type=submit]').wrap('<div class="buttonMainACC"></div>')
    html.search('//input[@type=submit]').add_class 'buttonMid accBtnMi'
    gra = html.search('.buttonMainACC')
    gra.prepend('<div class="buttonSide accBtnSt"></div>')
    gra.append('<div class="buttonSide accBtnEn"></div><br class="spacer"/>')

    html.to_html.html_safe
  end
  
  protected
  
  def normal_input(original, more_class = nil)
    html = Hpricot(original)
    html.search('input, select, textarea').add_class "accfil #{more_class}"
    (html.to_html + '<br class="spacer"/>').html_safe    
  end
  
end