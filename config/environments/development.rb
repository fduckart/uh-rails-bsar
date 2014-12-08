# Settings specified here will take precedence over those in config/environment.rb

# In the development environment your application's code is reloaded on
# every request.  This slows down response time but is perfect for development
# since you don't have to restart the webserver when you make code changes.
config.cache_classes = false
#config.cache_classes = true  # Restart the webserver when you make code changes.

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Enable the breakpoint server that script/breakpointer connects to
# config.breakpoint_server = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_controller.perform_caching             = false
config.action_view.debug_rjs                         = true

config.action_mailer.delivery_method = :smtp
config.action_mailer.perform_deliveries = true

# Don't care if the mailer can't send
config.action_mailer.raise_delivery_errors = false

#ENV['BAS_URL'] = 'http://its99.pvt.hawaii.edu:3000/bsar'
ENV['BAS_URL'] = 'http://localhost:3000/bsar'

# Encoded URL used for testing response from CAS.
#ENV['BAS_URL_ENCODED'] = 'http%3A%2F%2Fits99.pvt.hawaii.edu%3A3000%2Fbsar'
ENV['BAS_URL_ENCODED'] = 'http%3A%2F%2Ftest.host%2Fbsar'

# Email addresses used in application.
ENV['EMAIL_BIM']       = 'duckart@hawaii.edu'
ENV['EMAIL_REGISTRAR'] = 'duckart@hawaii.edu'

# CAS login filter setting.
# production => 'https://login.its.hawaii.edu/cas'
# test       => 'https://www.test.hawaii.edu/casld' 
#ENV['CAS_BAS_URL'] = 'https://login.its.hawaii.edu/cas'
ENV['CAS_BAS_URL'] = 'https://www.test.hawaii.edu/casld'
