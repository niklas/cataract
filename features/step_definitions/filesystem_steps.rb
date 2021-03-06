require Rails.root/'spec/support/filesystem'

Given /^the file for #{capture_model} exists$/ do |m|
  step %Q~the file "#{model!(m).path}" exists on disk~
end

Given /^the following filesystem structure exists on disk:$/ do |table|
  table.hashes.each do |row|
    step %Q~the #{row['type']} "#{row['path']}" exists on disk~
  end
end

Given /^the (file|directory) "([^"]+)" exists on disk$/ do |type, path|
  FileSystem.send(:"create_#{type}", Pathname.new(path) )
end

Then /^the following filesystem structure should be missing on disk:$/ do |table|
  table.hashes.each do |row|
    step %Q~the #{row['type']} "#{row['path']}" should not exist on disk~
  end
end

Then /^the following filesystem structure should (?:still )?exist on disk:$/ do |table|
  table.hashes.each do |row|
    step %Q~the #{row['type']} "#{row['path']}" should exist on disk~
  end
end

Then /^the (file|directory) "([^"]+)" should exist on disk$/ do |type, path|
  FileSystem.with_optional_fakefs do
    FileSystem.relativate(path).should send(:"exist_as_#{type}")
  end
end

Then /^the (file|directory) "([^"]+)" should not exist on disk$/ do |type, path|
  FileSystem.with_optional_fakefs do
    FileSystem.relativate(path).should_not send(:"exist_as_#{type}")
  end
end

# deserialize columns. [foo/bar,baz] => ["foo/bar", "baz"]
%w(content_filenames).each do |column|
  Transform /^table:(?:.*,)?#{column}(?:,.*)?$/ do |table|
    table.map_column!(column) do |serialized|
      if serialized.is_a?(Array)
        serialized # this transform is executed twice?!
      else
        if serialized =~ /^\[(.*)\]$/
          $1.split(',').map(&:strip)
        else
          serialized
        end
      end
    end
  end
end


Given /^the file "([^"]*)" is deleted$/ do |file|
  if file.start_with?('/')
    raise ArgumentError, "only relative paths please"
  end
  if File.exist?(file)
    FileUtils.rm(file)
  end
end

Given /^#{capture_model}'s (?:content|payload) exists on disk$/ do |m|
  model!(m).payload.files.each do |path|
    step %Q~the file "#{path}" exists on disk~
  end
end

Then /^the file "([^"]*)" should contain exactly:$/ do |file, content|
  file.should exist_as_file
  File.read(file).should == content
end

Then /^#{capture_model}'s content (should not|should) exist on disk$/ do |m, should_or_not|
  step %Q~the file "#{model!(m).payload.path}" #{should_or_not} exist on disk~
end

Then /^#{capture_model}'s file (should not|should) exist on disk$/ do |m, should_or_not|
  step %Q~the file "#{model!(m).path}" #{should_or_not} exist on disk~
end

Given /^the URL "([^"]*)" points to file "([^"]*)"$/ do |url, file|
  content = File.read( FileSystem.file_factory_path/file )
  stub_request(:get, url).to_return(status: 200, body: content)
end

Given /^the URL "([^"]*)" points to the following content:$/ do |url, content|
  stub_request(:get, url).to_return(status: 200, body: content)
end

Given /^the following disks are mounted:$/ do |table|
  paths = table.hashes.map do |row| 
    if r = row['path']
      r
    elsif r = row['disk']
      model!(r).path.to_s
    end
  end
  if paths.empty?
    raise ArgumentError, 'please provide a table with row headed "path" or "disk"'
  end
  created = paths.map do |path|
    FileSystem.create_directory Pathname.new(path)
  end
  Disk.stub(:detected_paths).and_return created.map(&:to_s)
end
