class Disk < ActiveRecord::Base
  validates :name, presence: true
  validates :path, presence: true

  serialize :path, Directory::Pathname.new
end
