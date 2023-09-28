require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "can see apps on home page" do
    get root_path
    assert_select "li.app", /Basecamp/
  end
end
