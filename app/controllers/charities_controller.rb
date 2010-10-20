class CharitiesController < ApplicationController
  def index
    @charities = Charity.all
  end

  def check_url
    if Charity.find_by_short_url(params[:url])
      render :text => 'not_available'
    else
      render :text => 'available'
    end
  end
end

