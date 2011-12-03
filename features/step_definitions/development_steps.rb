When /^I pause$/ do
  STDERR.puts "Pausing by running pry"
  binding.pry
end
