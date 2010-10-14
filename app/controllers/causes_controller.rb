class CausesController < ApplicationController

  before_filter :authenticate_user!, :except => [ :details, :index ]

  def details
    @cause = Cause.find_by_url(params[:url])
  end

  def index
    @causes = Cause.order('votes_count DESC').includes(:country).includes(:charity)
    
    # Filter by region
    if not params[:filter_region].blank?
      @causes = @causes.where('country_id = ?', params[:filter_region].to_i)
    end
    
    # Filter by status
    filter_status = params[:filter_status] || :active
    @causes = @causes.where('status = ?', filter_status)
    
    # Categories
    @filter_categories = []#CauseCategory.find(:all, :select => 'count(*) as count, cause_category')
    
    # Set pagination
    @causes = @causes.paginate(:per_page => params[:per_page] || 20, :page => params[:page])
    
    # Fill filters fields
    if not request.xhr?
      @regions = Country.all
      @filter_region = params[:filter_region]
      
      @statuses = Cause.enumerated_attributes[:status]
      @filter_status = filter_status
    
    end
  end

  def vote
    @cause = Cause.find_by_id(params[:cause_id])
    @vote = Vote.new(params[:cause_id])
    if @vote.save
      custom_response "Ok",true
    else
      custom_response @vote.errors.on(:user_id) ,false
    end
  end 
  
  def follow
    redirect_to request.referer
  end

  def custom_response(message,success)
    if request.xhr?
      #AJAX
      flash[:notice] = message
      @message =  message
      @success = success
    else
      #NO AJAX
      flash[:notice] = message
      redirect_to request.referer
    end

  end


  def new
    @cause = Cause.new
  end

  def edit
    @cause = Cause.new
  end
  
  def create
    @cause = Cause.new params[:cause]
    if !@cause.save
      render 'new'
    else
      redirect_to root_url
    end
  end

end

