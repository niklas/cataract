require 'spec_helper'

describe "routing for torrents" do
  it do
    { :get => '/torrents' }.should route_to(
      controller: 'torrents',
      action:     'index'
    )
  end

  it do
    { :get => torrents_path }.should route_to(
      controller: 'torrents',
      action:     'index'
    )
  end

  it do
    torrent = create :torrent
    { :get => torrent_path(torrent) }.should route_to(
      controller: 'torrents',
      action:     'show',
      id:         torrent.to_param
    )
  end
end
