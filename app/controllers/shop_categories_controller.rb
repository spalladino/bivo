class ShopCategoriesController < ApplicationController
  before_filter :only_admin

  def edit
    if params[:id].blank?
      @category = nil
      @path = []
      @child_categories = ShopCategory.roots
    else
      @category = ShopCategory.find_by_id params[:id]
      @path = @category.ancestors.reverse << @category
      @child_categories = @category.children
    end

    @newcategory = ShopCategory.new :parent => @category
  end

  def create
    @newcategory = ShopCategory.new params[:newcategory]
    @newcategory.save!

    redirect_to :action => :edit, :id => params[:newcategory][:parent_id]
  end
end

