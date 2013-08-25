# http://gembundler.com/deploying.html
require 'bundler/capistrano'
require 'puma/capistrano'

# http://guides.rubyonrails.org/asset_pipeline.html
load 'deploy/assets'

# http://beginrescueend.com/integration/capistrano/
# Also add rvm-capistrano to your Gemfile
require "rvm/capistrano"                  # Load RVM's capistrano plugin.
#set :rvm_type, :system  # Copy the exact line. I really mean :system here

set :application, "dominion"
set :repository,  "https://github.com/jcbantuelle/dominion.git"
set :scm, :git
set :deploy_via,  :remote_cache
set :use_sudo,    false
set :group_writable,  false # Setting $HOME to g+w during deploy:setup will break ssh key authentication

server '99.71.157.65:23451', :web, :app, :db, :primary => true
set :deploy_to, '/Users/justin/Sites/dominion'
set :user,      'justin'
set :rails_env, 'production'
set :branch,    'master'

desc 'Create the shared/config dir for various config files'
task :create_configs do
  run "mkdir -p #{shared_path}/config"
  run "touch #{shared_path}/config/database.yml"
end

desc 'Copy the shared config files to the release config dir'
task :update_configs do
  run "cp -Rf #{shared_path}/config/* #{release_path}/config"
end

desc 'Seed Database with Implemented Cards'
task :seed_cards do
  run "cd #{current_path} && RAILS_ENV=#{rails_env} bundle exec rake db:seed"
end

namespace :puma do
  desc "Start the application"
  task :start, :roles => :app, :except => { :no_release => true } do
    run "cd #{current_path} && RAILS_ENV=#{rails_env} bundle exec puma -t 8:32 -p 4321 -d -S #{shared_path}/sockets/puma.state", :pty => false
  end
end

# Set up our callbacks
after 'deploy:setup', :create_configs
after 'deploy:finalize_update', :update_configs
after 'deploy:restart', :seed_cards
