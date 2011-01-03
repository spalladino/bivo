require 'money'
require 'money/bank/google_currency'

class HomeController < ApplicationController
  MIN_FONT_TAG_CLOUD = 15  
  MAX_FONT_TAG_CLOUD = 40  
  skip_before_filter :set_gettext_locale, :only => [:change_language]
  skip_before_filter :check_eula_accepted, :only => [:accept_eula, :confirm_eula]

  def index
    @section = :home_index
    @raised_amount = Income.funds_raised(1.month.ago, Date.today)
  end

  def eula

  end

  def accept_eula
    unless (user_signed_in? && !current_user.eula_accepted)
      redirect_to root_path
    end
  end

  def confirm_eula
    if (params[:eula_accepted])
      current_user.eula_accepted = true
      current_user.save
    end

    redirect_to root_path
  end

  def dashboard
    @section = :dashboard
    load_periods
    
    @funds_raised = Income.funds_raised(@from, @to)
    @transactions = Income.transactions_count(@from, @to)
    @causes_being_funded = Cause.causes_being_funded(@from, @to)
    @most_voted_causes = Cause.most_voted_causes(@from, @to)
    @fully_funded_causes = Cause.fully_funded(@from, @to).count
    @shops_to_cloud = get_shops_with_font_calculation(Shop.all, @from, @to)
  end
  
  def stats
    load_periods

    @cash_reserves = Account.cash_reserves_account.balance_at(@to)

    @expenses = Expense.between(@from, @to)
    @expense_categories = ExpenseCategory.stats(@from, @to)
    @expenses_total = @expense_categories.sum(&:amount) rescue 0.to_d

    @revenues = Income.between(@from, @to)
    @revenue_categories = IncomeCategory.stats(@from, @to)
    @revenues_total = @revenue_categories.sum(&:revenue_amount) rescue 0.to_d
  end

  def change_language
    if ((params["language"]) && (Language.all.map(&:id).include? params["language"].to_sym))
      session[:locale] = params["language"].to_sym
    end

    if (user_signed_in?)
      current_user.preferred_language = session[:locale]
      current_user.save
    end

    redirect_to request.referrer
  end

  def change_currency
    if params[:currency] && Currency.by_id(params[:currency])
      session[:currency] = params[:currency].to_sym
    end

    if (user_signed_in?)
      current_user.preferred_currency = session[:currency]
      current_user.save
    end

    redirect_to request.referrer
  end

  def how_it_works
  end

  def jobs
  end

  def social_initiatives
  end

  def fund_raisers
  end

  def about
    @section = :about    
  end
  
  protected
  
  def load_periods
    @periods = [["this month","this_month"],
                ["last month","last_month"],
                ["this year", "this_year"],
                ["last year", "last_year"],
                ["this quarter", "this_quarter"],
                ["last quarter", "last_quarter"],
                ["custom", "custom"]]

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
    
    true    
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

  def get_shops_with_font_calculation(shops_to_cloud, from, to)
    shops_to_cloud.each do |shop| 
      shop.define_accessor :incomes_sum, shop.incomes_in_period(from, to)
    end
    
    shops_to_cloud = shops_to_cloud.select { |shop| shop.incomes_sum.round.to_i > 0 }
    # calculation to map minimum and maximum incomes to the minimum and maximum fonts in shop cloud.
    period_incomes = shops_to_cloud.map { |shop| shop.incomes_sum }    
    min_found = period_incomes.min || 0
    max_found = period_incomes.max || 0
    min_font = MIN_FONT_TAG_CLOUD.to_d
    max_font = MAX_FONT_TAG_CLOUD.to_d

    pend = ((max_font - min_font) / (max_found - min_found))
    offset = max_font - (pend * max_found)

    shops_to_cloud.each do |shop|
      if (min_found == max_found)
        shop.define_accessor :font_size, (min_found + max_found) / 2.0
      else
        shop.define_accessor :font_size, ((pend * shop.incomes_sum) + offset).round
      end
    end

    shops_to_cloud
  end
end

