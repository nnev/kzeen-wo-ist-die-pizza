require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module KzeenWoIstDiePizza
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.yml').to_s]
    config.i18n.available_locales = [:en, :de]


    config.tip_percent = 6

    # end with trailing slash
    config.shop_url = 'https://delivery-app.app-smart.services/api2.5/D4LQjy8fNbse392x/'
    config.shop_branch_id = 1184 # from get-branches
    config.shop_fax = 'TODO'
  end
end
