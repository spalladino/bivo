class CausesController < ApplicationController

  before_filter :authenticate_user!, :except => [ :details, :index ]

  def details
    @cause = Cause.find_by_url(params[:url])

    #VOTES:
    @voting_allowed = true
    @voting_error = "Can Vote"
    if !current_user
      @voting_allowed = false
      @voting_error = "Unknown user"
    else
      vote = Vote.new(:cause_id => @cause.id ,:user_id=> current_user.id)
      if !vote.valid?
        @voting_allowed = false
        @voting_error = vote.errors.on(:cause_id)
      end
    end

    #FOLLOWS:
    @follow_allowed = true
    @follow_error = "Can follow"
    if !current_user
      @follow_allowed = false
      @follow_error = "Unknown user"
    else
      follow = Follow.new(:cause_id => @cause.id ,:user_id=> current_user.id)
      if !follow.valid?
        @follow_allowed = false
        @follow_error = follow.errors.on(:cause_id)
      end
    end

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

    @vote = Vote.new(:cause_id => params[:cause_id],:user_id=> current_user.id)
    if @vote.save
      custom_response "Ok",true
    else
      custom_response @vote.errors.on(:cause_id) ,false
    end
  end

  def follow
    @cause = Cause.find_by_id(params[:cause_id])

    @follow = Follow.new(:cause_id => params[:cause_id],:user_id=> current_user.id)
    if @follow.save
      custom_response "Ok",true
    else
      custom_response @follow.errors.on(:cause_id) ,false
    end
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
    if !(Cause.new params[:cause]).save
      render 'new'
    else
      redirect_to root_url
    end
  end

end

