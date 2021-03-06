require 'drb'
class Torrent

  belongs_to :content_directory, :class_name => 'Directory'
  before_validation :ensure_content_directory

  attr_accessor :payload_id # for ember-data

  class TorrentContentError < Exception; end

  # TODO WTF is this for?
  def files_hierarchy
    return {} unless metainfo
    return {metainfo.name => metainfo} if metainfo.single?
    return {} unless metainfo.files
    hier = {metainfo.name => {}}
    base = hier[metainfo.name]
    metainfo.files.each do |file|
      file.path.inject(base) do |pos,component|
        pos[component] ||= {}
        pos[component] = file if component === file.path.last
        pos[component]
      end
    end
    hier
  end

  class Payload < Struct.new(:torrent)
    extend ActiveModel::Naming
    include ActiveModel::SerializerSupport

    def name
      @name ||= utf8(info.name)
    end

    def path
      @path ||= base_path.full_path/name
    end

    def base_path
      torrent.content_directory
    end

    def info
      @info ||= torrent.metainfo
    end

    def single?
      info.single?
    end

    def multiple?
      !single?
    end

    def exists?
      base_path.present? && name.present? && File.exists?(path)
    rescue HasNoMetaInfo => e
      false
    end

    alias exist? exists?

    def files
      if single?
        [ path ]
      else
        info.files.map do |file|
          path/utf8(file.path.first)
        end
      end
    rescue HasNoMetaInfo => e
      []
    end

    def relative_files
      if single?
        [ name ]
      else
        info.files.map do |file|
          "#{name}/#{utf8 file.path.first}"
        end.sort
      end
    rescue HasNoMetaInfo => e
      []
    end

    alias :filenames :relative_files

    def count
      if single?
        1
      else
        info.files.count
      end
    end

    def size
      if single?
        info.length
      else
        info.files.map(&:length).reduce(:+)
      end
    rescue HasNoMetaInfo => e
      -1
    end

    def actual_size
      `du --bytes '#{path.to_path.escape_quotes}' 2>/dev/null`.to_i
    rescue
      0
    end

    def torrent_id
      torrent.id
    end

    def destroy
      torrent.stop
      if exists?
        FileUtils.rm_rf path
      else
        torrent.errors.add :payload, :blank
      end
    end

    # returns the directory all the contents are in
    def locate
      if single?
        Directory.with_minimal_infix Mlocate.file(name).first
      else
        chosen = relative_files.last
        dir, infix = Directory.with_minimal_infix Mlocate.postfix(chosen).first
        if dir
          chosen = ::Pathname.new(chosen).dirname
          index  = ::Pathname.new(infix)
          while chosen.basename == index.basename && index.to_s != '.'
            index  = index.dirname
            chosen = chosen.dirname
          end
          if index.to_s == '.'
            return dir, ''
          else
            return dir, index.to_s
          end
        end
      end
    end

    private
    def utf8(string)
      string.encode('UTF-8')
    rescue
      string.force_encoding('UTF-8')
    end
  end

  class Deletion < HashWithIndifferentAccess
    include ActiveAttr::Model
    include ActiveAttr::AttributeDefaults

    attribute :delete_payload
    attribute :torrent

    def save
      if delete_payload?
        torrent.payload.destroy
      end
      torrent.stop! if torrent.stoppable?
      torrent.destroy
    end
  end

  def build_deletion(params={})
    @deletion ||= Deletion.new(params.merge(torrent: self))
  end

  def payload
    @payload ||= Payload.new(self)
  end
  attr_writer :payload_exists # FIXME ember does not support read-only attributes

  def ensure_content_directory
    self.content_directory ||= Setting.singleton.incoming_directory || Directory.watched.first || Directory.first
  end

  on_refresh :find_missing_content, :if => :metainfo?
  def find_missing_content
    unless payload.exists?
      dir, infix = payload.locate
      if dir
        self.content_directory = dir
        self.content_path_infix = infix.to_s
      end
    end
  end


  # TODO direct links to content
  # returns the current url to the content for the user
  # the user has to specify his moutpoints for that to happen
  def content_url(usr)
    return nil # FIXME we have no target_dir anymore
    return nil unless metainfo
    if archived?
      return File.join(usr.target_dir_mountpoint,metainfo.name) if usr.target_dir_mountpoint
    else
      return File.join(usr.content_dir_mountpoint,metainfo.name) if usr.content_dir_mountpoint
    end
    return nil
  end

  on_refresh :cache_content_size, :if => :metainfo?
  def cache_content_size
    self.content_size = payload.size
  end

  on_refresh :cache_content_filenames, :if => :metainfo?
  def cache_content_filenames
    self.content_filenames = payload.relative_files
  end

  def mover_job_key
    "mover_#{self.id}"
  end

  def job_manager
    @job_manager ||= DRbObject.new(nil, Settings.queue_manager_url)
  end

  def moving_progress
    job_manager.status_for(mover_job_key)[:progress]
  end

  # for fuse
  def content_root
    if content_single?
      content_filenames
    else
      content_filenames.map {|f| f.gsub /^.*?\//, ''} # strip the leading directory name
    end
  end

  def content_single?
    content_filenames.size == 1
  end

  def content_size
    read_attribute(:content_size) || payload.size
  end

  def has_files?
    !self[:content_filenames].blank?
  end

  serialize :content_filenames, Array
 
end
