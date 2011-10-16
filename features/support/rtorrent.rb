Before do
  # do not run rtorrent server in tests

  @rtorrent = mock('RTorrent', :call => true)
  @rtorrent.stub(:remote_respond_to?).with(:state).and_return(true)
  RTorrent.stub(:new).and_return( @rtorrent )
end
