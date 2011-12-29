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
    { :get => '/torrents/status/running' }.should route_to(
      controller: 'torrents',
      action:     'index',
      status:     'running'
    )
  end

  it do
    { :get => '/torrents/page/23' }.should route_to(
      controller: 'torrents',
      action:     'index',
      page:       '23'
    )
  end

  it do
    { :get => '/torrents/status/running/page/23' }.should route_to(
      controller: 'torrents',
      status:     'running',
      action:     'index',
      page:       '23'
    )
  end
end
