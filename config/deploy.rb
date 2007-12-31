set :application, "cataract"
set :repository,  "svn://lanpartei.de/cataract/trunk"
set :urlbase, "cataract"  # http://yourhost.bla/:urlbase
set :deploy_to, "/usr/lib/cgi-bin/#{application}"

single_target = ENV['TARGET'] || "poppomorya.local"
puts "  will use #{single_target} as target" 
puts "  set env.TARGET to deploy to another machine"

role :app, single_target
role :web, single_target
role :download, single_target
role :db,  single_target, :primary => true
set :user, 'niklas'

set :build_dir, '/tmp/rtorrent'
set :libtorrent_version, '0.11.6'
set :rtorrent_version, '0.7.6'

task :build_rtorrent, :roles => :download do
  sudo 'aptitude install -q -y g++ checkinstall libsigc++-2.0-dev libxmlrpc-c-dev ncurses-dev libcurl4-openssl-dev libcurl3-openssl-dev'
  sudo 'dpkg -r rtorrent libtorrent'

  sudo "rm -rf #{build_dir}"
  run "mkdir -p #{build_dir}"

  run "svn export svn://rakshasa.no/libtorrent/tags/libtorrent-#{libtorrent_version} #{build_dir}/libtorrent"
  run <<-CMD
    cd #{build_dir}/libtorrent; 
    ./autogen.sh && ./configure && make &&
    sudo checkinstall -y 
      --pkgversion #{libtorrent_version}cataract
  CMD

  run "svn export svn://rakshasa.no/libtorrent/tags/rtorrent-#{rtorrent_version} #{build_dir}/rtorrent"
  run <<-CMD
    cd #{build_dir}/rtorrent;
    ./autogen.sh &&
    ./configure 
      --with-xmlrpc-c && 
    make && 
    sudo checkinstall -y
      --pkgversion #{rtorrent_version}niklas
  CMD

  sudo "rm -rf #{build_dir}"
end

namespace :deploy do
  desc "Restart the Webserver (lighttpd)"
  task :restart, :roles => :app do
    sudo '/etc/init.d/lighttpd stop'
    sudo 'killall dispatch.fcgi || true'
    sudo '/etc/init.d/lighttpd start'
  end

  desc "Fix something after setup"
  task :after_setup, :roles => :app do
    group_permissions
  end
  task :before_restart, :roles => :app do
    group_permissions
  end
  desc "More symlinks (configs etc)"
  task :after_symlink, :roles => :app do
    config_dir = "#{deploy_to}/shared/config"
    sudo "mkdir -p #{config_dir}"
    sudo "ln -fs #{config_dir}/database.yml #{current_release}/config/database.yml"
    sudo "ln -fs #{config_dir}/messenger.yml #{current_release}/config/messenger.yml"
    puts "Make sure to create a proper database.yml (in #{config_dir})"
  end
  task :group_permissions do
    sudo "chgrp -R www-data #{deploy_to}"
    sudo "chmod -R g+w #{deploy_to}"
  end

  desc "Configure lighttpd"
  task :configure_lighttpd, :roles => :app do
    require 'erb'
    template = File.read('capistrano/recipes/templates/lighttpd.conf.template')
    result = ERB.new(template).result(binding)
    run "mkdir -p #{deploy_to}/shared/system"
    conf_target = "#{deploy_to}/shared/system/lighttpd.conf" 
    put result, conf_target
    sudo "lighty-disable-mod cataract"
    sudo "ln -fs #{conf_target} /etc/lighttpd/conf-available/55-cataract.conf"
    sudo "lighty-enable-mod cataract"
  end

  desc "Configure Rtorrent" 
  task :configure_rtorrent do
    result = File.read('capistrano/recipes/templates/rtorrent-lighttpd.conf')
    conf_target = "#{deploy_to}/shared/system/rtorrent-lighttpd.conf"
    put result, conf_target
    sudo "lighty-disable-mod rtorrent"
    sudo "ln -fs #{conf_target} /etc/lighttpd/conf-available/11-rtorrent.conf"
    sudo "lighty-enable-mod rtorrent"
    put "scgi_port = localhost:5000\n", "#{deploy_to}/shared/system/rtorrent.rc"
  end

  desc "Prepare config files"
  task :configure, :roles => :app do
    configure_lighttpd
    configure_rtorrent
    put urlbase, "#{current_release}/config/urlbase.txt"
  end

end
