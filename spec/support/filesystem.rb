module FileSystemSpecHelper
  def file_factory_path
    Rails.root/'spec'/'factories'/'files'
  end

  def create_file(path)
    FileUtils.copy file_factory_path/path.basename, path
  end

  def create_directory(path)
    FileUtils.mkdir_p path
  end

  def rootfs
    Rails.root/'tmp'/'rootfs'
  end
end

RSpec::Matchers.define :exist_as_directory do
  match { |actual| File.directory?(actual.to_s) }
end
RSpec::Matchers.define :exist_as_file do
  match { |actual| File.file?(actual.to_s) }
end

include FileSystemSpecHelper
