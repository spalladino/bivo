module MailerHelper
  def absolute_link_to_cause(cause)
    link_to cause.name, absolute_url_cause(cause)
  end

  def absolute_url_cause(cause)
    { :controller => "causes", :action => "details", :url => cause.url, :only_path => false }
  end

  def absolute_link_to_charity(charity)
    link_to charity.charity_name, absolute_url_charity(charity)
  end

  def absolute_url_charity(charity)
    { :controller => "charities", :action => "details", :url => charity.short_url, :only_path => false }
  end
end
