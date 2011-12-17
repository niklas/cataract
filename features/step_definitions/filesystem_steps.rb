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

