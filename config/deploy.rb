# RVM bootstrap
require 'rvm/capistrano'
set :rvm_ruby_string, '1.9.3-p194-xmlrpc64bit@cataract'
set :rvm_type, :system

# bundler bootstrap
require 'bundler/capistrano'
#load 'deploy/assets'

set :whenever_command, "bundle exec whenever"
require "whenever/capistrano"

# server details
default_run_options[:pty] = true
ssh_options[:forward_agent] = true
set :deploy_via, :remote_cache
set :use_sudo, false

# application settings
set :application, "cataract"
set :scm, :git
set :repository,  "git://github.com/niklas/cataract.git"
set :local_repository, "."
set :branch, ENV['BRANCH'] || 'master'
set :git_enable_submodules, 1


single_target = ENV['TARGET'] || "schnurr.local"
puts "  will use #{single_target} as target" 
puts "  set env.TARGET to deploy to another machine"

role :app, single_target
role :web, single_target
role :download, single_target
role :db,  single_target, :primary => true
set :user, "torrent"

set :deploy_to, "/home/#{user}/www/#{application}"
set :upstart_dir, "/home/#{user}/.init"

namespace :deploy do
  desc "Restart App (Apache Passanger)"
  task :restart do
    run "touch #{current_release}/tmp/restart.txt"
  end

  desc "Symlink shared stuff"
  task :symlink_shared, :roles => :app do
    config_dir = "#{deploy_to}/#{shared_dir}/config"
    make_link = "ln -sf #{deploy_to}/{#{shared_dir},#{version_dir}/#{release_name}}"
    run "mkdir -p #{config_dir}"
    run "#{make_link}/config/database.yml"
    run "#{make_link}/config/messenger.yml"
    run "#{make_link}/tmp/rtorrent.socket"
    run "mkdir -p #{deploy_to}/#{shared_dir}/public/uploads"
    run "#{make_link}/public/uploads"
  end

  after "deploy:create_symlink", "deploy:symlink_shared"

  task :foreman do
    run "mkdir -p #{upstart_dir}"
    run "cd #{current_release} && bundle exec foreman export upstart #{upstart_dir} --app=#{application} --user=#{user} --template ./config/foreman/templates --log #{current_release}/log/"
  end

  after "deploy:update_code", "deploy:foreman"
  after "deploy:foreman", "services:restart"

  task :warmup, :roles => :app do
    STDERR.puts "Warming up application"
    run "sleep 2; wget -q -O - http://#{single_target} | grep -vi exception > /dev/null"
  end

  desc "Delete the code we use to accelerate testing"
  task :delete_test_code do
    run "rm -f #{current_release}/app/controllers/test_acceleration_controller.rb"
  end

  before "deploy:assets:precompile", "deploy:delete_test_code"
end

namespace :rake do  
  desc "Run a task on a remote server."  
  # run like: cap staging rake:invoke task=a_certain_task  
  task :invoke do  
    run("cd #{deploy_to}/current; /usr/bin/env rake --trace #{ENV['task']} RAILS_ENV=#{rails_env}")  
  end  
end

namespace :services do
  desc "Restart all services"
  task :restart do
    run "restart cataract || start cataract"
  end
end
