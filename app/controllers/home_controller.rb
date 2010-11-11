require 'money'
require 'money/bank/google_currency'

class HomeController < ApplicationController
  skip_before_filter :check_eula_accepted, :only => [:accept_eula, :confirm_eula]

  def index
    @raised_amount = Income.founds_raised(1.month.ago, Date.today)
    @exchange = CurrencyExchange.get_conversion_rate(1, :USD, :EUR)
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
    @periods = [["this month","this_month"],
                ["last month","last_month"], 
                ["this year", "this_year"],
                ["last year", "last_year"],
                ["this quarter", "this_quarter"],
                ["last quarter", "last_quarter"],
                ["custom", "custom"]]
    
    @period = params["period"] || "this_month"
    
    if (@period.to_sym == :custom)
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
    else
      @from = get_period_from(@period.to_sym, Date.today)
      @to = get_period_to(@period.to_sym, Date.today)
    end

    @founds_raised = Income.founds_raised(@from, @to)
    @transactions = Transaction.transactions_count(@from, @to)
    @most_voted_causes = Cause.most_voted_causes
  end
end

