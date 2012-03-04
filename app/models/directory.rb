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

  after_save :create_on_filesystem, :on => :create, :if => :auto_create?
  attr_accessor :auto_create
  def auto_create?
    auto_create.present?
  end
  def create_on_filesystem
    FileUtils.mkdir_p path
  end

  has_many :torrents

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

  def self.of(*paths)
    paths.each do |found|
      if dir = find_by_path( File.dirname(found) )
        return dir
      end
    end
    return nil
  end

  def label
    [name,path.to_s].join(' - ')
  end

  def name
    super.presence || path.basename.to_s.capitalize
  end

  def sub_directories
    glob('*')
      .select { |dir| File.directory? dir }
      .sort
      .map    { |dir| ::Pathname.new(dir) }
  end

  def subdir_names
    subdirs
  end

  def glob(pattern)
    Dir[ path/pattern ]
  end

  class Pathname
    def load(text)
      return unless text
      ::Pathname.new(text)
    end

    def dump(pathname)
      pathname.to_s
    end
  end

  # the ancestry gem defines a path method to
  alias_method :ancestry_path, :path
  serialize :path, Pathname.new
  def path=(new_path)
    if new_path.is_a?(::Pathname)
      super new_path
    else
      super ::Pathname.new(new_path.to_s)
    end
  end
  def path
    read_attribute(:path)
  end

  validates_each :path do |record, attr, value|
    record.errors.add attr, "is not absolute" unless value.absolute?
  end
  validates :path, :uniqueness => true


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

  def self.physical_uniq
    all.group_by(&:mountpoint).keys.compact.map {|path| Directory.new(:path => path, :name => File.basename(path))}
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
    torrent.content_path.starts_with? path
  end

  def self.subdirs_by_id
    all(:conditions => {:show_sub_dirs => true}).
      map {|d| !d.subdirs.empty? ? { d.id => d.subdirs } : nil }.
      compact.
      inject(&:merge)
  end

  private
  def self.mountpoints
    File.read('/etc/mtab').collect {|l| l.split[1] }.sort {|b,a| a.length <=> b.length }
  end
end
