group :test, :halt_on_fail => true do

  guard 'rspec',
    cmd: 'zeus rspec --color --format documentation',
    run_all: {
      cli: "--color --format progress"
    },
    all_on_start: false do
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

  guard 'jasmine' do
    watch(%r{spec/javascripts/spec\.(js\.coffee|js|coffee)$})         { "spec/javascripts" }
    watch(%r{spec/javascripts/.+_spec\.(js\.coffee|js|coffee)$})
    watch(%r{app/assets/javascripts/(.+?)\.(js|coffee)})  { |m| "spec/javascripts/#{m[1]}_spec.#{m[2]}" }
  end if false # causes bad asset builds which are missing .emblem templates

  guard 'cucumber',
    cli: "--no-source --no-profile --strict --format pretty --format rerun --out rerun.txt --tags ~@wip",
    keep_failed: false,
    run_all: { cli: "--format progress --tags ~@wip" },
    command_prefix: 'zeus',
    bundler: false,
    all_on_start: false,
    all_after_pass: false do
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

