data = Rails.root.join("config", "app_directory.yml")
apps = YAML.load_file(data)["apps"]
APP_DETAILS = apps.sort_by { |a| a["name"].downcase }.freeze
