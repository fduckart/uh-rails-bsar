# Deployment settings:

set :rails_env, "#{stage}"
set :use_sudo, false
set :scm_command, '/usr/local/bin/svn'
set :rake, '/usr/local/bin/rake'
set :mongrel_rails, '/usr/bin/mongrel_rails'
set :user, 'duckart'
home_dir = '/var/home/duckart/bars4uh'
set :deploy_to, home_dir

current_path = "#{home_dir}/current/config"
set :mongrel_conf, "#{current_path}/mongrel_cluster_#{stage}.yml"

role :app, "its10.pvt.hawaii.edu"
role :web, "its10.pvt.hawaii.edu"
role :db,  "its10.pvt.hawaii.edu", :primary => true

# database.yml task
desc "Link in the #{stage} deployment database.yml."
task :link_db_configuration do
  run "ln -nfs /var/home/duckart/shared/config/#{stage}/database.yml.deploy #{release_path}/config/database.yml"
end

desc "Link in the #{stage} runtime database.yml."
task :link_runtime_db_configuration do
  run "ln -nfs /var/home/duckart/shared/config/#{stage}/database.yml.runtime #{release_path}/config/database.yml"
end
