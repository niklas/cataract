# == Schema Information
# Schema version: 36
#
# Table name: directories
#
#  id            :integer       not null, primary key
#  name          :string(255)   
#  path          :string(2048)  
#  created_at    :datetime      
#  updated_at    :datetime      
#  show_sub_dirs :boolean       
#

class Directory < ActiveRecord::Base
  has_ancestry
  # the ancestry gem defines a path method to
  alias_method :ancestry_path, :path
  include Filesystem
  before_validation :set_relative_path_from_name

  validates_presence_of :name
  validates_uniqueness_of :relative_path, scope: :disk_id

  validates_predicate :relative_path, :relative?
  validates_predicate :path, :absolute?

  after_save :create_on_filesystem, :on => :create, :if => :auto_create?
  attr_accessor :auto_create
  def auto_create?
    auto_create.present?
  end
  def create_on_filesystem
    FileUtils.mkdir_p path
  end

  # TODO validate path is on disk
  # FIXME assign directories to disks through rake task
  belongs_to :disk
  validates_presence_of :disk

  # end of scope to show all directies by name, leaving out duplicate copies in different disks
  def self.ignoring_copies
    all.group_by(&:name).map { |name, directories| directories.sort_by(&:disk_id).first }
  end

  def path
    disk.path + (relative_path || name)
  rescue NoMethodError => e
    nil
  end

  def exist?
    relative_path? && disk.present? && path.exist?
  end

  def name
    super.presence || (relative_path? && relative_path.basename.to_s)
  end

  def copies
    self.class.where(relative_path: relative_path.to_s).where('id != ?', id)
  end

  validates_presence_of :filter, if: :subscribed?
  def regexp
    Regexp.new filter, true
  end


  has_many :torrents

  def contains_torrents_with_content?
    !torrent_search.results.empty?
  end

  def torrent_search
    @torrent_search ||= Torrent.new_search(directory_id: id)
  end

  def set_relative_path_from_name
    unless relative_path?
      self.relative_path = name
    end
  end

  # Directories not already in database
  def detected_directories
    sub_directories.reject do |on_disk|
      children.any? { |in_db| in_db.path == on_disk }
    end.map do |found|
      children.new(relative_path: found.relative_path_from(disk.path), disk: disk, name: found.basename.to_s)
    end
  end

  def default!
    if filter.blank?
      self.filter = name
    end
  end

  def self.all_paths(opts={})
    find(:all, opts).select {|dir| File.directory? dir.path }
  end

  def self.base_of(path)
    d = nil
    while path != '/' && !(d = find_by_path(path))
      path = File.dirname(path)
    end
    d
  end

  # finds the directory of the path, no infixes allowed
  def self.of(path)
    dir, infix = with_minimal_infix(path)

    if dir && infix.to_path == '.'
      dir
    else
      nil
    end
  end

  def self.with_minimal_infix(path)
    return nil if path.nil?
    path = ::Pathname.new( path )
    all.map { |dir| [dir,
                     path.dirname.relative_path_from(dir.path)
                   ] rescue nil }
       .compact
       .sort_by { |dir, infix| infix.to_s.length }
       .first
  end

  def label
    [name,path.to_s].join(' - ')
  end

  def subdir_names
    subdirs
  end

  def self.for_series
    find_by_name('Serien')
  end

  def self.for_movies
    find_by_name('Filme')
  end

  def self.for_music
    find_by_name('Musik')
  end

  def self.watched
    where(:watched => true)
  end

  def self.subscribed
    where(:subscribed => true)
  end

  # side info
  def df
    cmd = '/bin/df'
    if File.exists?(path) and File.exists?(cmd)
      `#{cmd} '#{path}'`.split[10].to_i
    else
      0
    end
  end

  def usage_percent
    cmd = '/bin/df'
    if File.exists?(path) and File.exists?(cmd)
      `#{cmd} '#{path}'`.split[11].to_i
    else
      0
    end
  end

  def self.disksfree
    %w(torrent_dir).
      inject({}) { |hsh,dir| hsh.merge({ dir => Torrent.diskfree(Settings[dir]) }) }
  end

  def path_with_optional_subdir(subdir)
    if !subdir.blank? && subdirs.include?(subdir)
      if File.directory?(rpath = File.join(path, subdir))
        rpath
      else
        path
      end
    else
      path
    end
  end

  def is_on_same_drive?(otherdir)
    otherdir = self.class.new(:path => otherdir) if otherdir.is_a? String
    self.mountpoint == otherdir.mountpoint
  end

  def mountpoint
    self.class.mountpoints.find do |mountpoint|
      escaped = Regexp.quote(mountpoint+'/')
      (self.path + '/') =~ /^#{escaped}/
    end
  end

  def contains_torrent?(torrent)
    torrent.path.to_s.starts_with? path
  end

  def self.subdirs_by_id
    all(:conditions => {:show_sub_dirs => true}).
      map {|d| !d.subdirs.empty? ? { d.id => d.subdirs } : nil }.
      compact.
      inject(&:merge)
  end

  def self.find_or_create_by_directory_and_disk(directory, disk)
    if directory.disk == disk
      directory
    else
      if existing = by_relative_path(directory.relative_path).where(disk_id: disk.id).first
        existing
      else
        directory.dup.tap do |copy|
          copy.disk = disk
          copy.auto_create = true
          unless directory.is_root?
            copy.parent = find_or_create_by_directory_and_disk(directory.parent, disk)
          end
          copy.save!
        end
      end
    end
  end

  private
  def self.mountpoints
    File.read('/etc/mtab').collect {|l| l.split[1] }.sort {|b,a| a.length <=> b.length }
  end
end

DirectoryDecorator
