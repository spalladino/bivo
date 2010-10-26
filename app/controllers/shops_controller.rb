class ShopsController < ApplicationController

  before_filter :only_admin, :only => [:new, :create, :edit, :update]

  def details
    @shop = Shop.find_by_short_url! params[:short_url]
  end

  def new
  end
  
  def edit
  end
  
  def create
  end
  
  def update
  end

  

end

