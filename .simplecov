SimpleCov.start 'rails' do
  add_group 'Decorators', 'app/decorators'
  # add_group 'Widgets', 'app/widgets'
  # does not work yet :(
  add_group 'Views', 'app/views'
  add_group 'Steps', 'features/step_definitions'
end
