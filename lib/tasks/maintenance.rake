namespace :maintenance do

  desc "Assigns disks to directories"
  task :assign_disks_to_directories => :environment do
    disks = Disk.all
    Directory.where(disk_id: nil).find_each do |directory|
      if disk = disks.find { |d| directory.relative_path.to_s.starts_with?(d.path.to_s + '/') }
        directory.disk = disk
        directory.relative_path = directory.relative_path.relative_path_from disk.path
        directory.save!
      end
    end
  end

  task :relativate_directories => :assign_disks_to_directories do
    disks = Disk.all
    Directory.find_each do |directory|
      if directory.path.present? && directory.relative_path.absolute?
        directory.relative_path = directory.relative_path.relative_path_from directory.disk.path
        directory.save!
      end
    end

  end
end
