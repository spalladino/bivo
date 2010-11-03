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

    assert_not_nil Charity.find_by_email("char@bivotest.com")
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
  test "should update charity" do
    charity = create_charity_and_sign_in

    post :update,
      :user =>
      {
        :email                 => "char123@bivotest.com",
        :charity_name          => "test",
        :charity_website       => "http://www.test.com",
        :short_url             => "abc",
        :charity_type          => "def",
        :tax_reg_number        => 123456,
        :country_id            => Country.make.id,
        :city                  => "Bs As"
      }

    assert_equal Charity.find(charity.id).email, "char123@bivotest.com"
    assert_response :found
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
        :short_url             => nil,
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
end

