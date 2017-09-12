require 'test_helper'

class PoctransactionsControllerTest < ActionController::TestCase
  setup do
    @poctransaction = poctransactions(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:poctransactions)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create poctransaction" do
    assert_difference('Poctransaction.count') do
      post :create, poctransaction: {  }
    end

    assert_redirected_to poctransaction_path(assigns(:poctransaction))
  end

  test "should show poctransaction" do
    get :show, id: @poctransaction
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @poctransaction
    assert_response :success
  end

  test "should update poctransaction" do
    patch :update, id: @poctransaction, poctransaction: {  }
    assert_redirected_to poctransaction_path(assigns(:poctransaction))
  end

  test "should destroy poctransaction" do
    assert_difference('Poctransaction.count', -1) do
      delete :destroy, id: @poctransaction
    end

    assert_redirected_to poctransactions_path
  end
end
