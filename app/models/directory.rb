# encoding: utf-8

class Directory < ActiveRecord::Base
  has_ancestry
  #include Filesystem
  before_validation :process_path
  before_validation :set_disk_from_parent, unless: :disk
  before_validation :set_name_from_provided_paths
  after_save :create_intermediate_directories

  # FIXME assign directories to disks through rake task
  belongs_to :disk

  validates_presence_of :name
  validates_presence_of :disk_id
  validates_uniqueness_of :name, scope: :ancestry

  # FIXME better put these validations back in
  #validates_predicate :relative_path, :relative?
  #validates_predicate :full_path, :absolute?

  after_save :create_on_filesystem, :on => :create, :unless => :virtual?
  attr_accessor :virtual
  def virtual?
    virtual.in?(['1', 1, true, 'true'])
  end
  def create_on_filesystem
    FileUtils.mkdir_p full_path
  end

  # end of scope to show all directies by name, leaving out duplicate copies in different disks
  def self.ignoring_copies
    all.group_by(&:name).map { |name, directories| directories.sort_by(&:disk_id).first }
  end

  def full_path
    disk.path.join(relative_path)
  end

  # TODO remove table column 'relative_path'
  def relative_path
    if parent.present?
      ancestors.map(&:name).inject(Pathname.new(''), &:join).join(name)
    else
      name
    end
  end

  # TODO attribute writer, just for ember-data
  attr_writer :exists

  def exist?
    relative_path? && disk.present? && full_path.exist?
  end

  alias_method :exists?, :exist?

  def inspect
    %Q~<Directory "#{name}" #{full_path rescue '[[bad full_path]]'}>~
  end

  def to_s
    inspect
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

  #########################################################
  # creation
  #########################################################
  class PathInvalid < Exception; end

  def full_path=(new_path)
    @full_path = Pathname.new(new_path)
  end
  def relative_path=(new_path)
    @relative_path = Pathname.new(new_path)
  end

  def process_path
    if @full_path.present?
      unless @full_path.absolute?
        raise(PathInvalid, "#{@full_path.inspect} is not absolute")
      end
      if @relative_path.present?
        raise(PathInvalid, "gave both relative and full path")
      end

      if disk.blank? || !@full_path.starts_with?(disk.path)
        self.disk = Disk.find_or_create_by_path(@full_path)
        self.relative_path = @full_path.relative_path_from(disk.path)
      end
    end
  end

  def create_intermediate_directories
    if @dirname.present?
      if parent.present?
        while @dirname.more_than_basename?
          first, @dirname = @dirname.split_first
          self.parent = parent.find_or_create_child_by_name!(first)
        end
        self.parent = parent.find_or_create_child_by_name!(@dirname.to_s)
        @dirname = nil
      end
    end
  end

  def set_name_from_provided_paths
    if @full_path.present?
      self.name ||= @full_path.basename.to_s
      @dirname = @full_path.dirname
      @full_path = nil
    end
    if @relative_path.present?
      self.name ||= @relative_path.basename.to_s
      @dirname = @relative_path.dirname
      @relative_path = nil
    end
  end

  def set_disk_from_parent
    if parent
      self.disk = parent.disk
    end
  end

  def find_or_create_child_by_name!(child_name)
    children.where(name: child_name).first ||
      children.create!(name: child_name, disk: disk)
  end

  # Directories not already in database
  def detected_directories
    sub_directories.reject do |on_disk|
      children.any? { |in_db| in_db.path == on_disk }
    end.map do |found|
      children.new(relative_path: found.relative_path_from(disk.path), disk: disk, name: found.basename.to_s)
    end
  end

  # OPTIMIZE duplicated in Ember model
  def default!
    if filter.blank?
      self.filter = name
    end
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

  def self.watched
    where(:watched => true)
  end

  def self.subscribed
    where(:subscribed => true)
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
          copy.virtual = false
          unless directory.is_root?
            copy.parent = find_or_create_by_directory_and_disk(directory.parent, disk)
          end
          copy.save!
        end
      end
    end
  end
end

DirectoryDecorator
