every 20.minutes do
  runner 'Maintenance::Recognizer.new.work'
end

every 2.hours do
  runner 'Maintenance::CachePayloadExists.new.work'
end
