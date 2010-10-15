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
    @categories = CauseCategory.sorted_by_cause_count

    # Filter by region
    if not params[:region].blank?
      @causes = @causes.where('country_id = ?', params[:region].to_i)
      @categories = @categories.where('causes.country_id = ?', params[:region].to_i)
    end

    # Filter by status
    status = params[:status] || :active
    @causes = @causes.where('status = ?', status)
    @categories = @categories.where('causes.status = ?', status)

    # Filter by category
    if not params[:category].blank?
      @causes = @causes.where('category_id = ?', params[:category].to_i)
    end

    # Cap maximum to show to 50
    causes_real_count = @causes.size 
    @causes = @causes[0...50]

    # Set pagination
    @causes = @causes.paginate(:per_page => params[:per_page] || 20, :page => params[:page])

    # Fill filters fields
    @regions = Country.all
    @region = params[:region]

    @statuses = Cause.enumerated_attributes[:status]
    @status = status
    
    @categories = @categories[0...6].insert(0, all_category(causes_real_count))
    @category = params[:category]
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
    @cause = Cause.find_by_id(params[:id])
  end

  def create
    @cause = Cause.new params[:cause]
    @cause.funds_raised = 0
    @cause.charity_id = current_user.id
    if !@cause.save
      render 'new'
    else
      redirect_to root_url
    end
  end
  
  def update
    @cause = Cause.find_by_id(params[:id])
    @cause.attributes = params[:cause]
    if !@cause.save
      render 'edit'
    else
      redirect_to root_url
    end
  end

  private
  
  def all_category(count)
    c = CauseCategory.new :name => _("All")
    c.class_eval { attr_accessor :cause_count }
    c.cause_count = count
    return c
  end

end

