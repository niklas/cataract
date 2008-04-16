class Torrent
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

  def set_metainfo
    return unless metainfo
    calculate_info_hash
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

  # Here lies the content while it is being downloaded (default)
  def working_path
    return '' unless metainfo
    File.join(Settings.torrent_dir,metainfo.name)
  end

  # where to find the contents, either saved :content_path or #working_path
  def content_path
    self[:content_path] ||= working_path
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

  def metainfo
    begin
      if !@mii and file_exists?
        @mii = RubyTorrent::MetaInfo.from_location(fullpath).info
      end
    rescue # RubyTorrent::MetaInfoFormatError
      # no UDP supprt yet
      @mii = nil
    end
    @mii
  end

  def move_content_to target_dir
    raise "must update BackgrounDRB. Work in Progress"
    begin
      unless File.exists?(content_path)
        raise TorrentContentError, "Content not found: #{content_path}"
      end
      unless File.directory?(target_dir)
        raise TorrentContentError, "Target directory does not exist: #{target_dir}"
      end
      new_path = File.join(target_dir,metainfo.name)
      if File.exists?(new_path)
        raise TorrentContentError, "Target already exists: #{new_path}"
      end
      begin
        FileUtils.ln content_path, new_path # will raise EXDEV
        FileUtils.rm new_path
        FileUtils.move content_path, new_path
        update_attribute(:content_path, new_path)
      rescue Errno::EXDEV # it is on another device, cannot move fast. use rsync in background
        MiddleMan.new_worker(:class => :torrent_mover_worker, :job_key => mover_worker_job_key)
        update_attribute(:status, 'moving')
      end



      # TODO
      # change content_path
    rescue Exception => e
      errors.add :filename, "^error on moving content: #{e.to_s}"
    end
  end

  def mover_worker_job_key
    "mover_#{self.id}".to_sym
  end

  def mover_worker
    @mover_worker ||= MiddleMan.worker(mover_worker_job_key)
  end

  def delete_content!
    return unless metainfo
    begin
      opfer = content_path
      if File.exists?(opfer) 
        rm_rf(opfer) 
        true
      else
        errors.add :filename, "^content not found: #{opfer}"
        false
      end
    rescue Exception => e
      errors.add :filename, "^error on deleting content: #{e.to_s}"
    end
  end
  def calculate_info_hash
    return unless metainfo
    metainfo.sha1.unpack('H*').first.upcase
  end

  def info_hash
    self[:info_hash] ||= calculate_info_hash
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
