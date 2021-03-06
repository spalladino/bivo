class ApplicationController < ActionController::Base
  rescue_from ActiveRecord::RecordNotFound, :with => :render_not_found
  protect_from_forgery

  before_filter :set_main_site_as_default
  before_filter :set_gettext_locale
  before_filter :set_currency
  before_filter :check_eula_accepted
  before_filter :instantiate_controller_and_action_names
  before_filter :load_languages
  before_filter :load_currencies
  before_filter :mailer_set_url_options
  before_filter :store_last_visited_page_as_guest

  protected

  def set_main_site_as_default
    self.default_url_options = { :host => ['www.', request.domain, request.port_string].join }
  end

  def only_admin
    if not (current_user && current_user.is_admin_user)
      render_forbidden
    end
  end

  def admin_is_logged_in
    current_user && current_user.is_admin_user
  end

  def ajax_flash
    if request.xhr?
      flash.now
    else
      flash
    end
  end

  def set_currency
    if user_signed_in? && Currency.by_id(current_user.preferred_currency)
      session[:currency] = current_user.preferred_currency.to_sym
    elsif session[:currency].nil?
      country_data = self.get_country_from_ip
      session[:currency] = Currency.from_geo country_data[6], country_data[3]
    end
  end

  def set_gettext_locale
    if user_signed_in? && Language.by_id(current_user.preferred_language)
      session[:locale] = current_user.preferred_language.to_sym
    elsif (session[:locale].nil?)
      session[:locale] = Language.preferred(get_browser_accept_languages).id || :en
    end
    I18n.locale = session[:locale]
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

  def load_languages
    @languages = Language.all
    @language = Language.by_id(session[:locale].to_sym)
  end

  def load_currencies
    @all_currencies = Currency.all
    @current_currency = Currency.by_id(session[:currency].to_sym)
  end

  def mailer_set_url_options
    ActionMailer::Base.default_url_options[:host] = request.host_with_port
  end
  
  def append_errors(message, entity)
    message + ". " + entity.errors.values.flatten.to_sentence(:last_word_connector => " and ")
  end

  def get_country_from_ip
    @@geoip ||= GeoIP.new(Rails.root.to_s + '/data/GeoIP.dat')
    @@geoip.country request.remote_ip
  end
  
  def store_last_visited_page_as_guest
    # only for to devise/session#new
    if params[:action] == "new" && params[:controller] == "devise/sessions"
      session[:"user_return_to"] = request.referrer
      @section = :login
    end
  end
  
  def load_ratings
    @ratings = (0..5).map{|i| ["#{i} #{n_('star', 'stars', i)}", i]}
  end

  def load_periods
    @periods = [
      :this_month, :last_month, :this_year, 
      :last_year, :this_quarter, :last_quarter,
      :custom].map { |p| [p.to_pascal_case, p] }

    @period = params["period"] || "this_month"

    if @period.to_sym == :custom
      begin 
        load_custom_periods
      rescue
        load_non_custom_periods
        flash.now[:error] = _('Please select a valid date (now displaying current month).')
        return false
      end
    else
      load_non_custom_periods
    end
    
    return true
  end

  def load_custom_periods
    @from = Date.civil(
      params[:custom_from][:year].to_i,
      params[:custom_from][:month].to_i,
      params[:custom_from][:day].to_i
    )

    @to = Date.civil(
      params[:custom_to][:year].to_i,
      params[:custom_to][:month].to_i,
      params[:custom_to][:day].to_i
    )
  end
  
  def load_non_custom_periods
    @from = get_period_from(@period.to_sym, Date.today)
    @to = get_period_to(@period.to_sym, Date.today)
  end
end

