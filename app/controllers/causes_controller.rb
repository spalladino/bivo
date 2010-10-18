class CausesController < ApplicationController
  include CausesPresenters

  before_filter :authenticate_user!, :except => [ :details, :index ]

  before_filter :load_cause, :except => [:details, :index, :new, :checkUrl, :create]
  

  def details
    @cause = Cause.find_by_url(params[:url])
    set_vote_btn_variables @cause #VOTE
    set_follow_btn_variables @cause #FOLLOW
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
    @vote = Vote.new(:cause_id => params[:id],:user_id=> current_user.id)
    if @vote.save
      flash[:notice] = "Vote submitted"
      redirect_to request.referer unless request.xhr? #Not Ajax
    else
      flash[:notice] = @vote.errors.on(:cause_id)
      redirect_to request.referer unless request.xhr? #Not Ajax
    end
    set_vote_btn_variables @cause
  end

  def follow
    @follow = Follow.new(:cause_id => params[:id],:user_id=> current_user.id)
    if @follow.save
      flash[:notice] = "Follow submitted"
      if not request.xhr? #Not Ajax?
        redirect_to request.referer
      end
    else
      flash[:notice] = "Error, try again"
      if not request.xhr?
        redirect_to request.referer
      end
    end
    set_follow_btn_variables @cause
  end

  def unfollow
    follow = Follow.find_by_cause_id_and_user_id(params[:id], current_user.id)
    follow.destroy
    if follow.destroyed?
      flash[:notice] = "Unfollow submitted"
      if not request.xhr? #Not Ajax?
        redirect_to request.referer
      end
    else
      flash[:notice] = "Error, try again"
      if !request.xhr?
        redirect_to request.referer
      end
    end

    set_follow_btn_variables @cause
  end


  def new
    @cause = Cause.new
  end

  def edit
    @cause = Cause.find(params[:id])
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
    @cause = Cause.find(params[:id])
    @cause.attributes = params[:cause]
    if !@cause.save
      render 'edit'
    else
      redirect_to root_url
    end
  end

  def delete
    # TODO: chequeo para ver si se puede borrar en base al estado, y si el user es admin
    # (si se hace borrado logico, se borra permanentemente o no se puede borrar)
    @cause = Cause.find(params[:id])
    @cause.destroy
    if @cause.destroyed?
      redirect_to root_url
    else
      render 'edit'
    end
  end

  def checkUrl
    @cause = Cause.find_by_url(params[:shortUrl])
    @result = 'available'
    if @cause
      @result = 'not_available'
    end
    render :text => @result
  end

  def activate
    @cause = Cause.find(params[:id])
    @cause.status = :active
    @cause.save
    render 'edit'
  end

  def deactivate
    @cause = Cause.find(params[:id])
    @cause.status = :inactive
    @cause.save
    render 'edit'
  end
  
  def mark_paid
    @cause = Cause.find(params[:id])
    @cause.status = :paid
    @cause.save
    render 'edit'
  end

  private
  
  def load_cause
    @cause = Cause.find params[:id]
  end

  def set_vote_btn_variables(cause)
    @vote_presenter = VoteButtonPresenter.new(cause, current_user)
  end

  def set_follow_btn_variables(cause)
    @follow_presenter = FollowButtonPresenter.new(cause, current_user)
  end
  
  def all_category(count)
    c = CauseCategory.new :name => _("All")
    c.class_eval { attr_accessor :cause_count }
    c.cause_count = count
    return c
  end

end

