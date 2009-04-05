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

  def self.all
    find(:all).select {|dir| File.directory? dir.path }
  end

  def label
    [name,path].join(' - ')
  end

  def subdirs
    Dir[path + '/*'].
      select { |dir| File.directory? dir }.
      map { |dir| dir.split('/').last }.
      compact.
      sort || []
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

  private
  def self.mountpoints
    File.read('/etc/mtab').collect {|l| l.split[1] }.sort {|b,a| a.length <=> b.length }
  end
end
