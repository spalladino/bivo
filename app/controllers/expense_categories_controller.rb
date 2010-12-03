class ExpenseCategoriesController < ApplicationController
  layout nil
  prepend_before_filter :authenticate_user!, :only_admin
  # GET /expense_categories
  # GET /expense_categories.xml
  def index
    @expense_categories = ExpenseCategory.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @expense_categories }
    end
  end

  # GET /expense_categories/1
  # GET /expense_categories/1.xml
  def show
    @expense_category = ExpenseCategory.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @expense_category }
    end
  end

  # GET /expense_categories/new
  # GET /expense_categories/new.xml
  def new
    @expense_category = ExpenseCategory.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @expense_category }
    end
  end

  # GET /expense_categories/1/edit
  def edit
    @expense_category = ExpenseCategory.find(params[:id])
  end

  # POST /expense_categories
  # POST /expense_categories.xml
  def create
    @expense_category = ExpenseCategory.new(params[:expense_category])

    respond_to do |format|
      if @expense_category.save
        format.html { redirect_to(@expense_category, :notice => 'Expense category was successfully created.') }
        format.xml  { render :xml => @expense_category, :status => :created, :location => @expense_category }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @expense_category.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /expense_categories/1
  # PUT /expense_categories/1.xml
  def update
    @expense_category = ExpenseCategory.find(params[:id])

    respond_to do |format|
      if @expense_category.update_attributes(params[:expense_category])
        format.html { redirect_to(@expense_category, :notice => 'Expense category was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @expense_category.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /expense_categories/1
  # DELETE /expense_categories/1.xml
  def destroy
    @expense_category = ExpenseCategory.find(params[:id])
    @expense_category.destroy

    respond_to do |format|
      format.html { redirect_to(expense_categories_url) }
      format.xml  { head :ok }
    end
  end

  def list_options
    @expense_categories = ExpenseCategory.all
    render :partial => 'select_categories'
  end
end
