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
end
