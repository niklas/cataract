class Disk < ActiveRecord::Base
  include Filesystem
  has_many :directories

  def self.detected_directories
    includes(:directories).all.map(&:detected_directories).flatten
  end

  # Directories not already in database
  def detected_directories
    sub_directories.reject do |on_disk|
      directories.any? { |in_db| in_db.path == on_disk }
    end.map do |path|
      directories.new(path: path)
    end
  end

end
