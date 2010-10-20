class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :set_gettext_locale

  def set_gettext_locale
    #session[:locale] = 'es' # Uncomment this line to test setting an alternative locale for gettext testing
    super
  end

  def ajax_flash
    if request.xhr?
      flash.now
    else
      flash
    end
  end

 def only_admin
    if not current_user.is_admin_user
      render :nothing => true, :status => :forbidden
    end
  end

end

