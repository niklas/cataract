module FileSystem
  extend self
  def file_factory_path
    app_root/'spec'/'factories'/'files'
  end

  def create_file(path)
    create_directory path.parent
    FileUtils.copy file_factory_path/path.basename, path
  end

  def create_directory(path)
    FileUtils.mkdir_p path
  end

  def rootfs
    app_root/'tmp'/'rootfs'
  end

  def clear_filesystem!
    FileUtils.rm_rf(rootfs) if rootfs.exist?
  end

  def app_root
    (Pathname.new(__FILE__)/'..'/'..'/'..').tap do |root|
      unless Rails.root == root
        raise "strange Rails.root: #{Rails.root} vs #{root}" 
      end
    end
  end
end

RSpec::Matchers.define :exist_as_directory do
  match { |actual| File.directory?(actual.to_s) }
end
RSpec::Matchers.define :exist_as_file do
  match { |actual| File.file?(actual.to_s) }
end

RSpec.configure do |config|
  config.include FileSystem
  config.after :each do
    FileSystem.clear_filesystem!
  end
end

if defined?(World)

  Before '@rootfs' do
  end

  After '@rootfs' do
  end

  After do
    FileSystem.clear_filesystem!
  end
end

