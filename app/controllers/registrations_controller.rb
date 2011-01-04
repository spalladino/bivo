class RegistrationsController < Devise::RegistrationsController
  before_filter :load_resource, :only => [:edit,:update,:destroy]
  before_filter :allow_edit , :only => [:edit, :update]
  before_filter :load_countries_and_categories, :only => [:create,:new]
  before_filter :allow_destroy, :only => [:destroy]

  def new
    super
  end

  def create
    if ((params["user"]["type"] != "PersonalUser") &&
        (params["user"]["type"] != "Charity"))
      params["user"]["type"] = "PersonalUser"
    end

    build_resource

    unless captcha_valid?
      resource.set_captcha_invalid
    end

    resource.preferred_language = Language.preferred(request.accept_language).id

    if resource.save
      if resource.active?
        set_flash_message :notice, :signed_up
        sign_in_and_redirect(resource_name, resource)
      else
        set_flash_message :notice, :inactive_signed_up, :reason => resource.inactive_message.to_s
        redirect_to after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords(resource)
      render_with_scope :new
    end
  end

  def edit
    @ratings = (0..5).map{|i| ["#{i} #{n_('star', 'stars', i)}", i]}
    render_with_scope :edit
  end


  def update
    # Manually update rating as we mark it as protected, it can be only modified by an admin
    @resource.rating = params[resource_name][:rating] if @resource.type.to_s == "Charity" && admin_is_logged_in
    
    if @resource.update_with_password(params[resource_name])
      set_flash_message :notice, :updated
      if admin_is_logged_in
        redirect_to admin_user_manager_path
      else
        redirect_to after_update_path_for(@resource)
      end
    else
      clean_up_passwords(resource)
      @ratings = (0..5).map{|i| ["#{i} #{n_('star', 'stars', i)}", i]}
      render_with_scope :edit
    end
  end

  def destroy
    @resource.destroy
    set_flash_message :notice, :destroyed
    redirect_to admin_user_manager_path
  end

  protected

    def allow_edit
      if  !((current_user && current_user == @resource) || admin_is_logged_in)
        render :nothing => true, :status => :forbidden
        return false
      end
    end

    def allow_destroy
      if  !(admin_is_logged_in)
        render :nothing => true, :status => :forbidden
        return false
      end
    end

    def load_resource
      if !params[:id].blank?
        @id = params[:id]
        @resource = User.find(params[:id])
      else
        @resource = resource
      end

      @type = @resource.type.to_sym
      if (@type == :Charity)
        @countries = Country.all
      end

      @path = registration_path(@resource)

    end

    def load_countries_and_categories
      @countries = Country.all
      @categories = CharityCategory.all
    end

    def build_resource(*args)
      super

      if (params["user"])
        if (params["user"]["type"] == "PersonalUser")
          self.resource = PersonalUser.new(params["user"])
        elsif (params["user"]["type"] == "Charity")
          self.resource = Charity.new(params["user"])
        end
      end
    end

    def captcha_valid?
      verify_recaptcha
    end
end

