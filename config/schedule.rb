every 20.minutes do
  runner 'Maintenance::Recognizer.new.work'
end
