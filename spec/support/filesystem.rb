require 'fakefs/safe'
module FileSystem
  extend self
  def file_factory_path
    app_root/'spec'/'factories'/'files'
  end

  def create_file(path)
    path = relativate path
    create_directory path.parent
    with_optional_fakefs do |enabled|
      if enabled
        File.open(path, 'w') do |file|
          file.write precached_files[ path.basename.to_s ] ||
            sample_content(path)
        end
      else
        if (file_factory_path/path.basename).exist?
          FileUtils.copy file_factory_path/path.basename, path
        else
          File.open(path, 'w') do |file|
            file.write sample_content(path)
          end
        end
      end
    end
  end

  def create_directory(path)
    path = relativate path
    with_optional_fakefs do
      FileUtils.mkdir_p path
    end
    path
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

  def precache_files!
    I18n.translate(:"provoke.loading.of.real.translations")
    @precached_files = Dir[ file_factory_path/'*' ].inject({}) do |files, path|
      files[ File.basename(path) ] = File.read(path)
      files
    end
    Rails.logger.debug { "precached #{@precached_files.length} files" }
  end

  def precached_files
    @precached_files
  end

  def with_optional_fakefs
    if @fakefs
      FakeFS do
        yield(true)
      end
    else
      yield(false)
    end
  end

  def enable_fakefs_on_demand!
    @fakefs = true
  end

  def disable_fakefs_on_demand!
    @fakefs = false
  end

  def relativate(path)
    path = Pathname.new(path) unless path.is_a?(Pathname)
    if path.relative?
      rootfs/path
    else
      path
    end
  end

  def sample_content(path=nil)
    "a non-empty file with path: '#{path}'"
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

if respond_to?(:Before)
  Before '@rootfs' do
  end

  After '@rootfs' do
  end

  After do
    FileSystem.clear_filesystem!
  end

  Before '@fakefs' do
    FileSystem.precache_files!
    FileSystem.enable_fakefs_on_demand!
  end

  After '@fakefs' do
    FileSystem.disable_fakefs_on_demand!
    FakeFS::FileSystem.clear
  end

end

