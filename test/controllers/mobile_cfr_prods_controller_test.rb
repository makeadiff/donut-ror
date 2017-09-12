require 'test_helper'

class MobileCfrProdsControllerTest < ActionController::TestCase
  setup do
    @mobile_cfr_prod = mobile_cfr_prods(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:mobile_cfr_prods)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create mobile_cfr_prod" do
    assert_difference('MobileCfrProd.count') do
      post :create, mobile_cfr_prod: {  }
    end

    assert_redirected_to mobile_cfr_prod_path(assigns(:mobile_cfr_prod))
  end

  test "should show mobile_cfr_prod" do
    get :show, id: @mobile_cfr_prod
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @mobile_cfr_prod
    assert_response :success
  end

  test "should update mobile_cfr_prod" do
    patch :update, id: @mobile_cfr_prod, mobile_cfr_prod: {  }
    assert_redirected_to mobile_cfr_prod_path(assigns(:mobile_cfr_prod))
  end

  test "should destroy mobile_cfr_prod" do
    assert_difference('MobileCfrProd.count', -1) do
      delete :destroy, id: @mobile_cfr_prod
    end

    assert_redirected_to mobile_cfr_prods_path
  end
end
