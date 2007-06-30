require File.dirname(__FILE__) + '/../test_helper'

class TorrentTest < Test::Unit::TestCase
  fixtures :torrents

  def setup
    prepare_directories
  end

  def test_status_methods
    assert @lebelge.status.to_sym == :remote
    assert @lebelge.current_state == :remote
    assert @lebelge.remote?
  end

  def test_a_remote_torrent
    assert_equal :remote, @lebelge.current_state
    assert @lebelge.remote?, 'not remote'
    assert @lebelge.valid?, 'not valid'
    unless @lebelge.fetchable?
      assert @lebelge.errors.empty?, @lebelge.errors.full_messages
      flunk 'not fetchable'
    end
  end

  def test_fetch_and_lifecycle
    assert @lebelge.fetch!, 'could not fetch'
    # after that the file should lay in the history dir
    assert_kind_of String, @lebelge.fullpath
    assert !@lebelge.fullpath.empty?, 'empty path'
    assert_equal Settings.history_dir + 'LeBelgeElectrod - AudioDestruction Part I -- Jamendo - MP3 VBR 192k - 2006.03.23 [www.jamendo.com].torrent', @lebelge.fullpath, 'wrong path'
    assert @lebelge.file_exists?, 'file missing'

    @lebelge.start!
    assert_equal :running, @lebelge.current_state
    assert @lebelge.running?
    assert_kind_of String, @lebelge.fullpath
    assert !@lebelge.fullpath.empty?
    assert_equal Settings.torrent_dir + '/LeBelgeElectrod - AudioDestruction Part I -- Jamendo - MP3 VBR 192k - 2006.03.23 [www.jamendo.com].torrent', @lebelge.fullpath
    assert @lebelge.file_exists?

    # start again, for verpeiling users
    @lebelge.start!
    assert @lebelge.running?
    assert_equal :running, @lebelge.current_state

    @lebelge.pause!
    assert_equal :paused, @lebelge.current_state
    assert @lebelge.paused?
    assert @lebelge.file_exists? ####

    @lebelge.start!
    assert @lebelge.running?
    assert @lebelge.file_exists?

    @lebelge.stop!
    assert @lebelge.stopping?
    assert @lebelge.file_exists?

    @lebelge.archive!
    assert @lebelge.archived?
    assert @lebelge.file_exists?

    @lebelge.destroy
    assert !@lebelge.file_exists?
  end
end
