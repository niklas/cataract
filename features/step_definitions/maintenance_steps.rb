When /^the ([\S]+) (?:run|work)s$/ do |maintainer_name|
  maintainer = %Q[Maintenance::#{maintainer_name}].constantize.new
  FileSystem.with_optional_fakefs do
    maintainer.work!
  end
end
