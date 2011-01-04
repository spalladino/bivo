class CausesController < ApplicationController

  before_filter :authenticate_user!, :except => [ :show, :details, :index ]
  before_filter :load_cause, :except => [ :index, :new, :check_url, :create ]

  before_filter :inactive_in_list_only_admin, :only => [:index]
  before_filter :only_owner_or_admin_if_inactive, :only => [:details]
  before_filter :only_owner_or_admin, :only => [:delete, :edit, :update]
  before_filter :only_admin_or_charity, :only => [:create]
  before_filter :only_admin, :only => [:activate, :deactivate, :mark_paid, :mark_unpaid ]

  before_filter :status_allow_edit , :only => [:edit, :update]
  before_filter :status_allow_delete, :only => [:delete]
  before_filter :follows_exist, :only => [:unfollow]

  before_filter :set_section, :only => [:show, :details, :index, :vote]

  def show
    render 'details'
  end

  def details
  end

  def index
    @causes = Cause.includes(:country).includes(:charity)
    @categories = CauseCategory.sorted_by_causes_count

    def apply_filters(&block)
      @causes = block.call(@causes)
      @categories = block.call(@categories)
    end

    # Handle sorting options
    @sorting = (params[:sorting] || :alphabetically).to_sym
    @causes = @causes.order case @sorting
      when :votes then 'votes_count DESC'
      when :funds_raised then 'funds_raised DESC'
      when :funds_needed then 'funds_needed DESC'
      when :completion then 'funds_raised / funds_needed DESC'
      when :rating then 'users.rating DESC'
      when :geographical then 'countries.name ASC, causes.city ASC'
      else 'name ASC, description ASC'
    end

    # Filter by region
    @region = params[:region]
    apply_filters { |c| c.where('causes.country_id = ?', params[:region].to_i) } unless @region.blank?

    # Filter by status
    @status = params[:status] || :active
    apply_filters do |c|
      if @status != :completed
        c.where('causes.status = ?', @status)
      else
        c.where('causes.status = ? OR causes.status = ?', :completed, :paid)
      end
    end

    # Filter by text
    @name = params[:name]
    apply_filters { |c| c.where('causes.name ~* ? OR causes.description ~* ?', @name, @name) } unless @name.blank?

    # Count for all causes
    all_causes_count = @causes.size

    # Filter by category
    @category = params[:category]
    @causes = @causes.where('causes.cause_category_id = ?', @category.to_i) unless @category.blank?

    # Set pagination
    @per_page = (params[:per_page] || 5).to_i
    if !current_user || !current_user.is_admin_user
      @causes = @causes.first(50) if @status == :active
    end
    @causes = @causes.paginate(:per_page => @per_page, :page => params[:page])

    # Fill filters fields
    @regions = Country.all
    if !current_user || !current_user.is_admin_user
      @statuses = [:active, :raising_funds, :completed]
    else
      @statuses = [:active, :raising_funds, :completed, :inactive]
    end
    @categories = @categories.first(6).to_a.insert(0, all_category(all_causes_count))
    @page_sizes = [5,10,20,50]
    @sortings = causes_list_sortings_for(@status)
  end


  def vote
    @vote = Vote.new :cause_id => params[:id], :user_id=> current_user.id
    ajax_flash[:notice] = @vote.save ? _("Vote submitted") : @vote.errors[:cause_id]

    if request.xhr?
      @small = params[:small] || false
      @votes_count = Cause.find(params[:id]).votes_count
    else
      redirect_to request.referer
    end
  end

  def follow
    @follow = Follow.new :cause_id => params[:id],:user_id=> current_user.id
    if @follow.save
      ajax_flash[:notice] = _("Follow submitted")
    else
      ajax_flash[:notice] = _("Error, try again")
    end
    redirect_to request.referer unless request.xhr?
  end

  def unfollow
    @follow.destroy
    if @follow.destroyed?
      ajax_flash[:notice] = _("Unfollow submitted")
    else
      ajax_flash[:notice] = _("Error, try again")
    end
    redirect_to request.referer unless request.xhr?
  end


  def new
    @cause = Cause.new :charity_id => params[:charity_id]
  end

  def edit
    @partial_cause_edit = @cause.can_edit_sensitive_data?(current_user) ? 'form_sensitive_edit' : 'form_sensitive_readonly'
  end

  def create
    @cause = Cause.new params[:cause]
    @cause.funds_raised = 0
    # charity is protected so we need to assign it manually
    # depending if the user is admin or not, obey the charity_id param
    if !current_user.is_admin_user
      @cause.charity_id = current_user.id
    else
      @cause.charity_id = params[:cause][:charity_id]
    end
    if !@cause.save
      render 'new'
    else
      redirect_to :action => :details, :url => @cause.url
    end
  end

  def update
    if !@cause.can_edit_sensitive_data?(current_user)
      params[:cause].delete :name
      params[:cause].delete :url
      params[:cause].delete :funds_needed
    end
    @cause.attributes = params[:cause]
    if !@cause.save
      redirect_to request.referer
    else
      redirect_to :action => :details, :url => @cause.url
    end
  end

  def destroy
    @cause.destroy
    if @cause.destroyed?
      redirect_to root_url
    else
      redirect_to request.referer
    end
  end

  def check_url
    cause = Cause.new
    cause.url = params[:url]

    if (Cause.find_by_url(params[:url]))
      render :text => _('not_available')
    else
      if (cause.valid? || cause.errors[:url].empty?)
        render :text => _('available')
      else
        render :text => _('invalid')
      end
    end
  end

  def activate
    @cause.status = :active
    if @cause.save then
      ajax_flash[:notice] = _("Activated")
    else
      ajax_flash[:notice] = append_errors(_("Error activating cause"), @cause)
      @cause.reload
    end
    redirect_to request.referer unless request.xhr?
  end

  def deactivate
    @cause.status = :inactive
    if @cause.save then
      ajax_flash[:notice] = _("Deactivated")
    else
      ajax_flash[:notice] = append_errors(_("Error deactivating cause"), @cause)
      @cause.reload
    end
    redirect_to request.referer unless request.xhr?
  end

  def mark_paid
    @cause.status = :paid
    if @cause.save then
      ajax_flash[:notice] = _("Marked as Paid")
    else
      ajax_flash[:notice] = _("Error marking as UnPaid cause")
    end
    redirect_to request.referer unless request.xhr?
  end

  def mark_unpaid
    @cause.status = :completed
    if @cause.save then
      ajax_flash[:notice] = _("Marked as UnPaid")
    else
      ajax_flash[:notice] = _("Error marking as UnPaid cause")
    end
    redirect_to request.referer unless request.xhr?
  end

  private

  def load_cause
    @cause = (Cause.find params[:id]) if params[:id]
    @cause = (Cause.find_by_url! params[:url]) if params[:url]
  end

  def all_category(count)
    c = CauseCategory.new :name => _("All")
    c.class_eval { attr_accessor :causes_count }
    c.causes_count = count
    return c
  end

  def only_owner_or_admin
    if not (@cause.charity.id == current_user.id || current_user.is_admin_user)
      ajax_flash[:notice] = _("Only admin")
      render :nothing => true, :status => :forbidden
    end
  end

  def only_admin_or_charity
    unless (current_user.can_add_causes?)
      ajax_flash[:notice] = _("Only admin or charity")
      render :nothing => true, :status => :forbidden
    end
  end

  def status_allow_edit
    if !@cause.can_edit? && (current_user && !current_user.is_admin_user)
      ajax_flash[:notice] = _("Status doesnt allow edit")
      render :nothing => true, :status => :forbidden
    end
  end

  def status_allow_delete
    if !current_user.is_admin_user && !@cause.can_delete?
       ajax_flash[:notice] = _("Status doesnt allow delete")
       render :nothing => true, :status => :forbidden
    end
  end


  def follows_exist
    @follow = Follow.find_by_cause_id_and_user_id(params[:id], current_user.id)
    if not @follow
      ajax_flash[:notice] = _("Follow already exists")
      render :nothing => true, :status => :method_not_allowed
    end
  end

  def causes_list_sortings_for(status)
    sortings = [
      [_('alphabetically'), :alphabetical],
      [_('geographically'), :geographical],
      [_('charity rating'), :rating],
      [_('funds needed'),   :funds_needed]
    ]

    case status
      when :active then
        sortings << [_('popularity'), :votes]
      when :raising_funds then
        sortings << [_('funds raised'), :funds_raised] << [_('% of completion'), :completion]
      when :completed then
        sortings << [_('funds raised'), :funds_raised]
    end

    return sortings

  end

  def only_owner_or_admin_if_inactive
    if @cause.status_inactive? && (!current_user || (!(@cause.charity_id == current_user.id) && !current_user.is_admin_user))
      @kind = _('cause')
      @name = @cause.name
      render('shared/inactive')
    end
  end

  def inactive_in_list_only_admin
    if params[:status] == :inactive && (!current_user || !current_user.is_admin_user)
      render :nothing => true, :status => :forbidden
    end
  end

  def set_section
    @section = :vote_causes
  end
end

