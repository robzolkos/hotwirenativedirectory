source "https://rubygems.org"

ruby "3.3.5"

# Rails
gem "rails", github: "rails/rails", branch: "main"

# Drivers
gem "sqlite3"

# Deployment
gem "puma", "~> 6.4"
gem "bootsnap", require: false

# Assets
gem "propshaft"
gem "importmap-rails"

# Hotwire
gem "turbo-rails"
gem "stimulus-rails"

# Other
gem "inline_svg"
gem "tailwindcss-rails"

group :development, :test do
  gem "debug"
  gem "rubocop-rails-omakase", require: false
  gem "brakeman", require: false
end

group :development do
  gem "web-console"
  gem "kamal", require: false
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
end
