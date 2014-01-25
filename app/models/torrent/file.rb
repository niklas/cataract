require 'mlocate'

class Torrent
  validates_uniqueness_of :filename
  validates_length_of :filename, :in => 9..255

  mount_uploader :file, TorrentUploader
  validates_length_of :file, minimum: 10.bytes, if: :path?

  validates_presence_of :metainfo?, if: :filedata?

  class FileError < ActiveRecord::ActiveRecordError; end
  class FileNotFound < FileError; end
  class HasNoMetaInfo < FileError; end
  class HasNoInfoHash < HasNoMetaInfo; end

  def path
    path? && Pathname.new(file.current_path)
  end

  def path?
    file.present? && file.current_path.present?
  end

  attr_reader :filedata
  def filedata=(data)
    return if data.blank? && !data.nil?
    if data.starts_with?('data:')
      payload = data.split(',').last
      @filedata = Base64.decode64(payload).force_encoding("ASCII-8BIT")
    else
      @filedata = data
    end
  end

  def filedata?
    filedata.present?
  end

  before_validation :set_file_from_raw_data, if: lambda { |t| t.filedata? && t.filename.present? }

  # filename and filedata must be present!
  def set_file_from_raw_data
    self.status = :archived
    self.file = ActionDispatch::Http::UploadedFile.new(filename: filename, tempfile: tempfile_for_filedata)
  end

  def tempfile_for_filedata
    Tempfile.new('ajaxupload').tap do |tempfile|
      tempfile.binmode
      tempfile << filedata
      tempfile.rewind
    end
  end

  on_refresh :refresh_file
  def refresh_file
    if !path? || !file_exists?
      if found = Mlocate.file(filename).first
        self.file = File.open(found)
      end
    end
  end

  def file_exists?
    path? && ( File.exists?(path) || file.present? )
  end

  after_destroy :remove_file

  def remove_file
    FileUtils.rm(path) if file_exists?
  rescue
    true
  end

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

  has_one :move

  def moving?
    ! move.nil?
  end

end


