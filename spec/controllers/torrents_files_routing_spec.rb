require File.dirname(__FILE__) + '/../spec_helper'

describe TorrentsFilesController do
  describe "route generation" do

    it do
      route_for(:controller => 'torrents_files', :action => 'show', :torrent_id => 23).should == '/torrents/23/files'
    end

  end


  describe "route recognition" do

    it  do
      params_from(:get, "/torrents/23/files").should == {:controller => "torrents_files", :action => "show", :torrent_id => "23"}
    end

    it  do
      params_from(:put, "/torrents/23/files").should == {:controller => "torrents_files", :action => "update", :torrent_id => "23"}
    end

    it  do
      params_from(:post, "/torrents/23/files").should == {:controller => "torrents_files", :action => "create", :torrent_id => "23"}
    end
  
  end
end
