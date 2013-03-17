SimpleCov.start 'rails' do
  add_filter '/spec/'
  add_filter '/features/support'

  add_group 'Controllers', 'app/controllers'
  add_group 'Models', 'app/models'
  add_group 'Libraries', 'lib'
  add_group 'Helpers', 'app/helpers'
  add_group 'Views', 'app/views'
  add_group 'Steps', 'features/step_definitions'
  add_group 'Serializers', 'app/serializers'

  add_filter 'vendor'
  filters.delete_if { |f| f.filter_argument == '/features/' }
end
