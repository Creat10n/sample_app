require_relative "boot"
require "rails/all"
require File.expand_path("../boot", __FILE__)

Bundler.require(*Rails.groups)

module SampleApp
  class Application < Rails::Application
    config.load_defaults 5.1
    config.i18n.available_locales = Settings.locales.available
    config.i18n.default_locale = Settings.locales.default
    config.i18n.load_path += Dir[Rails.root.join("config", "locales", "**", "*.{rb,yml}").to_s]
    # Include the authenticity token in remote forms.
    config.action_view.embed_authenticity_token_in_remote_forms = true
    config.assets.initialize_on_precompile = false
  end
end
