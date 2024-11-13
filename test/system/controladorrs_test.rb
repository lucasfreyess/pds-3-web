require "application_system_test_case"

class ControladorrsTest < ApplicationSystemTestCase
  setup do
    @controladorr = controladorrs(:one)
  end

  test "visiting the index" do
    visit controladorrs_url
    assert_selector "h1", text: "Controladorrs"
  end

  test "should create controladorr" do
    visit controladorrs_url
    click_on "New controladorr"

    fill_in "Esp32 mac address", with: @controladorr.esp32_mac_address
    fill_in "Locker count", with: @controladorr.locker_count
    fill_in "Name", with: @controladorr.name
    click_on "Create Controladorr"

    assert_text "Controladorr was successfully created"
    click_on "Back"
  end

  test "should update Controladorr" do
    visit controladorr_url(@controladorr)
    click_on "Edit this controladorr", match: :first

    fill_in "Esp32 mac address", with: @controladorr.esp32_mac_address
    fill_in "Locker count", with: @controladorr.locker_count
    fill_in "Name", with: @controladorr.name
    click_on "Update Controladorr"

    assert_text "Controladorr was successfully updated"
    click_on "Back"
  end

  test "should destroy Controladorr" do
    visit controladorr_url(@controladorr)
    click_on "Destroy this controladorr", match: :first

    assert_text "Controladorr was successfully destroyed"
  end
end
