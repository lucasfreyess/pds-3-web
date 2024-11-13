require "test_helper"

class ControladorrsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @controladorr = controladorrs(:one)
  end

  test "should get index" do
    get controladorrs_url
    assert_response :success
  end

  test "should get new" do
    get new_controladorr_url
    assert_response :success
  end

  test "should create controladorr" do
    assert_difference("Controladorr.count") do
      post controladorrs_url, params: { controladorr: { esp32_mac_address: @controladorr.esp32_mac_address, locker_count: @controladorr.locker_count, name: @controladorr.name } }
    end

    assert_redirected_to controladorr_url(Controladorr.last)
  end

  test "should show controladorr" do
    get controladorr_url(@controladorr)
    assert_response :success
  end

  test "should get edit" do
    get edit_controladorr_url(@controladorr)
    assert_response :success
  end

  test "should update controladorr" do
    patch controladorr_url(@controladorr), params: { controladorr: { esp32_mac_address: @controladorr.esp32_mac_address, locker_count: @controladorr.locker_count, name: @controladorr.name } }
    assert_redirected_to controladorr_url(@controladorr)
  end

  test "should destroy controladorr" do
    assert_difference("Controladorr.count", -1) do
      delete controladorr_url(@controladorr)
    end

    assert_redirected_to controladorrs_url
  end
end
