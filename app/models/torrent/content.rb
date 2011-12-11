require 'drb'
class Torrent
  extend ActiveSupport::Memoizable
  class TorrentContentError < Exception; end
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


  # Here lies the content while it is being downloaded (default)
  # FIXME respect #directory
  def working_path
    return '' unless metainfo
    File.join(Settings.torrent_dir,metainfo.name)
  end

  class Content < Struct.new(:torrent)
    def path
      base_path.path/info.name
    end

    def base_path
      torrent.content_directory
    end

    def info
      torrent.metainfo
    end
  end

  belongs_to :content_directory, :class_name => 'Directory'

  def content
    @content ||= Content.new(self)
  end

  # minimal path for content. Path has at least one more component than its #directory
  def content_path
    content.path
  end

  def content_exists?
    !content_path.blank? && File.exists?(content_path)
  end
  memoize :content_exists?

  def download_path
    content_path.sub(%r(/[^/]*$),'')
  end

  def content_dir_name
    d = Directory.base_of content_path
    d ? d.name : '-unknown-'
  end


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

  def set_content_information
    return unless metainfo
    self[:content_size] = if metainfo.single?
      metainfo.length
    else
      metainfo.files.inject(0) { |sum, f| sum + f.length}
    end
    self[:content_filenames] = 
      if metainfo.single?
        [metainfo.name]
      else
        metainfo.files.map { |f| File.join(metainfo.name, f.path)}
      end
  end


  def move_content_to target_dir
    begin
      unless File.exists?(content_path)
        update_attribute(:content_path, nil)
        raise TorrentContentError, "Content not found: #{content_path}"
      end
      unless File.directory?(target_dir)
        raise TorrentContentError, "Target directory does not exist: #{target_dir}"
      end
      new_path = File.join(target_dir,metainfo.name)
      if File.exists?(new_path)
        raise TorrentContentError, "Target already exists: #{new_path}"
      end
      stop! if running?
      finally_stop!
      if Directory.new(:path => new_path).is_on_same_drive?(content_path)
        FileUtils.move content_path, new_path
        update_attribute(:content_path, new_path)
      else
        job_manager.create_job(:torrent_mover,mover_job_key,self.id,new_path)
        self.status = :moving
      end
#    rescue Exception => e
#      errors.add :filename, "^error on moving content: #{e.to_s}"
    end
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

  def delete_content!
    return unless metainfo
    begin
      opfer = content_path
      if File.exists?(opfer) 
        rm_rf(opfer) 
        true
      else
        errors.add :files, "^content not found: #{opfer}"
        false
      end
    rescue Exception => e
      errors.add :files, "^error on deleting content: #{e.to_s}"
      false
    end
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
    self[:content_size].to_i
  end

  def has_files?
    !self[:content_filenames].blank?
  end

  def content_filenames
    @content_filenames ||= YAML.load(self[:content_filenames])
  rescue TypeError
  end


 
end
