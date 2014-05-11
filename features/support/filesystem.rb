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


