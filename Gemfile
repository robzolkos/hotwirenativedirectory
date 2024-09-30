source "https://rubygems.org"

ruby "3.3.5"

# Rails
gem "rails", "~> 8.0.0.beta1"

# Drivers
gem "sqlite3"

# Deployment
gem "puma", "~> 6.4"
gem "thruster", require: false
gem "bootsnap", require: false
gem "kamal", require: false

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
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"
  gem "rubocop-rails-omakase", require: false
  gem "brakeman", require: false
end

group :development do
  gem "web-console"
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
end
