class ShopCategoriesController < ApplicationController
  layout nil
  before_filter :only_admin

  def edit
    load_category
    @newcategory = ShopCategory.new :parent => @category
  end

  def create
    @newcategory = ShopCategory.new params[:newcategory]
    if @newcategory.save
      redirect_to :action => :edit, :id => params[:newcategory][:parent_id]
    else
      load_category
      render 'edit'
    end
  end
  
  def update
    @category = ShopCategory.find_by_id params[:id]
    @category.attributes = params[:category]
    if @category.save
      flash[:notice] = 'category updated'
      redirect_to :action => :edit, :id => params[:id]
    else
      load_category_context
      @newcategory = ShopCategory.new :parent => @category
      render 'edit'
    end
  end
  
  def destroy
    @category = ShopCategory.find_by_id params[:id]
    @category.destroy
    flash[:notice] = 'category deleted'
    redirect_to :action => :edit, :id => @category.parent_id
  end
  
  protected
  
  def load_category
    if params[:id].blank?
      @category = nil
    else
      @category = ShopCategory.find_by_id params[:id]
    end
    load_category_context
  end
  
  def load_category_context
    if @category.nil?
      @path = []
      @child_categories = ShopCategory.roots
    else
      @path = @category.ancestors.reverse << @category
      @child_categories = @category.children
    end
  end
  
end

