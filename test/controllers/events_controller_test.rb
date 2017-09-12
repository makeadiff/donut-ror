require 'test_helper'

class EventsControllerTest < ActionController::TestCase
  setup do
    @event = events(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:events)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create event" do
    assert_difference('Event.count') do
      post :create, event: { city_id: @event.city_id, date_range_from: @event.date_range_from, date_range_to: @event.date_range_to, description: @event.description, event_name: @event.event_name, image_url: @event.image_url, state_id: @event.state_id, ticket_price: @event.ticket_price, venue_address1: @event.venue_address1, venue_address: @event.venue_address }
    end

    assert_redirected_to event_path(assigns(:event))
  end

  test "should show event" do
    get :show, id: @event
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @event
    assert_response :success
  end

  test "should update event" do
    patch :update, id: @event, event: { city_id: @event.city_id, date_range_from: @event.date_range_from, date_range_to: @event.date_range_to, description: @event.description, event_name: @event.event_name, image_url: @event.image_url, state_id: @event.state_id, ticket_price: @event.ticket_price, venue_address1: @event.venue_address1, venue_address: @event.venue_address }
    assert_redirected_to event_path(assigns(:event))
  end

  test "should destroy event" do
    assert_difference('Event.count', -1) do
      delete :destroy, id: @event
    end

    assert_redirected_to events_path
  end
end
