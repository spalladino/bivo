class ShopsController < ApplicationController

  before_filter :authenticate_user!, :except => [:details,:home,:show,:search]
  before_filter :only_admin, :only => [:new, :create, :edit, :update, :destroy,:activate, :deactivate, :edit_categories]
  before_filter :load_shop, :except => [  :new, :create, :index, :search, :edit_categories]
  before_filter :load_places, :only => [ :new, :edit, :create, :update ]
  before_filter :load_categories, :only => [ :new, :edit, :create, :update, :edit_categories, :index ]
  before_filter :valid_transition, :only => [:activate,:deactivate]
  before_filter :only_admin_if_inactive_or_deleted, :only => [:home,:details]

  def details
  end

  def home
    if @shop.redirection == :custom_html
      redirect_to @shop.affiliate_code
    end
  end

  def new
    @shop = Shop.new
  end

  def edit
  end

  def index
    @is_shop_list = true
    if params[:category_field]
      @category = ShopCategory.find(params[:category_field])
      @shops = @category.shops unless admin_is_logged_in
      @shops = @category.shops.all_with_inactive if admin_is_logged_in
      @path = @category.ancestors
    else
      @shops = Shop.all unless admin_is_logged_in
      @shops = Shop.all_with_inactive if admin_is_logged_in
    end
    # Set pagination
    @per_page = (params[:per_page] || 20).to_i
    @count = Shop.where('shops.status != ?',:inactive).count unless admin_is_logged_in
    @count = Shop.count if admin_is_logged_in

    @shops = @shops.paginate(:per_page => @per_page, :page => params[:page])
    @page_sizes = [5,10,20,50]

  end

   def search
    # Filter by text
    @search_word = params[:search_word]
    if @search_word.blank?
      @shops = Shop.includes(:countries) unless admin_is_logged_in
      @shops = Shop.all_with_inactive.includes(:countries)if admin_is_logged_in
    else
      @shops = Shop.all_with_inactive.includes(:countries).search(@search_word.gsub(/\\/, '\&\&').gsub(/'/, "''")) if admin_is_logged_in
      @shops = Shop.includes(:countries).search(@search_word.gsub(/\\/, '\&\&').gsub(/'/, "''")) unless admin_is_logged_in
    end

    # Handle sorting options
    @sorting = (params[:sorting] || :alphabetically).to_sym
    if @sorting == :proximity && !current_user.country_id.nil?
      @shops = @shops.where("exists (select * from country_shops where country_id = ? and shop_id = Shops.id)",current_user.country_id) + @shops.where("not exists (select * from country_shops where country_id = ? and shop_id = Shops.id)",current_user.country_id)
    else
      @shops = @shops.order 'name ASC, description ASC'
    end

    # Set pagination
    @per_page = (params[:per_page] || 20).to_i
    @shops = @shops.paginate(:per_page => @per_page, :page => params[:page])
    @page_sizes = [5,10,20,50]

    @count = @shops.count
    @sortings = [
      [_('alphabetically'), :alphabetical],
      [_('proximity'), :proximity],
    ]
  end


  def create
    @shop = Shop.new
    if save_shop
      flash[:notice] = _("Shop successfully created")
      redirect_to root_url
    else
      render :new
    end
  end

  def update
    if save_shop
      flash[:notice] = _("Shop successfully updated")
      redirect_to shop_details_path @shop.short_url
    else
      render :edit
    end
  end


  def show
    render 'details'
  end

  def activate
    @shop.status = :active
    if @shop.save then
      ajax_flash[:notice] = _("Activated")
    else
      ajax_flash[:error] = _("Error activating shop")
    end
    redirect_to request.referer unless request.xhr?
  end

  def deactivate
    @shop.status = :inactive
    if @shop.save then
      ajax_flash[:notice] = _("Deactivated")
    else
      ajax_flash[:error] = _("Error deactivating shop")
    end

    redirect_to request.referer unless request.xhr?
  end

  def destroy
    #TODO: Check when a shop can be safely destroyed
    @shop.destroy
    if @shop.destroyed? then
      flash[:notice] = _("Shop has been deleted")
      redirect_to root_url
    else
      flash[:error] = _("Shop could not be deleted")
      redirect_to request.referer
    end
  end

  def edit_categories
    @shop = Shop.new
    render :partial => 'select_categories'
  end

private

  def load_places
    @countries = Country.all
  end

  def save_shop
    params[:shop] ||= {}
    params[:shop][:country_ids] ||= []
    params[:shop][:category_ids] ||= []
    @shop.attributes= params[:shop]
    @shop.save
  end

  def load_shop
    @shop = Shop.find_with_inactives_and_deleted params[:id] if params[:id]
    @shop = Shop.all_with_inactive_and_deleted.find_by_short_url! params[:short_url] if params[:short_url]
  end

  def load_categories
    # TODO should query all categories is a way the view is able to render the whole tree
    @categories = ShopCategory.roots
  end

  def valid_transition
    if @shop.status == :deleted
      ajax_flash[:error] = _("Error, deleted shop")
      redirect_to request.referer unless request.xhr?
    end
  end

  def only_admin_if_inactive_or_deleted
    if (@shop.status == :deleted || @shop.status ==:inactive) && !admin_is_logged_in
      render :nothing => true, :status => :forbidden
    end
  end


end

