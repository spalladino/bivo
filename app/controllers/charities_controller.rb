class CharitiesController < ApplicationController

  before_filter :authenticate_user!, :except => [ :show, :details, :index ]
  before_filter :load_charity, :except => [ :details, :index, :new, :create ]

  before_filter :only_owner_or_admin, :only => [ :edit, :update]
  before_filter :only_admin, :only => [:activate, :deactivate, :mark_paid, :mark_unpaid, :create,:delete]


  def index
    @charities = Charity.all
  end

  def check_url
    if Charity.find_by_short_url(params[:url])
      render :text => 'not_available'
    end
  end

  def show
    render 'details'
  end

  def details
    @charity = Charity.find_by_short_url! params[:url]
  end

  def activate
    @charity.status = :active
    ajax_flash[:notice] = if @charity.save then "Activated" else "Error activating cause" end 
    redirect_to request.referer unless request.xhr?
  end

  def deactivate
    @charity.status = :inactive
    
    # TODO: Use cascade update so charity save fails if any cause save fails as well
    @charity.causes.each do |cause|
      cause.status = :inactive
      cause.save
    end
    
    ajax_flash[:notice] = if @charity.save then "Deactivated" else "Error deactivating cause" end  
    redirect_to request.referer unless request.xhr?
  end

  def follow
    @follow = CharityFollow.new :charity_id => params[:id],:user_id=> current_user.id
    ajax_flash[:notice] = if @follow.save then "Follow submitted" else "Error, try again" end 

    redirect_to request.referer unless request.xhr?
  end


  def unfollow
    follow = CharityFollow.find_by_charity_id_and_user_id(params[:id], current_user.id)
    follow.destroy
    if follow.destroyed?
      ajax_flash[:notice] = "Unfollow submitted"
    else
      ajax_flash[:notice] = "Error, try again"
    end

    redirect_to request.referer unless request.xhr?
  end


 protected

  def load_charity
    @charity = Charity.find(params[:id])
  end

  def only_owner_or_admin
    if not (@charity.id == current_user.id || current_user.is_admin_user)
      render :nothing => true, :status => :forbidden
    end
  end


end

