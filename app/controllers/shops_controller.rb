class ShopsController < ApplicationController

  def details
    @shop = Shop.find_by_short_url! params[:short_url]
  end


  def activate
    @shop.status = :active
    @shop.save
    if @shop.save then
      ajax_flash[:notice] = _("Activated")
    else
      ajax_flash[:notice] = _("Error activating shop")
    end
    redirect_to request.referer unless request.xhr?
  end

  def deactivate
    @shop.status = :inactive
    @shop.save
    if @shop.save then
      ajax_flash[:notice] = _("Deactivated")
    else
      ajax_flash[:notice] = _("Error deactivating shop")
    end
    redirect_to request.referer unless request.xhr?
  end

end

