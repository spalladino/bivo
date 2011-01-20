class IncomeCategoriesController < ApplicationController
  layout 'plain'
  prepend_before_filter :authenticate_user!, :only_admin
  # GET /income_categories
  # GET /income_categories.xml
  def index
    @income_categories = IncomeCategory.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @income_categories }
    end
  end

  def show
    @income_category = IncomeCategory.find(params[:id])
  end

  def new
    @income_category = IncomeCategory.new
  end

  # GET /income_categories/1/edit
  def edit
    @income_category = IncomeCategory.find(params[:id])
  end

  def create
    @income_category = IncomeCategory.new(params[:income_category])

    if @income_category.name != IncomeCategory::ShopName && @income_category.save
      redirect_to(income_categories_path, :notice => 'Income source was successfully created.')
    else
      ajax_flash[:notice] = _("Error, invalid name")
      render :action => "new"
    end

  end

   def update
    @income_category = IncomeCategory.find(params[:id])

    if @income_category.name != IncomeCategory::ShopName && @income_category.update_attributes(params[:income_category])
      redirect_to(income_categories_path, :notice => 'Income source was successfully updated.')
    else
      render :action => "edit"

    end
  end

  def destroy
    @income_category = IncomeCategory.find(params[:id])
    if @income_category.name == IncomeCategory::ShopName
      redirect_to(income_categories_url)
    else
      @income_category.destroy
      redirect_to(income_categories_url)
    end
  end

  def list_options
    @income_categories = IncomeCategory.all
    render :partial => 'select_categories'
  end
end

