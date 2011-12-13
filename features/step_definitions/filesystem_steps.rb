Before '@fakefs' do
  FileSystem.precache_files!
  FakeFS.activate!
end

After '@fakefs' do
  FakeFS.deactivate!
end

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

Then /^the following filesystem structure should exist on disk:$/ do |table|
  table.hashes.each do |row|
    step %Q~the #{row['type']} "#{row['path']}" should exist on disk~
  end
end

Then /^the (file|directory) "([^"]+)" should exist on disk$/ do |type, path|
  path.should send(:"exist_as_#{type}")
end

Then /^the (file|directory) "([^"]+)" should not exist on disk$/ do |type, path|
  path.should_not send(:"exist_as_#{type}")
end

