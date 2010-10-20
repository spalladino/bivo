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
  end

  def edit
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

  def check_url
    if Charity.find_by_short_url(params[:url])
      render :text => 'not_available'
    else
      render :text => 'available'
    end
  end

  def build_resource(*args)
    super

    if (params[:user])
      if (params["user"]["type"] == "PersonalUser")
        self.resource = PersonalUser.new(params["user"])   
      elsif (params["user"]["type"] == "Charity")
        self.resource = Charity.new(params["user"])
      end
    end
  end
end
