# Remove Inter font from precompile list
# This is automatically included with tailwindcss-rails but unused in this project
Rails.application.config.to_prepare do
  Rails.application.config.assets.precompile -= %w[inter-font.css]
  Rails.application.config.assets.paths.reject! { _1.is_a?(String) && _1.include?("gems/tailwindcss-rails") }
end
