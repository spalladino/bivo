class ShopsController < ApplicationController

  before_filter :authenticate_user!, :except => [:details,:home,:show]
  before_filter :only_admin, :only => [:new, :create, :edit, :update, :activate, :deactivate]
  before_filter :load_shop, :except => [ :details, :new, :create, :home]
  before_filter :load_places, :only => [ :new, :edit, :create, :update ]

  def details
    @shop = Shop.find_by_short_url! params[:short_url]
  end

  def new
    @shop = Shop.new
  end

  def edit
  end

  def create
    @shop = Shop.new
    if save_shop
      flash[:notice] = _("Shop successfully created")
      redirect_to root_url
    else
      render :new
    end
  end

  def update
    if save_shop
      flash[:notice] = _("Shop successfully updated")
      redirect_to root_url
    else
      render :edit
    end
  end

  def home
    @shop = Shop.find_by_short_url! params[:short_url]
  end

  def show
    render 'details'
  end

  def activate
    @shop.status = :active
    if @shop.save then
      ajax_flash[:notice] = _("Activated")
    else
      ajax_flash[:error] = _("Error activating shop")
    end
    redirect_to request.referer unless request.xhr?
  end

  def deactivate
    @shop.status = :inactive
    if @shop.save then
      ajax_flash[:notice] = _("Deactivated")
    else
      ajax_flash[:error] = _("Error deactivating shop")
    end
    redirect_to request.referer unless request.xhr?
  end
  
  def destroy
    #TODO: Check when a shop can be safely destroyed
    if @shop.destroy.destroyed? then
      flash[:notice] = _("Shop has been deleted")
      redirect_to root_url
    else
      flash[:error] = _("Shop could not be deleted")
      redirect_to request.referer
    end
  end

private

  def load_places
    @countries = Country.all
  end

  def save_shop
    params[:shop] ||= {}
    params[:shop][:country_ids] ||= []
    @shop.attributes= params[:shop]
    @shop.save
  end

  def load_shop
    @shop = Shop.find params[:id]
  end

end

