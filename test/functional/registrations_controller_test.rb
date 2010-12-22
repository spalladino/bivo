require 'test_helper'

class RegistrationsControllerTest < ActionController::TestCase
  def setup
    request.env["devise.mapping"] = Devise.mappings[:user]
  end

  #CREATE
  test "should create charity" do
    @controller.stubs(:captcha_valid?).returns(true)

    post :create,
      :user =>
      {
        :type                  => "Charity",
        :email                 => "char@bivotest.com",
        :password              => "123456",
        :password_confirmation => "123456",
        :eula_accepted         => true,
        :charity_name          => "test",
        :charity_website       => "http://www.test.com",
        :charity_category_id   => CharityCategory.make.id,
        :short_url             => "abc",
        :charity_type          => "def",
        :tax_reg_number        => 123456,
        :country_id            => Country.make.id,
        :city                  => "Bs As",
        :description           => "Dscription test"
      }
    charity = Charity.find_by_email("char@bivotest.com")

    assert_not_nil charity
    assert_equal :inactive, charity.status
    assert_response :found
  end

  #CREATE
  test "should create charity without setting rating" do
    @controller.stubs(:captcha_valid?).returns(true)

    post :create,
      :user =>
      {
        :type                  => "Charity",
        :email                 => "char@bivotest.com",
        :password              => "123456",
        :password_confirmation => "123456",
        :eula_accepted         => true,
        :charity_name          => "test",
        :charity_website       => "http://www.test.com",
        :charity_category_id   => CharityCategory.make.id,
        :short_url             => "abc",
        :charity_type          => "def",
        :tax_reg_number        => 123456,
        :country_id            => Country.make.id,
        :city                  => "Bs As",
        :description           => "Dscription test",
        :rating                => 4
      }

    charity = Charity.find_by_email("char@bivotest.com")

    assert_not_nil charity
    assert_nil charity.rating
    
    assert_equal :inactive, charity.status
    assert_response :found
  end


 test "should create charity inactive disparite status param if not admin" do
    @controller.stubs(:captcha_valid?).returns(true)

    post :create,
      :user =>
      {
        :status                => :active,
        :type                  => "Charity",
        :email                 => "char@bivotest.com",
        :password              => "123456",
        :password_confirmation => "123456",
        :eula_accepted         => true,
        :charity_name          => "test",
        :charity_website       => "http://www.test.com",
        :charity_category_id   => CharityCategory.make.id,
        :short_url             => "abc",
        :charity_type          => "def",
        :tax_reg_number        => 123456,
        :country_id            => Country.make.id,
        :city                  => "Bs As",
        :description           => "Dscription test"
      }
    charity = Charity.find_by_email("char@bivotest.com")

    assert_not_nil charity
    assert_equal :inactive, charity.status
    assert_response :found
  end



  #CREATE
  test "shouldnt create charity" do
    @controller.stubs(:captcha_valid?).returns(false)

    post :create,
      :user =>
      {
        :type                  => "Charity",
        :email                 => "char@bivotest.com",
        :password              => "123456",
        :password_confirmation => "123456",
        :charity_category_id   => CharityCategory.make.id,
        :eula_accepted         => false,
        :charity_name          => "test",
        :short_url             => "abc",
        :charity_type          => "def",
        :tax_reg_number        => 123456,
        :country_id            => Country.make.id,
        :city                  => "Bs As"
      }

    assert_nil Charity.find_by_email("char@bivotest.com")
    assert_response :ok
  end

  #CREATE
  test "should create personal user" do
    @controller.stubs(:captcha_valid?).returns(true)

    post :create,
      :user =>
      {
        :type                  => "PersonalUser",
        :email                 => "pers@bivotest.com",
        :password              => "123456",
        :password_confirmation => "123456",
        :eula_accepted         => true,
        :first_name            => "juan",
        :last_name             => "rodriguez"
      }

    assert_not_nil PersonalUser.find_by_email("pers@bivotest.com")
    assert_response :found
  end

  #CREATE
  test "shouldnt create personal user" do
    @controller.stubs(:captcha_valid?).returns(false)

    post :create,
      :user =>
      {
        :type                  => "PersonalUser",
        :email                 => "pers@bivotest.com",
        :password              => "123456",
        :password_confirmation => "123456",
        :eula_accepted         => false,
        :first_name            => "juan",
        :last_name             => nil
      }

    assert_nil PersonalUser.find_by_email("pers@bivotest.com")
    assert_response :ok
  end

  #CREATE
  test "shouldnt create admin user" do
    @controller.stubs(:captcha_valid?).returns(true)

    post :create,
      :user =>
      {
        :type                  => "Admin",
        :email                 => "adm@bivotest.com",
        :password              => "123456",
        :password_confirmation => "123456",
        :about_me              => "lalala"
      }

    assert_nil Admin.find_by_email("adm@bivotest.com")
    assert_response :ok
  end

  #UPDATE
  [:active,:inactive].each do |status|
    test "should update #{status} charity" do
      charity = create_charity_and_sign_in :status => status, :rating => 3
      
      post :update,
        :user =>
        {
          :email                 => "char123@bivotest.com",
          :charity_name          => "test",
          :charity_website       => "http://www.test.com",
          :charity_type          => "def",
          :tax_reg_number        => 123456,
          :country_id            => Country.make.id,
          :city                  => "Bs As",
          :rating                => 1
        }

      charity.reload
      assert_equal "char123@bivotest.com", charity.email
      assert_equal status, charity.status
      assert_equal 3, charity.rating.to_i
      assert_response :found
    end
  end
  

  #UPDATE
  test "shouldnt update charity" do
    charity = create_charity_and_sign_in

    post :update,
      :user =>
      {
        :email                 => "char456@bivotest.com",
        :charity_name          => "test",
        :charity_website       => "http://www.test.com",
        :charity_type          => "def",
        :tax_reg_number        => 123456,
        :country_id            => nil,
        :city                  => "Bs As"
      }

    assert_not_equal Charity.find(charity.id).email, "char456@bivotest.com"
    assert_response :ok
  end

  #UPDATE
  test "should update personal user" do
    personal = create_and_sign_in

    put :update,
      :user =>
      {
        :email                 => "aa@bb.com",
        :first_name            => "juan",
        :last_name             => "rodriguez"
      }

    assert_equal PersonalUser.find(personal.id).email, "aa@bb.com"
    assert_response :found
  end

  #UPDATE
  test "shouldnt update personal user" do
    personal = create_and_sign_in
    put :update,
      :user =>
      {
        :email                 => "dd@ee.com",
        :first_name            => "juan",
        :last_name             => nil
      }
    assert_not_equal PersonalUser.find(personal.id).email, "dd@ee.com"
    assert_response :ok
  end


  #NEW
  test "can go to new user page" do
    user = create_and_sign_in
    get :new
    assert_response :found
  end

  #EDIT
  test "can go to edit charity" do
    user = create_charity_and_sign_in
    get :edit, :id => user.id

    assert_not_nil assigns(:resource)
    assert_equal assigns(:resource), user
    assert_response :ok
  end
  
  #EDIT
  test "can go to edit charity and set rating" do
    create_admin_and_sign_in
    charity = Charity.make
    get :edit, :id => charity.id

    assert_not_nil assigns(:resource)
    assert_equal assigns(:resource), charity
    assert_select 'select#charity_rating'
    assert_response :ok
  end

 #EDIT
  test "can go to edit personal user" do
    user = create_and_sign_in
    get :edit, :id => user.id

    assert_not_nil assigns(:resource)
    assert_equal assigns(:resource), user
    assert_response :ok
  end

 #EDIT
  test "cant go to edit charity becouse is another charity" do
    user = create_charity_and_sign_in
    user_to_edit = Charity.make
    get :edit, :id => user_to_edit.id

    assert_response :forbidden
  end

 #EDIT
  test "cant go to edit user becouse is another user" do
    user = create_charity_and_sign_in
    user_to_edit = PersonalUser.make
    get :edit, :id => user_to_edit.id

    assert_response :forbidden
  end

  #DELETE
  test "should not delete PersonalUser if not admin" do
    user = PersonalUser.make
    create_and_sign_in

    assert_difference('User.count', 0) do
      post :destroy, :id => user.id
    end

    assert_response :forbidden
  end

  #DELETE
  test "should not delete PersonalUser if self" do
    user = create_and_sign_in

    assert_difference('User.count', 0) do
      post :destroy, :id => user.id
    end

    assert_response :forbidden
  end

  #DELETE
  test "should not delete Charity if not admin" do
    user = Charity.make
    create_and_sign_in

    assert_difference('User.count', 0) do
      post :destroy, :id => user.id
    end

    assert_response :forbidden
  end
  
  #DELETE
  test "should not delete Charity if self" do
    user = create_charity_and_sign_in

    assert_difference('User.count', 0) do
      post :destroy, :id => user.id
    end

    assert_response :forbidden
  end

  #DELETE
  test "should always make logical destroy, personal user,  beeing admin" do
    user = PersonalUser.make
    create_admin_and_sign_in

    assert_no_difference('User.with_deleted.count') do
      post :destroy, :id => user.id
    end

    user.reload
    assert user.destroyed?
    assert_redirected_to admin_user_manager_path
  end

  #DELETE
  test "should always make logical destroy, charity,  beeing admin" do
    user = Charity.make
    create_admin_and_sign_in

    assert_no_difference('User.with_deleted.count') do
      post :destroy, :id => user.id
    end

    user.reload
    assert user.destroyed?
    assert_redirected_to admin_user_manager_path
  end

  #DELETE
  test "should always make logical destroy beeing admin for charity and cascade delete on causes" do
    user = Charity.make
    Cause.make(:charity => user,:status => :active)
    Cause.make(:charity => user,:status => :inactive)
    Cause.make(:charity => user,:status => :raising_funds)
    Cause.make(:charity => user,:status => :completed)
    Cause.make(:charity => user,:status => :paid)
    Cause.make(:charity => user,:status => :deleted)
    create_admin_and_sign_in

    assert_no_difference('User.with_deleted.count') do
      post :destroy, :id => user.id
    end
    
    user.reload
    assert user.destroyed?
    # TODO test cascade delete on causes
    assert_redirected_to admin_user_manager_path
  end

  test "should edit a charity from admin" do
    admin = create_admin_and_sign_in
    charity = Charity.make :rating => 4

    post :update,
      :id => charity.id,
      :user =>
      {
        :email                 => "char123@bivotest.com",
        :charity_name          => "test",
        :charity_website       => "http://www.test.com",
        :charity_type          => "def",
        :tax_reg_number        => 123456,
        :country_id            => Country.make.id,
        :city                  => "Bs As",
        :rating                => 2
      }

    charity.reload
    assert_equal "char123@bivotest.com", charity.email
    assert_equal 2, charity.rating.to_i

    assert_redirected_to :controller => :admin, :action => :user_manager
  end
  
  test "guest should not be able to edit charity" do
    # Would be better if a :forbidden status is returned but
    # update action is inaccesible for guest due to authenticate_scope!
    charity = Charity.make

    assert_raise NoMethodError do
      post :update,
        :id => charity.id,
        :user =>
        {
          :email                 => "char123@bivotest.com",
          :charity_name          => "test",
          :charity_website       => "http://www.test.com",
          :charity_type          => "def",
          :tax_reg_number        => 123456,
          :country_id            => Country.make.id,
          :city                  => "Bs As"
        }
    end

    assert_not_equal Charity.find(charity.id).email, "char123@bivotest.com"    
  end

  test "should update personal user from admin" do
    create_admin_and_sign_in
    personal = PersonalUser.make

    post :update,
      :id => personal.id,
      :user =>
      {
        :email                 => "aa@bb.com",
        :first_name            => "juan",
        :last_name             => "rodriguez"
      }

    assert_equal PersonalUser.find(personal.id).email, "aa@bb.com"
    assert_response :found
  end
  
  test "guest should not be able to update personal user" do
    # Would be better if a :forbidden status is returned but
    # update action is inaccesible for guest due to authenticate_scope!
    personal = PersonalUser.make

    assert_raise NoMethodError do
      post :update,
        :id => personal.id,
        :user =>
        {
          :email                 => "aa@bb.com",
          :first_name            => "juan",
          :last_name             => "rodriguez"
        }
    end
    
    assert_not_equal PersonalUser.find(personal.id).email, "aa@bb.com"
  end
end

