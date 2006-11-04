require File.dirname(__FILE__) + '/../test_helper'

class TorrentTest < Test::Unit::TestCase
  fixtures :torrents

  def setup
    Settings.torrent_dir = File.dirname(__FILE__) + '/../sandbox/'
    Settings.target_dir  = File.dirname(__FILE__) + '/../sandbox/__finished/'
    Settings.history_dir = File.dirname(__FILE__) + '/../sandbox/history/'
    
  end

  def test_settings_and_directories
    assert File.exists?(Settings.torrent_dir)
    assert File.exists?(Settings.target_dir)
    assert File.exists?(Settings.history_dir)
  end

  def test_fetch_and_lifecycle
    assert_equal :remote, @lebelge.current_state
    assert @lebelge.remote?
    assert @lebelge.fetchable?
    @lebelge.fetch!
    assert @lebelge.file_exists?
    @lebelge.start!
    assert_equal :running, @lebelge.current_state
    assert @lebelge.running?

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
    assert @lebelge.archived?
    assert @lebelge.file_exists?

    @lebelge.destroy
    assert !@lebelge.file_exists?
  end
end
