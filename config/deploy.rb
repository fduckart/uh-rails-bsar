require 'capistrano/ext/multistage'
require 'mongrel_cluster/recipes'

set :stages, %w(staging production testing)
set :default_stage, 'testing'

set :scm, :subversion
set :repository,  "svn+ssh://svnd@repo.its.hawaii.edu/misint/bsar/branches/trunk/rails/bsar"

ssh_options[:auth_methods] = %w(password keyboard-interactive)

namespace :deploy do
  after  "deploy:update_code", :link_db_configuration
  before "deploy:start", :link_runtime_db_configuration
end

