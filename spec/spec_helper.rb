  ENV["RAILS_ENV"] ||= 'test'
  require File.expand_path("../../config/environment", __FILE__)

  require 'rspec/rails'
  require 'fakefs/spec_helpers'
  require 'factory_girl'
  require 'webmock/rspec'
  require 'vcr'

  RSpec.configure do |config|
    include FactoryGirl::Syntax::Default

    config.include Devise::TestHelpers, :type => :controller

    config.before :each do
      Torrent::RTorrent.offline!
    end

    config.after :each do
      stop_rtorrent # if started
    end

    config.before(:suite) do
      DatabaseCleaner.strategy = :transaction
      DatabaseCleaner.clean_with(:truncation)
    end

    config.before(:suite) do
      VCR.configure do |c|
        c.cassette_library_dir = 'fixtures/vcr_cassettes'
        c.hook_into :webmock # or :fakeweb
      end
    end

    config.before(:each) do
      unless RSpec.current_example.metadata[:without_transaction]
        DatabaseCleaner.start
      end
    end

    config.after(:each) do
      if RSpec.current_example.metadata[:without_transaction]
        DatabaseCleaner.clean_with(:truncation)
      else
        DatabaseCleaner.clean
      end
    end

    # useful for debugging without being bombarded with pry prompts:
    # in your example:
    #   $want_pry = true
    #   call_method_that_is_called_a_gazillion.times
    #
    # at thew to be instpected location:
    #   binding.pry if $want_pry
    config.after(:each) do
      # other examples should not open pry
      $want_pry = false
    end

    config.mock_with :rspec
  end

Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}
FactoryGirl.reload

#  # rspec reports time since its started https://github.com/guard/guard-rspec/issues/61
#  $rspec_start_time = Time.now
#
#  # Requires supporting ruby files with custom matchers and macros, etc,
#  # in spec/support/ and its subdirectories.
#  I18n.reload!
#  load Rails.root/'config'/'routes.rb'
