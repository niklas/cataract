require File.dirname(__FILE__) + '/../test_helper'
require 'lib/fileutils_monkeypatch'

class File
  def self.touch(filename)
    File.open(filename,'w') do |f|
    end
  end

end

class FileUtilsTest < Test::Unit::TestCase
  @@other_filesystem = '/tmp/catatact_test/'

  def setup
    prepare_directories
    Dir.mkdir @@other_filesystem unless File.directory?(@@other_filesystem)
    @sandbox = Settings.torrent_dir
    @richdir = @sandbox + 'richdir/'
    @target1 = @sandbox + 'richdir2'
    @target2 = @@other_filesystem + 'richdir'
    Dir.mkdir @richdir
    Dir.mkdir @richdir + 'foo'
    File.touch @richdir + 'foo/' + 'bar1'
    File.touch @richdir + 'foo/' + 'bar2'
    File.touch @richdir + 'foo/' + 'bar3'
    Dir.mkdir @richdir + '1'
    File.touch @richdir + '1/' + '23'
    File.touch @richdir + '1/' + '5'
    File.touch @richdir + '1/' + '42'
  end

  def teardown
    [@richdir,@target1,@target2,@@other_filesystem].each do |d|
      d += '/' unless d.last == '/'
      delete_if_exists d + '/1/' + '42'
      delete_if_exists d + '/1/' + '5'
      delete_if_exists d + '/1/' + '23'
      delete_if_exists d + '/1'
      delete_if_exists d + '/foo/' + 'bar3'
      delete_if_exists d + '/foo/' + 'bar2'
      delete_if_exists d + '/foo/' + 'bar1'
      delete_if_exists d + '/foo'
      delete_if_exists d
    end
  end

  def test_should_move_in_same_filesystem
    all_things_there(@richdir)
    FileUtils.move(@richdir,@target1)
    all_things_there(@target1)
  end

  def test_should_move_between_different_filesystems
    all_things_there(@richdir)
    FileUtils.move(@richdir,@target2)
    all_things_there(@target2)
  end

  def all_things_there(base)
    base += '/' unless base.last == '/'
    assert File.exist?(base)
    assert File.exist?(base + '/foo')
    assert File.exist?(base + '/foo/' + 'bar1')
    assert File.exist?(base + '/foo/' + 'bar2')
    assert File.exist?(base + '/foo/' + 'bar3')
    assert File.exist?(base + '/1')
    assert File.exist?(base + '/1/' + '23')
    assert File.exist?(base + '/1/' + '5')
    assert File.exist?(base + '/1/' + '42')
  end

  def delete_if_exists(filename)
    File.delete(filename) if File.exist?(filename)
  rescue Errno::EISDIR
    Dir.rmdir(filename)
  end

end
