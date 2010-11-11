class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :set_gettext_locale
  before_filter :check_eula_accepted
  before_filter :instantiate_controller_and_action_names

  def set_gettext_locale
    #session[:locale] = 'es' # Uncomment this line to test setting an alternative locale for gettext testingzzzzz
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
    if not (current_user && current_user.is_admin_user)
      render :nothing => true, :status => :forbidden
    end
  end

  protected
  
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
end

