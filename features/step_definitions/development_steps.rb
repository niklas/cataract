When /^I pause$/ do
  STDERR.puts "Pausing..."
  if system(%Q~zenity --question --text="Paused. Want to pry?"~)
    binding.pry
  end
end

When /^nothing$/ do
  # for scenario outlines
end
