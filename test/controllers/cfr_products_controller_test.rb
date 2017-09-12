require 'test_helper'

class CfrProductsControllerTest < ActionController::TestCase
  setup do
    @cfr_product = cfr_products(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:cfr_products)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create cfr_product" do
    assert_difference('CfrProduct.count') do
      post :create, cfr_product: { city_id: @cfr_product.city_id, description: @cfr_product.description, image_logo: @cfr_product.image_logo, name: @cfr_product.name, target: @cfr_product.target }
    end

    assert_redirected_to cfr_product_path(assigns(:cfr_product))
  end

  test "should show cfr_product" do
    get :show, id: @cfr_product
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @cfr_product
    assert_response :success
  end

  test "should update cfr_product" do
    patch :update, id: @cfr_product, cfr_product: { city_id: @cfr_product.city_id, description: @cfr_product.description, image_logo: @cfr_product.image_logo, name: @cfr_product.name, target: @cfr_product.target }
    assert_redirected_to cfr_product_path(assigns(:cfr_product))
  end

  test "should destroy cfr_product" do
    assert_difference('CfrProduct.count', -1) do
      delete :destroy, id: @cfr_product
    end

    assert_redirected_to cfr_products_path
  end
end
