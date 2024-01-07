require "application_system_test_case"

class HomePageTest < ApplicationSystemTestCase
  test "visiting the home page" do
    visit root_url

    assert_selector "h1", text: "Turbo Native Directory"
  end
end
