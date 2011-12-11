class Torrent
  belongs_to :directory, :inverse_of => :torrents
  validates_presence_of :directory, :if => :filename?

  class FileError < ActiveRecord::ActiveRecordError; end
  class FileNotFound < FileError; end
  class HasNoInfoHash < FileError; end

  # FIXME serialize in #path as Pathname
  def pathname
    directory.path.join(filename)
  end

  def path
    pathname.to_s
  end

  def file_exists?(stat=current_state)
    # cannot us pathname because fakefs does not fake it :(
    filename.present? && File.exists?(path)
  end

  after_destroy :remove_file

  def remove_file
    FileUtils.rm(path) if file_exists?
  rescue
    true
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
    else
      raise FileNotFound.new("file does not exist: #{path}")
    end
  rescue Errno::ENOENT => e
    raise FileNotFound.new(e.message)
  #rescue # RubyTorrent::MetaInfoFormatError
  #  # no UDP supprt yet
  #  @mii = nil
  #  raise HasNoInfoHash.new()
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


