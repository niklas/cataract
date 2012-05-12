describe "torrents/create" do
  let(:torrent) { create :torrent }
  it "includes URL for prepend request" do
    assign(:torrent, torrent)
    render
    JSON.parse(rendered).should be_matching({'id' => torrent.id, 'prepend_url' => prepend_torrent_path(torrent)}, :ignore_additional=>true)
  end
end
