class CharitiesController < ApplicationController

  before_filter :authenticate_user!, :except => [ :show, :details, :index ]
  before_filter :load_charity, :except => [ :details, :index, :new, :create ]

  before_filter :only_owner_or_admin, :only => [ :edit, :update]
  before_filter :only_admin, :only => [:activate, :deactivate, :mark_paid, :mark_unpaid, :create,:delete]


  def index
    @charities = Charity.all
  end

  def show
    render 'details'
  end

  def details
   @charity = Charity.find_by_short_url! params[:url]
  end

  def activate
    @charity.status = :active
    @charity.save
    if @charity.save then
      ajax_flash[:notice] = "Activated"
    else
      ajax_flash[:notice] = "Error activating cause"
    end
    redirect_to request.referer unless request.xhr?
  end

  def deactivate
    @charity.status = :inactive
    @charity.causes.each do |cause|
      cause.status = :inactive
      cause.save
    end

    @charity.save
    if @charity.save then
      ajax_flash[:notice] = "Deactivated"
    else
      ajax_flash[:notice] = "Error deactivating cause"
    end
    redirect_to request.referer unless request.xhr?
  end


  def new
    @countries = Country.all
    @charity = Charity.new
  end

  def edit
    @charity = Charity.find(params[:id])
  end

  def create
    @charity = Charity.new(params[:charity])

    if @charity.save
      render :text => "exito"
      #redirect_to @charity, :notice => 'Charity was successfully created.'
    else
      render :text => @charity.errors.to_s
      #render :action => "new"
    end
  end

  def update
    @charity = Charity.find(params[:id])

    if @charity.update_attributes(params[:charity])
      redirect_to @charity, :notice => 'Charity was successfully updated.'
    else
      render :action => "edit"
    end
  end


  def follow
    @follow = CharityFollow.new :charity_id => params[:id],:user_id=> current_user.id
    if @follow.save
      ajax_flash[:notice] = "Follow submitted"
    else
      ajax_flash[:notice] = "Error, try again"
    end

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

  def destroy
    @charity = Charity.find(params[:id])
    @charity.destroy

    redirect_to charities_url
  end


  def load_charity
    @charity = Charity.find(params[:id])
  end


  def only_owner_or_admin
    if not (@charity.id == current_user.id || current_user.is_admin_user)
      render :nothing => true, :status => :forbidden
    end
  end

  def only_admin
    if not current_user.is_admin_user
      render :nothing => true, :status => :forbidden
    end
  end


end

