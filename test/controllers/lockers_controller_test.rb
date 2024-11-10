require "test_helper"

class LockersControllerTest < ActionDispatch::IntegrationTest
  test "should get edit" do
    get lockers_edit_url
    assert_response :success
  end
end
