class TransactionsController < ApplicationController
  before_filter :authenticate_user!, :except => [:index]
  before_filter :only_admin, :except => [:index]

 def index


    if params[:kind]
      @sorting = params[:sorting].to_sym
    else
      @sorting = :all
    end

   # Filter by kind (income-expense)
    if params[:kind]
      @kind = params[:kind].to_sym
    else
      @kind = :all
    end

    # Filter by description
    if params[:description]
      @description = params[:description]
    else
      @description = ""
    end

    load_periods

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

    @transactions = @transactions.order case @sorting
      when :type then 'type ASC'
      when :date_new then 'transaction_date DESC'
      when :date_old then 'transaction_date ASC'
      when :description then 'description ASC'
      when :amount_desc then 'amount DESC'
      when :amount_asc then 'amount ASC'

      else'id ASC'
     end

    # Set result count
    @count = @transactions.count

    # Set pagination
    @sortings = [
      [_('type'), :type],
      [_('newest'), :date_new],
      [_('oldest'), :date_old],
      [_('description'), :description],
      [_('greater amount'),:amount_desc],
      [_('lower amount'),:amount_asc]
    ]
    @per_page = (params[:per_page] || 10).to_i
    @transactions = @transactions.paginate(:per_page => @per_page, :page => params[:page])
    @kinds = [:all, :income, :expense]

    @page_sizes = [5,10,20,50,100]

  end

  def new
    load_create_options
    @transaction = Transaction.new
  end

  def create
    type = params["transaction"].delete("type")

    if (type == "Income")
      @transaction = Income.new(params["transaction"])
    elsif (type == "Expense")
      @transaction = Expense.new(params["transaction"])
    else
      @transaction = Transaction.new
    end

    @transaction.user = current_user

    if (@transaction.save)
      redirect_to transaction_list_path
    else
      load_create_options
      render "new"
    end
  end

  def edit
    @transaction = Transaction.find(params[:id])
    load_update_options
  end

  def update
    @transaction = Transaction.find(params[:id])
    @transaction.description = params[:transaction][:description]
    @transaction.input_currency = params["transaction"]["input_currency"]
    @transaction.input_amount = params["transaction"]["amount"]

    if @transaction.save
      redirect_to transaction_list_path
    else
      load_update_options

      render "edit"
    end
  end

  private

  def load_create_options
    load_currency
    @currencies = Currency.all.collect { |c| [c.name, c.id] }
    @income_categories = IncomeCategory.all
    @expense_categories = ExpenseCategory.all
    @shops = Shop.all
  end

  def load_update_options
    load_currency
    @currencies = Currency.all.collect { |c| [c.name, c.id] }
  end

  def load_currency
    if (params["transaction"])
      @currency = params["transaction"]["input_currency"]
    else
      @currency = Transaction::DefaultCurrency
    end
  end
end

