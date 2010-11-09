class TransactionsController < ApplicationController

  before_filter :authenticate_user!, :except => [:index]

 def index
   # Filter by kind (income-expense)
    if params[:kind]
      @kind = params[:kind].to_sym
    else
      @kind = :all
    end

    # Filter by description
    if params[:description]
      @description = params[:description].to_sym
    else
      @description = ""
    end

    # Filter by period
    if params[:period]
      @period = params[:period].to_sym

      if @period == :custom

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

        @from = get_period_from(@period,Date.today)
        @to = get_period_to(@period,Date.today)

      end

    end

    # get transactions by kind
    if @kind && @kind == :all
      @transactions = Transaction.where("transactions.type ~* 'Expense' OR transactions.type ~* 'Income'")
    else
      @transactions = Transaction.where("transactions.type ~* ?",@kind)
    end

    #get transactions that match description
    @transactions = @transactions.where("transactions.description ~* ?", @description) unless @description.blank?

    #get transactions that match period
    @transactions = @transactions.where('transactions.transaction_date BETWEEN ? AND ?', @from, @to) unless @period.nil?

    # Set result count
    @count = @transactions.count

    # Set pagination
    @per_page = (params[:per_page] || 10).to_i
    @transactions = @transactions.paginate(:per_page => @per_page, :page => params[:page])

    # Options to complete selects
    @periods = [:this_month, :last_month, :this_year, :last_year, :this_quarter, :last_quarter,:custom]
    @kinds = [:all, :income, :expense]
    @page_sizes = [5,10,20,50,100]

  end

private

  def get_period_from(period,now)
      from = case period
        when :this_month then now.beginning_of_month
        when :last_month then now.beginning_of_month - 1.month
        when :this_year then now.beginning_of_year
        when :last_year then now.beginning_of_year - 1.year
        when :this_quarter then now.beginning_of_quarter
        when :last_quarter then now.beginning_of_quarter - 3.month
      end
      return from
  end

  def get_period_to(period,now)
      to = case period
        when :this_month then now.end_of_month
        when :last_month then now.end_of_month - 1.month
        when :this_year then now.end_of_year
        when :last_year then now.end_of_year - 1.year
        when :this_quarter then now.end_of_quarter
        when :last_quarter then now.end_of_quarter - 3.month
      end
      return to
  end
end

