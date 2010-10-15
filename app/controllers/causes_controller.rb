class CausesController < ApplicationController

  before_filter :authenticate_user!, :except => [ :details, :index ]

  def details

    @cause = Cause.find_by_url(params[:url])
    set_vote_btn_variables @cause #VOTE
    set_follow_btn_variables @cause #FOLLOW

  end

  def index
    @causes = Cause.order('votes_count DESC').includes(:country).includes(:charity)

    # Filter by region
    if not params[:region].blank?
      @causes = @causes.where('country_id = ?', params[:region].to_i)
    end

    # Filter by status
    status = params[:status] || :active
    @causes = @causes.where('status = ?', status)

    # Filter by category
    if not params[:category].blank?
      @causes = @causes.where('category_id = ?', params[:category].to_i)
    end

    # Cap maximum to show to 50
    @causes = @causes[0...50]

    # Set pagination
    @causes = @causes.paginate(:per_page => params[:per_page] || 20, :page => params[:page])

    # Fill filters fields
    if not request.xhr?
      @regions = Country.all
      @region = params[:region]

      @statuses = Cause.enumerated_attributes[:status]
      @status = status

      @categories = CauseCategory.sorted_by_cause_count[0...6]
      @category = params[:category]
    end
  end


  def vote
    @cause = Cause.find_by_id(params[:cause_id])
    @vote = Vote.new(:cause_id => params[:cause_id],:user_id=> current_user.id)
    if @vote.save
      flash[:notice] = "Vote submitted"
      if not request.xhr? #Not Ajax?
        redirect_to request.referer
      end
    else
      flash[:notice] = @vote.errors.on(:cause_id)
      if !request.xhr?
        redirect_to request.referer
      end
    end
    set_vote_btn_variables @cause
  end

  def follow
    @cause = Cause.find_by_id(params[:cause_id])

    @follow = Follow.new(:cause_id => params[:cause_id],:user_id=> current_user.id)
    if @follow.save
      flash[:notice] = "Follow submitted"
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

  def unfollow
    @cause = Cause.find_by_id(params[:cause_id])
    follow = Follow.find_by_cause_id_and_user_id(params[:cause_id],current_user.id)
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

  def delete
    @cause = Cause.find_by_id(params[:id])
    @cause.destroy
    if @cause.destroyed?
      redirect_to root_url
    end
  end

  def set_vote_btn_variables(cause)
    if !current_user
      @vote_label = "Vote (you must login first)"
      @vote_disabled = false
      @vote_visible = true
    else
      vote = Vote.new(:cause_id => cause.id ,:user_id=> current_user.id)
      if vote.valid?
        @vote_label = "Vote"
        @vote_disabled = false
        @vote_visible = true
      else
        error = vote.errors.on(:cause_id)
        @vote_label = error
        @vote_errors = error
        @vote_disabled = true
        if vote.already_exists
          @vote_visible = true
        else
          @vote_visible = false
        end

      end
    end
  end




  def set_follow_btn_variables(cause)
    if !current_user
      @follow_label = "Follow (you must login first)"
      @follow_route = 'follow'
    else
      follow = Follow.find_by_cause_id_and_user_id(cause.id,current_user.id)
      @follow_label = if follow then "Unfollow" else "Follow" end
      @follow_route = if follow then 'unfollow' else 'follow' end
    end

  end





end

