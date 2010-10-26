require 'test_helper'

class RegistrationsControllerTest < ActionController::TestCase
  #CREATE
  test "should create charity" do
    @controller.stubs(:captcha_valid?).returns(true)
    request.env["devise.mapping"] = Devise.mappings[:user]
    post :create,
      :user =>
      {
        :type                  => 'Charity',
        :email                 => "aaa@bbb.com",
        :password              => "123456",
        :password_confirmation => "123456",
        :eula_accepted         => true,
        :charity_name          => "test",
        :charity_website       => "http://www.test.com",
        :short_url             => "abc",
        :charity_type          => "def",
        :tax_reg_number        => 123456,
        :city                  => "Bs As"
      }

    assert_not_nil Charity.find_by_email("aaa@bbb.com")
    assert_response :found
  end

  #CREATE
  test "shouldnt create charity without captcha" do
    #TODO completar
    assert_response :ok
  end

  #CREATE
  test "should create personal user" do
    #TODO completar
    assert_response :ok
  end

  #CREATE
  test "shouldnt create personal user" do
    #TODO completar
    assert_response :ok
  end

  #UPDATE
  test "should update charity" do
    #TODO completar
    assert_response :ok
  end

  #UPDATE
  test "shouldnt update charity" do
    #TODO completar
    assert_response :ok
  end
end
