require 'mlocate'

class Torrent
  belongs_to :directory, :inverse_of => :torrents
  validates_presence_of :directory, :if => :filename?, :unless => :remote?

  validates_uniqueness_of :filename, :unless => :remote?
  validates_length_of :filename, :in => 9..255, :unless => :remote?

  class FileError < ActiveRecord::ActiveRecordError; end
  class FileNotFound < FileError; end
  class HasNoMetaInfo < FileError; end
  class HasNoInfoHash < HasNoMetaInfo; end

  def path
    directory.path/filename
  end

  def path?
    filename.present? && directory.present?
  end

  on_refresh :refresh_file
  def refresh_file
    if path? && !file_exists?
      Mlocate.locate(file: filename).each do |found|
        if dir = Directory.find_by_path( File.dirname(found) )
          self.directory = dir
        end
      end
    end
  end

  def file_exists?
    path? && File.exists?(path)
  end

  after_destroy :remove_file

  def remove_file
    FileUtils.rm(path) if file_exists?
  rescue
    true
  end

  before_validation :ensure_directory, :unless => :directory
  def ensure_directory
    self.directory ||= Directory.watched.first || Directory.first
  end

  validates_each :path, :if => :path? do |record, attr, value|
    begin
      record.errors.add attr, :empty if File.size(value.to_path) < 10
    rescue Errno::ENOENT => e
    end
  end

  before_validation :set_info_hash_from_metainfo, :unless => :info_hash?
  validates_format_of :info_hash, :with => /[0-9A-F]{40}/, :unless => :remote?

  # we must open the BStream manually because FakeFS and open-uri in MetaInfo.from_location collide
  def metainfo
    return @mii unless @mii.nil?
    if file_exists?
      File.open path, 'rb' do |file|
        stream = RubyTorrent::BStream.new file
        @mii = RubyTorrent::MetaInfo.from_bstream( stream ).info
      end
    elsif downloaded?
      StringIO.open download.payload, 'r'do |stream|
        @mii = RubyTorrent::MetaInfo.from_stream(stream).info
      end
    else
      raise HasNoMetaInfo.new("no source for metainfo found")
    end
  rescue Errno::ENOENT => e
    raise FileNotFound.new(e.message)
  rescue RubyTorrent::MetaInfoFormatError => e
    logger.debug { "could not set info hash from metainfo: #{e.message}" }
    @mii = nil
    raise HasNoInfoHash.new(e.message)
  end

  def metainfo?
    metainfo.present?
  rescue Torrent::HasNoMetaInfo => e
    return false
  end


  def set_info_hash_from_metainfo
    write_attribute :info_hash, info_hash_from_metainfo
  rescue FileError => e
    logger.debug { "could not set info hash from metainfo: #{e.message}" }
  end

  def info_hash_from_metainfo
    metainfo.sha1.unpack('H*').first.upcase
  end

  has_one :move

end


