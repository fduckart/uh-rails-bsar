# Deployment settings for local testing instance.

home_dir = '/Users/fduckart/tmp/bars4uh'
set :deploy_to, home_dir

current_path = "#{home_dir}/current/config"
set :mongrel_conf, "#{current_path}/mongrel_cluster_#{stage}.yml"
    
role :app, "ogas.its.hawaii.edu"
role :web, "ogas.its.hawaii.edu"
role :db,  "ogas.its.hawaii.edu", :primary => true

# database.yml task
task :link_db_configuration do
  # Nothing necessary to do in testing environment.
end

task :link_runtime_db_configuration do
  # Nothing necessary to do in testing environment.
end
