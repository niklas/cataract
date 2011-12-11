Given /^the following files exist on the filesystem:$/ do |table|
  table.hashes.each do |row|
    if path = row['path']
      FileUtils.mkdir_p File.dirname(path)
      File.open(path, 'w') do |file|
        file.write @files[ row['source'] ] ||
          "a non-empty file with path: '#{path}'"
      end
    end
  end
end

When /^the torrent syncer runs$/ do
  Torrent.sync
end

Before '@fakefs' do
  I18n.translate(:"warmup.fakefs")
  @files = Dir[ Rails.root.join('spec', 'factories', 'files', '*') ].inject({}) do |files, path|
    files[ File.basename(path) ] = File.read(path)
    files
  end
  Rails.logger.debug { "precached #{@files.count} files" }
  FakeFS.activate!
end

After '@fakefs' do
  FakeFS.deactivate!
end

require Rails.root/'spec/support/filesystem'

Given /^the file for #{capture_model} exists$/ do |m|
  FileSystem.create_file model!(m).path
end



