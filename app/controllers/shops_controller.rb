class ShopsController < ApplicationController

  before_filter :authenticate_user!, :except => [:details,:home,:show,:search,:index]
  before_filter :only_admin, :only => [:new, :create, :edit, :update, :destroy,:activate, :deactivate, :edit_categories]

  around_filter :translate_categories, :except => [ :edit_categories ]
  before_filter :load_shop, :except => [ :new, :create, :index, :search, :edit_categories]
  before_filter :load_places, :only => [ :new, :edit, :create, :update ]
  before_filter :load_categories, :only => [ :new, :edit, :create, :update, :edit_categories, :index ]

  before_filter :ensure_active_if_not_admin, :only => [:home,:details]


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
    if !params[:category_field].blank?
      @category = ShopCategory.find(params[:category_field])
      @shops = if admin_is_logged_in then @category.shops.all_translated_with_inactives else @category.shops.translated end
      @path = @category.ancestors
    else
      @shops = if admin_is_logged_in then Shop.all_translated_with_inactives else Shop.translated end
    end
    # Set pagination
    @per_page = (params[:per_page] || 20).to_i

    @count = if admin_is_logged_in then @shops.count else @shops.where('shops.status != ?',:inactive).count end

    @shops = @shops.paginate(:per_page => @per_page, :page => params[:page])
    @page_sizes = [5,10,20,50]
  end


  def search

    # Filter by text
    @search_word = params[:search_word]

    if @search_word.blank?
      @shops = Shop.translated.includes(:countries)
    else
      term = @search_word.gsub(/\\/, '\&\&').gsub(/'/, "''")

      # Return all shops that match the search and that have categories that match the search
      categories = ShopCategory.search_translated(term)
      categories_filter = "OR EXISTS (SELECT * FROM shop_categories_shops WHERE shop_categories_shops.shop_category_id IN (#{categories.map(&:id).join(',')}) AND shop_categories_shops.shop_id = shops.id)" if categories.count > 0
      @shops = Shop.includes(:countries).search_translated(term, nil, categories_filter)
    end

    # Handle sorting options
    @sorting = (params[:sorting] || :alphabetically).to_sym
    if @sorting == :proximity && !current_user.country_id.nil?
      @shops = @shops.where("exists (select * from country_shops where country_id = ? and shop_id = Shops.id)",current_user.country_id) + @shops.where("not exists (select * from country_shops where country_id = ? and shop_id = Shops.id)",current_user.country_id)
    else
      @shops = @shops.order "#{Shop.translation_table}.name ASC, #{Shop.translation_table}.description ASC"
    end

    @count = @shops.count

    # Set pagination
    @per_page = (params[:per_page] || 20).to_i
    @shops = @shops.paginate(:per_page => @per_page, :page => params[:page])
    @page_sizes = [5,10,20,50]

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
    @shop = Shop.find_translated_with_inactives params[:id] if params[:id]
    @shop = Shop.all_translated_with_inactives.find_by_short_url! params[:short_url] if params[:short_url]
    render :status => :not_found unless @shop
  end

  def load_categories
    # TODO should query all categories in a way the view is able to render the whole tree
    @categories = ShopCategory.roots
  end

  def ensure_active_if_not_admin
    if @shop.status_inactive? && !admin_is_logged_in
      @kind = _('shop')
      @name = @shop.name
      render('shared/inactive')
    end
  end

  def translate_categories
    ShopCategory.with_lazy_translation { yield }
  end

end

