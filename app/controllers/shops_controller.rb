class ShopsController < ApplicationController

  before_filter :authenticate_user!, :except => [:details]
  before_filter :only_admin, :only => [:new, :create, :edit, :update, :activate, :deactivate]
  before_filter :load_shop, :except => [ :details, :new, :create]

  def details
    @shop = Shop.find_by_short_url! params[:short_url]
  end

  def new
    @shop = Shop.new
  end
  
  def edit
  end
  
  def create
    @shop = Shop.new params[:shop]
    if @shop.save
      flash[:notice] = _("Shop successfully created")
      redirect_to root_url
    else
      render :new
    end
  end
  
  def update
    @shop.attributes= params[:shop]
    if @shop.save
      flash[:notice] = _("Shop successfully updated")
      redirect_to root_url
    else
      render :edit
    end
  end

  def activate
    @shop.status = :active
    if @shop.save then
      ajax_flash[:notice] = _("Activated")
    else
      ajax_flash[:notice] = _("Error activating shop")
    end
    redirect_to request.referer unless request.xhr?
  end

  def deactivate
    @shop.status = :inactive
    if @shop.save then
      ajax_flash[:notice] = _("Deactivated")
    else
      ajax_flash[:notice] = _("Error deactivating shop")
    end
    redirect_to request.referer unless request.xhr?
  end

private

  def load_shop
    @shop = Shop.find params[:id]
  end

end

