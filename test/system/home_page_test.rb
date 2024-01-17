require "application_system_test_case"

class HomePageTest < ApplicationSystemTestCase
  test "visiting the home page" do
    visit root_url

    assert_selector "p", text: "Native iOS/Android applications backed by web views"
  end
end
