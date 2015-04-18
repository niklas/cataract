When /^the ([A-Z][a-z]+) is worked on in background$/ do |name|
  jobs = name.constantize
  jobs.all.each do |job|
    job.work!
  end
  sleep 5 # give it some time
end
