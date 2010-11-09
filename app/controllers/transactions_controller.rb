class TransactionsController < ApplicationController

  before_filter :authenticate_user!, :except => [:index]

 def index
    @transactions = Transaction.all

    # Filter by kind of transaction
    @kind = params[:kind]
    @transactions = @transactions.where('transactions.type = ?',@kind) unless (@kind.blank? || @kind == :all)

    # Filter by text
    @name = params[:name]
    @transactions = @transactions.where('transactions.name ~* ? OR transactions.description ~* ?', @name, @name) unless @name.blank?

    # Filter by period
    @period = params[:period]
    if @period
      now = Date.today
      from = case @period
        when :this_month then now - now.day + 1.day
        when :last_month then now - now.day + 1.day - 1.month
        when :this_year then now - now.day + 1.day - now.month.month + 1.month
        when :last_year then now - now.day + 1.day - now.month.month + 1.month - 1.year
        when :this_quarter then now - now.day + 1.day - ((now.month-1)%3).month
        when :last_quarter then now - now.day + 1.day - ((now.month-1)%3).month - 3.month
        when :custom then now - 100.year
      end

      to = case @period
        when :this_month then from + 1.month
        when :last_month then from + 1.month
        when :this_year then from + 1.year
        when :last_year then from + 1.year
        when :this_quarter then from + 3.month
        when :last_quarter then from + 3.month
        when :custom then now + 100.year
      end

      @transactions =  @transactions.where('transaction.transaction_date BETWEEN ? and ?', from, to)
    end


    # Count for all transactions
    @count = @transactions.size

    # Set pagination
    @per_page = (params[:per_page] || 10).to_i
    @transactions = @transactions.paginate(:per_page => @per_page, :page => params[:page])
    @periods = [:this_month, :last_month, :this_year, :last_year, :this_quarter, :last_quarter,:custom]
    @kinds = [:all, :income, :expense]
    @page_sizes = [5,10,20,50,100]

  end


end

