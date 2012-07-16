# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard 'spork', :cucumber_env => { 'RAILS_ENV' => 'test' }, :rspec_env => { 'RAILS_ENV' => 'test' }, :test_unit => false, :wait => 120 do
  watch('config/application.rb')
  watch('config/environment.rb')
  watch(%r{^config/environments/.+\.rb$})
  watch(%r{^config/initializers/.+\.rb$})
  watch('Gemfile.lock')
  watch('spec/spec_helper.rb')
  watch('test/test_helper.rb')
  watch('features/support/env.rb')
end unless ENV['NO_SPORK']

group :test, :halt_on_fail => true do

  guard 'rspec', :cli => '--drb --color', :version => 2, :run_all => { :cli => "--color" }, :all_on_start => false do
    watch(%r{^spec/.+_spec\.rb$})
    watch(%r{^lib/(.+)\.rb$})     { |m| "spec/lib/#{m[1]}_spec.rb" }
    watch('spec/spec_helper.rb')  { "spec" }
    watch(%r{^spec/factories/.+$}) { 'spec' }

    # Rails example
    watch(%r{^spec/.+_spec\.rb$})
    watch(%r{^app/(.+)\.rb$})                           { |m| "spec/#{m[1]}_spec.rb" }
    watch(%r{^lib/(.+)\.rb$})                           { |m| "spec/lib/#{m[1]}_spec.rb" }
    # we (will) use cucumber extensivly
    # watch(%r{^app/controllers/(.+)_(controller)\.rb$})  { |m| ["spec/routing/#{m[1]}_routing_spec.rb", "spec/#{m[2]}s/#{m[1]}_#{m[2]}_spec.rb", "spec/acceptance/#{m[1]}_spec.rb"] }
    watch(%r{^spec/support/(.+)\.rb$})                  { "spec" }
    watch('spec/spec_helper.rb')                        { "spec" }
    watch('config/routes.rb')                           { "spec/routing" }
    watch('app/controllers/application_controller.rb')  { "spec/controllers" }
    # Capybara request specs
    watch(%r{^app/views/(.+)/.*\.(erb|haml)$})          { |m| "spec/requests/#{m[1]}_spec.rb" }
  end

#                                                         V --no-drb skip spork to run simplecov 
  guard 'cucumber', :cli => "--drb --no-source --no-profile --strict --format pretty --format rerun --out rerun.txt", :run_all => { :cli => "--format progress" }, :all_on_start => false do
    watch(%r{^features/.+\.feature$})
    watch(%r{^app/(controllers|widgets)})     { "features" }
    watch(%r{^app/models/maintenance/(.+)\.rb$}) { |m| Dir[File.join("**/#{m[1]}.feature")][0]  }
    watch(%r{^spec/support/.+$})              { 'features' }
    watch(%r{^spec/factories/.+$})            { 'features' }
    watch(%r{^features/step_definitions/filesystem_steps.rb$})  { 'features -t @fakefs,@rootfs' }
    watch(%r{^app/models/.*(?:sync|file|content)})  { 'features -t @fakefs,@rootfs' }
#watch(%r{^features/support/.+$})          { 'features' }
    watch(%r{^features/step_definitions/(.+)_steps\.rb$}) { |m| Dir[File.join("**/#{m[1]}.feature")][0]  }

    watch(%r{^app/decorators/torrent})        { %w(transfer_info).map { |f| "features/#{f}.feature"} }

    callback(:run_all_end) do
      # update todo file
      system 'script/todo'
    end
  end

end

guard 'bundler' do
  watch('Gemfile')
end
