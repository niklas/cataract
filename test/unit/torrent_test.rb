require File.dirname(__FILE__) + '/../test_helper'

class TorrentTest < Test::Unit::TestCase
  fixtures :torrents

  def setup
    prepare_directories
  end

  def teardown
    cleanup_directories
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
    assert @lebelge.fetch!, 'could not fetch ' + @lebelge.errors.full_messages.join(', ')
    # after that the file should lay in the history dir
    assert_equal :archived, @lebelge.current_state
    assert_kind_of String, @lebelge.fullpath
    assert !@lebelge.fullpath.empty?, 'empty path'
    assert_equal Settings.history_dir + 'lebelge.torrent', @lebelge.fullpath, 'wrong path'
    assert @lebelge.file_exists?, 'file missing'

    @lebelge.start!
    assert @lebelge.valid?, 'not valid'
    assert_equal :running, @lebelge.current_state
    assert @lebelge.running?
    assert_kind_of String, @lebelge.fullpath
    assert !@lebelge.fullpath.empty?
    assert_equal Settings.torrent_dir + 'lebelge.torrent', @lebelge.fullpath
    assert @lebelge.file_exists?

    # start again, for verpeiling users
    @lebelge.start!
    assert @lebelge.valid?, 'not valid'
    assert @lebelge.running?
    assert_equal :running, @lebelge.current_state

    @lebelge.pause!
    assert @lebelge.valid?, 'not valid'
    assert_equal :paused, @lebelge.current_state
    assert @lebelge.paused?
    assert @lebelge.file_exists? ####

    @lebelge.start!
    assert @lebelge.valid?, 'not valid'
    assert @lebelge.running?
    assert @lebelge.file_exists?

    @lebelge.stop!
    assert @lebelge.valid?, 'not valid'
    assert @lebelge.archived?
    assert @lebelge.filename
    assert @lebelge.fullpath
    assert_equal Settings.history_dir + 'lebelge.torrent', @lebelge.fullpath
    assert !File.exists?(Settings.torrent_dir + 'lebelge.torrent.stopping')
    assert File.exists?(Settings.history_dir + 'lebelge.torrent')
    assert @lebelge.file_exists?

    @lebelge.destroy
    assert !@lebelge.file_exists?
  end
end
