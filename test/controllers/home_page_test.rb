require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "can see apps on home page" do
    get root_path
    assert_select "li.app", /Basecamp/
  end

  test "renders optional app descriptions without affecting apps that omit them" do
    get root_path

    assert_select "li.app", text: /Basecamp/ do
      assert_select "p.app-description", text: /Project management from 37signals/
    end

    assert_select "li.app", text: /HEY Email/ do
      assert_select "p.app-description", false
    end
  end

  test "download buttons stay pinned to the bottom of cards" do
    get root_path

    assert_select "li.app.flex.flex-col.h-full"
    assert_select "li.app ul.mt-auto"
  end
end
