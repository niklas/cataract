set :repository,  "git://github.com/niklas/cataract.git"

set :upstart_dir, "/home/#{user}/.init"

namespace :deploy do

  desc "Symlink shared stuff"
  task :symlink_shared, :roles => :app do
    config_dir = "#{deploy_to}/#{shared_dir}/config"
    make_link = "ln -sf {#{shared_path},#{latest_release}}"

    run <<-CMD
      mkdir -p #{shared_path}/config &&
      mkdir -p #{shared_path}/tmp &&
      mkdir -p #{shared_path}/public/uploads &&
      #{make_link}/config/messenger.yml &&
      #{make_link}/config/newrelic.yml &&
      #{make_link}/tmp/rtorrent.socket &&
      #{make_link}/public/uploads
    CMD
  end

  after "deploy:finalize_update", "deploy:symlink_shared"



  task :foreman do
    run "mkdir -p #{upstart_dir}"
    run "cd #{current_release} && bundle exec foreman export upstart #{upstart_dir} --app=#{application} --user=#{user} --template ./config/foreman/templates --log #{current_release}/log/"
  end

  after "deploy:update_code", "deploy:foreman"
  after "deploy:foreman", "services:restart"



  desc "Delete the code we use to accelerate testing"
  task :delete_test_code do
    run "rm -f #{current_release}/app/controllers/test_acceleration_controller.rb"
  end

  before "deploy:restart", "deploy:delete_test_code"

end

namespace :raketask do
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
