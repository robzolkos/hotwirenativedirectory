require "test_helper"

class AppDirectoryTest < ActiveSupport::TestCase
  VALID_KEYS = %w[name app_category ios_url android_url web_url source_url image].freeze

  setup do
    @apps = YAML.load_file(Rails.root.join("config/app_directory.yml"))["apps"]
  end

  test "app_directory.yml contains apps" do
    assert @apps.present?, "app_directory.yml must contain at least one app"
  end

  test "each app only uses valid keys" do
    @apps.each do |app|
      invalid_keys = app.keys - VALID_KEYS
      assert invalid_keys.empty?,
        "#{app['name'] || 'Unknown app'} has invalid keys: #{invalid_keys.join(', ')}. " \
        "Valid keys are: #{VALID_KEYS.join(', ')}"
    end
  end

  test "each app has required keys" do
    @apps.each do |app|
      assert app["name"].present?, "Every app must have a name"
      assert app["app_category"].present?, "#{app['name'] || 'Unknown app'} must have an app_category"
      assert app["image"].present?, "#{app['name'] || 'Unknown app'} must have an image"
      assert app["ios_url"].present? || app["android_url"].present?,
        "#{app['name'] || 'Unknown app'} must have at least an ios_url or android_url"
    end
  end
end
