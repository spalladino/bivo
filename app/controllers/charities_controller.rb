class CharitiesController < ApplicationController

  before_filter :authenticate_user!, :except => [:show, :details, :index, :check_url, :destroy]
  before_filter :user_required, :only => [:follow, :unfollow]
  before_filter :load_charity, :except => [:index, :new, :create, :check_url,:destroy, :show, :details]
  before_filter :load_charity_with_data, :only => [:show, :details]
  before_filter :only_owner_or_admin_if_inactive, :only => [:details, :follow]
  before_filter :only_admin, :only => [:activate, :deactivate, :create,:delete,:destroy]
  before_filter :follows_exist, :only => [:unfollow]

  def index
    @charities = Charity.exclude_inactive.with_cause_data
    @categories = CharityCategory.sorted_by_charities_count

    def apply_filters(only_charities=false, &block)
      @charities = block.call(@charities)
      @categories = block.call(@categories) unless only_charities
    end

    # Filter by region
    @region = params[:region]
    apply_filters {|c| c.where("#{Charity.table_name}.country_id = ?", @region.to_i)} unless @region.blank?

    # Filter by name
    @name = params[:name]
    apply_filters do |c|
      c.where("#{Charity.table_name}.charity_name ~* ? OR #{Charity.table_name}.description ~* ?", @name, @name)
    end unless @name.blank?

    # Set categories to show
    all_categ = all_category(@charities.count.size)
    @categories = @categories.first(6).to_a.insert(0, all_categ)

    # Filter by category
    @category = params[:category]
    apply_filters(true) do |c|
      c.where("#{Charity.table_name}.charity_category_id = ?", @category.to_i)
    end unless @category.blank?

    # Sorting
    @sorting = (params[:sorting] || :alphabetically).to_sym
    @charities = @charities.order case @sorting
      when :votes         then "votes_count DESC"
      when :funds_raised  then "total_funds_raised DESC"
      when :rating        then "#{Charity.table_name}.rating DESC"
      when :geographical  then "country_name ASC, #{Charity.table_name}.city ASC"
                          else "#{Charity.table_name}.charity_name ASC, #{Charity.table_name}.description ASC"
    end

    # Set pagination
    @per_page = (params[:per_page] || 10).to_i
    @charities = @charities.first(50).paginate(:per_page => @per_page, :page => params[:page])

    # Fill filters fields
    @regions = Country.all
    @page_sizes = [5,10,20,50]
    @sortings = [
      [_('alphabetically'), :alphabetical],
      [_('geographically'), :geographical],
      [_('rating'),         :rating      ],
      [_('funds raised'),   :funds_raised],
    ]

  end

  def check_url
    charity = Charity.new
    charity.short_url = params[:url]

    if (Charity.find_by_short_url(params[:url]))
      render :text => _('not_available')
    else
      if (charity.valid? || charity.errors[:short_url].empty?)
        render :text => _('available')
      else
        render :text => _('invalid')
      end
    end
  end

  def show
    render 'details'
  end

  def details
  end

  def activate
    @charity.status = :active
    if @charity.save then
      ajax_flash[:notice] = _("Activated")
    else
      ajax_flash[:notice] = append_errors(_("Error activating charity"), @charity)
      @charity.reload
    end
    redirect_to request.referer unless request.xhr?
  end

  def deactivate
    @charity.status = :inactive

    if @charity.save then
      ajax_flash[:notice] = _("Deactivated")
    else
      ajax_flash[:notice] = append_errors(_("Error deactivating charity"), @charity)
      @charity.reload
    end
    redirect_to request.referer unless request.xhr?
  end

  def follow
    @follow = CharityFollow.new :charity_id => params[:id],:user_id=> current_user.id
    ajax_flash[:notice] = if @follow.save then _("Follow submitted") else _("Error, try again") end

    redirect_to request.referer unless request.xhr?
  end

  def destroy
    @charity.destroy
    if @charity.destroyed?
      redirect_to root_url
    else
      redirect_to request.referer
    end
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


  def manage_comments

  end


 protected

  def load_charity
    @charity = Charity.find(params[:id]) if params[:id]
    @charity = Charity.find_by_short_url(params[:url]) if params[:url]
  end

  def load_charity_with_data
    @charity = Charity.with_cause_data.find(params[:id]) if params[:id]
    @charity = Charity.with_cause_data.find_by_short_url(params[:url]) if params[:url]
  end


   def all_category(count)
    c = CharityCategory.new :name => _("All")
    c.class_eval { attr_accessor :charities_count }
    c.charities_count = count
    return c
  end

  def follows_exist
    @follow = CharityFollow.find_by_charity_id_and_user_id(params[:id], current_user.id)
    if not @follow
      render :nothing => true, :status => :method_not_allowed
    end
  end

  def only_owner_or_admin_if_inactive
    if @charity.status_inactive? && (!current_user || (!(@charity.id == current_user.id) && !current_user.is_admin_user))
      @kind = _('charity')
      @name = @charity.name
      render('shared/inactive')
    end
  end

  def user_required
    render :nothing => true, :status => :forbidden unless current_user
  end
end

