class RegistrationsController < Devise::RegistrationsController

  def new
    @countries = Country.all
    @categories = CharityCategory.all

    super
  end

  def create
    @countries = Country.all
    @categories = CharityCategory.all

    super
    session[:omniauth] = nil unless @user.new_record?
  end

  def build_resource(*args)
    super

    if (params[:user])
      if (params["user"]["type"] == "PersonalUser")
        session[:test_type] = "user"
        self.resource = PersonalUser.new(params["user"])   
      elsif (params["user"]["type"] == "Charity")
        self.resource = Charity.new(params["user"])
      end

      if session[:omniauth]
        @user.apply_omniauth(session[:omniauth])
        @user.valid?
      end
    end
  end
end
