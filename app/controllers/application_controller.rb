class ApplicationController < ActionController::Base
  rescue_from ActiveRecord::RecordNotFound, :with => :render_not_found
  protect_from_forgery

  before_filter :set_gettext_locale
  before_filter :check_eula_accepted
  before_filter :instantiate_controller_and_action_names

  protected

  def only_admin
    if not (current_user && current_user.is_admin_user)
      render_forbidden
    end
  end

  def ajax_flash
    if request.xhr?
      flash.now
    else
      flash
    end
  end

  def set_gettext_locale
    if user_signed_in?
      session[:locale] = current_user.preferred_language.to_sym
    else
      if (session[:locale].nil?)
        session[:locale] = Language.preferred(get_browser_accept_languages).id
      end
    end
    super
  end

  def get_browser_accept_languages
    request.accept_language
  end  

  def check_eula_accepted
    if (user_signed_in? && !current_user.eula_accepted)
      redirect_to accept_eula_path
    end
  end

  def instantiate_controller_and_action_names
    @action_name = action_name
    @controller_name = controller_name
  end

  def get_period_from(period,date)
      case period
        when :this_month   then date.beginning_of_month
      when :last_month   then date.prev_month.beginning_of_month
        when :this_year    then date.beginning_of_year
        when :last_year    then date.prev_year.beginning_of_year
        when :this_quarter then date.beginning_of_quarter
        when :last_quarter then date.beginning_of_quarter - 3.month
      end
  end

  def get_period_to(period,date)
      case period
        when :this_month   then date.end_of_month
        when :last_month   then date.prev_month.end_of_month
        when :this_year    then date.end_of_year
        when :last_year    then date.prev_year.end_of_year
        when :this_quarter then date.end_of_quarter
        when :last_quarter then date.end_of_quarter - 3.month
      end
  end

  def render_forbidden
    render :file => "#{Rails.root.to_s}/public/403.html", :layout => false, :status => :forbidden
  end

  def render_not_found
    render :file => "#{Rails.root.to_s}/public/404.html", :layout => false, :status => :not_found
  end
end

