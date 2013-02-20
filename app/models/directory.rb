# encoding: utf-8

class Directory < ActiveRecord::Base
  has_ancestry
  # the ancestry gem defines a path method to
  alias_method :ancestry_path, :path
  include Filesystem
  before_validation :set_relative_path_from_name

  validates_presence_of :name
  validates_presence_of :disk_id
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

  # TODO attribute writer, just for ember-data
  attr_writer :path
  attr_writer :exists

  def exist?
    relative_path? && disk.present? && path.exist?
  end

  alias_method :exists?, :exist?

  def inspect
    %Q~<Directory "#{name}" #{path}>~
  end

  def to_s
    inspect
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
          copy.auto_create = true
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
