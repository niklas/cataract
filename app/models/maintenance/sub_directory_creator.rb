class Maintenance::SubDirectoryCreator < Maintenance::Base

  def work
    Directory.where(:show_sub_dirs => true).each do |dir|
      db = dir.children.map(&:path)
      dir.sub_directories.each do |sub|
        unless db.include?(sub)
          dir.children.create! :path => sub
        end
      end
    end
  end

end
