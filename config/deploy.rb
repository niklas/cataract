set :application, "cataract"
set :repository,  "svn://lanpartei.de/cataract/trunk"

set :deploy_to, "/usr/lib/cgi-bin/#{application}"

role :app, "pomorya.local"
role :web, "pomorya.local"
role :download, "pomorya.local"
role :db,  "pomorya.local", :primary => true
set :user, 'niklas'

set :build_dir, '/tmp/rtorrent'
set :libtorrent_version, '0.11.6'
set :rtorrent_version, '0.7.6'

task :build_rtorrent, :roles => :download do
  sudo 'aptitude install -q -y g++ checkinstall libsigc++-2.0-dev libxmlrpc-c-dev ncurses-dev libcurl4-openssl-dev'
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
