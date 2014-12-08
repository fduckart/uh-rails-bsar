# Settings specified here will take precedence 
# over those in config/environment.rb
ENV['RAILS_ENV'] = 'staging'

# The production environment is meant for finished, "live" apps.
# Code is not reloaded between requests
config.cache_classes = true

# Use a different logger for distributed setups
# config.logger = SyslogLogger.new

# Full error reports are disabled and caching is turned on
config.action_controller.consider_all_requests_local = false
config.action_controller.perform_caching             = true

# Enable serving of images, stylesheets, and javascripts from an asset server
#config.action_controller.asset_host = "http://assets.example.com"

config.action_mailer.delivery_method = :smtp
config.action_mailer.perform_deliveries = true

ENV['BAS_URL']         = 'http://www.test.hawaii.edu/bsar'

# Email addresses used in application.
ENV['EMAIL_BIM']       = 'duckart@hawaii.edu'
ENV['EMAIL_REGISTRAR'] = 'duckart@hawaii.edu'

# Encoded URL used for testing response from CAS.
ENV['BAS_URL_ENCODED'] = 'http%3A%2F%2Fwww.test.hawaii.edu%2Fbsar'
