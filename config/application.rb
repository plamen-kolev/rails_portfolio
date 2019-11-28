require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)
module RailsPortfolio
  class Application < Rails::Application
    config.middleware.use Rack::Deflater

    config.email = 'p.kolev22@gmail.com'
    config.linkedin = 'https://www.linkedin.com/in/plamen-kolev'
    config.github = 'https://github.com/plamen-kolev'
    config.cv_url = '/media/Plamen-Kolev_Software-Engineer_Resume.pdf'

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
  end
end
