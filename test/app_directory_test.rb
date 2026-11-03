require "minitest/autorun"
require "yaml"

class AppDirectoryTest < Minitest::Test
  VALID_KEYS = %w[name app_category description ios_url android_url web_url source_url image].freeze
  ANDROID_STORES = %r{\Ahttps://(play\.google\.com|f-droid\.org)/}
  IMAGES_DIR = File.expand_path("../assets/images/apps", __dir__)

  def setup
    @apps = YAML.load_file(File.expand_path("../_data/app_directory.yml", __dir__))["apps"]
  end

  def present?(value)
    !value.to_s.strip.empty?
  end

  def label(app)
    app["name"] || "Unknown app"
  end

  def test_app_directory_contains_apps
    refute_empty @apps, "app_directory.yml must contain at least one app"
  end

  def test_each_app_only_uses_valid_keys
    @apps.each do |app|
      invalid_keys = app.keys - VALID_KEYS
      assert_empty invalid_keys,
        "#{label(app)} has invalid keys: #{invalid_keys.join(', ')}. Valid keys are: #{VALID_KEYS.join(', ')}"
    end
  end

  def test_each_app_has_required_keys
    @apps.each do |app|
      assert present?(app["name"]), "Every app must have a name"
      assert present?(app["app_category"]), "#{label(app)} must have an app_category"
      assert present?(app["image"]), "#{label(app)} must have an image"
      assert present?(app["ios_url"]) || present?(app["android_url"]),
        "#{label(app)} must have at least an ios_url or android_url"
    end
  end

  def test_each_app_image_exists
    @apps.each do |app|
      assert File.exist?(File.join(IMAGES_DIR, app["image"].to_s)),
        "#{label(app)} image #{app['image']} is missing from assets/images/apps"
    end
  end

  def test_android_urls_point_to_a_supported_store
    @apps.select { |app| present?(app["android_url"]) }.each do |app|
      assert_match ANDROID_STORES, app["android_url"],
        "#{label(app)} android_url must link to Google Play or F-Droid"
    end
  end

  def test_values_are_not_blank
    @apps.each do |app|
      app.each do |key, value|
        assert present?(value), "#{label(app)} has a blank #{key}. Remove the key instead."
      end
    end
  end

  def test_description_is_optional
    assert @apps.any? { |app| present?(app["description"]) }, "At least one app should demonstrate an optional description"
    assert @apps.any? { |app| !present?(app["description"]) }, "Apps without descriptions should remain valid"
  end
end
