require 'test_helper'

class HelloControllerTest < ActionController::TestCase
  test "should get index" do
    @controller.class.els_faker("neilcuk","development","test")
    get :index
    assert_response :success
    assert_not_nil assigns(:cdid)
    assert_equal @controller.class.els_options[:faker][:user], assigns(:cdid)
  end

  test "should not get index" do
    @controller.class.els_faker({})
    get :index
    assert_response :unauthorized
   end

  test "authenticated should be false" do
    @controller.class.els_faker({})
    get :index
    assert_equal assigns(:authenticated), false
  end  

  test "authenticated should be true " do
    puts "enter a username"
    @controller.instance_variable_set "@username", gets.chomp
    puts "enter a password"
    @controller.instance_variable_set "@password", gets.chomp
    get :index
    assert_equal assigns(:authenticated), true
  end
end
