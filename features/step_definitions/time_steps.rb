Given /^today is ([^,]+)$/ do |timey|
  Timecop.travel Time.zone.parse(timey)
end

When /^(\d+) minutes? pass(?:es)?$/ do |minutes|
  Timecop.travel Time.now + minutes.to_i.minutes
end

After do
  Timecop.return
end
