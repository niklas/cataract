require File.dirname(__FILE__) + '/../test_helper'

class TorrentTest < Test::Unit::TestCase
  fixtures :torrents

  # Replace this with your real tests.
  def test_truth
    assert_kind_of Torrent, torrents(:first)
  end
end
