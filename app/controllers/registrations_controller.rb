class RegistrationsController < Devise::RegistrationsController

  def new
    @countries = Country.all
    @categories = CharityCategory.all

    super
  end

  def create
    @countries = Country.all
    @categories = CharityCategory.all

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
    @resource = resource
    @resource_name = resource_name
    @path = registration_path(resource_name)

    if (resource.type == "PersonalUser")
      @type = :personal
    elsif (resource.type == "Charity")
      @type = :charity
      @countries = Country.all
    end
    render_with_scope :edit
  end

  def update
    if (resource.type == "PersonalUser")
      @type = :personal
    elsif (resource.type == "Charity")
      @type = :charity
      @countries = Country.all
    end

    super
  end

  protected
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

