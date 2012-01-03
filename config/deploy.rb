# RVM bootstrap
$:.unshift(File.expand_path("~/.rvm/lib"))
require 'rvm/capistrano'
set :rvm_ruby_string, '1.9.3-p0-xmlrpc64bit@cataract'

# bundler bootstrap
require 'bundler/capistrano'
load 'deploy/assets'

# server details
default_run_options[:pty] = true
ssh_options[:forward_agent] = true
set :deploy_via, :remote_cache
set :use_sudo, false

# application settings
set :application, "cataract"
set :scm, :git
set :repository,  "git@github.com:niklas/cataract.git"
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
set :user, "niklas"

set :deploy_to, "/home/#{user}/www/#{application}"

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
    run "#{make_link}/tmp/sockets"

    run "chmod a+rXw #{deploy_to}/#{shared_dir}/tmp/sockets"
  end

  before "deploy:assets:precompile", "deploy:symlink_shared"

  task :group_permissions do
    sudo "chgrp -R www-data #{current_release}"
    sudo "chmod -R g+w #{current_release}"
  end
  after 'deploy:setup', 'deploy:group_permissions'

end
