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
      map { |dir| dir.split('/').last }
  end
end
