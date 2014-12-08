# Settings specified here will take precedence 
# over those in config/environment.rb
ENV['RAILS_ENV'] = 'production'

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

#ENV['BAS_URL'] = 'http://its10.pvt.hawaii.edu:3000/bsar'
ENV['BAS_URL'] = 'http://www.hawaii.edu/bsar'

# Email addresses used in application.
ENV['EMAIL_BIM']       = 'banner-idmgmt@lists.hawaii.edu'
ENV['EMAIL_REGISTRAR'] = 'duckart@hawaii.edu'

# CAS login filter setting.
ENV['CAS_BAS_URL'] = 'https://login.its.hawaii.edu/cas'
