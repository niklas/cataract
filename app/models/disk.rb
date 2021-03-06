# encoding: utf-8
class Disk < ActiveRecord::Base
  include Filesystem
  has_many :directories
  before_validation :set_name_from_path

  validates_predicate :path, :absolute?

  def self.detected_directories
    includes(:directories).all.map(&:detected_directories).flatten
  end

  def self.detected_paths
    File.read('/etc/mtab')
      .lines
      .map { |line| line.split.second }
  end

  def self.detected
    detected_paths
      .grep(%r(/media/))
      .reject do |on_disk|
        find_by_path(on_disk)
      end.sort
      .map do |path|
        new path: path
      end
  end

  def self.find_or_create_by_path(path)
    raise NotImplementedError
  end

  # Directories not already in database
  def detected_directories
    sub_directories.reject do |on_disk|
      directories.any? { |in_db| in_db.full_path == on_disk }
    end.map do |found|
      directories.new(relative_path: found.relative_path_from(path), name: found.basename.to_s)
    end
  end

  def find_or_create_root_directory_by_basename!(dir)
    raise(ArgumentError, "must give a path with only one component, gave #{dir}") if Pathname.new(dir).relative_components.length != 1
    directories.roots.by_relative_path(dir).first || directories.create!(relative_path: dir)
  end

  def set_name_from_path
    if path? and read_attribute(:name).blank?
      self.name = name_from_path
    end
  end

  def name_from_path
    path.basename.to_s if path?
  end

  def name
    super.presence || name_from_path
  end

  def exist?
    path? && path.exist?
  end

  def mounted?
    self.class.detected_paths.include?(path.to_s)
  end

end

DiskDecorator
