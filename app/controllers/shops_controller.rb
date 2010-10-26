class ShopsController < ApplicationController

  def details
    @shop = Shop.find_by_short_url! params[:short_url]
  end



end

