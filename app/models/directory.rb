# == Schema Information
# Schema version: 35
#
# Table name: directories
#
#  id         :integer       not null, primary key
#  name       :string(255)   
#  path       :string(2048)  
#  created_at :datetime      
#  updated_at :datetime      
#

class Directory < ActiveRecord::Base
end
