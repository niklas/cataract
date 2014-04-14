  ENV["RAILS_ENV"] ||= 'test'
  require File.expand_path("../../config/environment", __FILE__)

  require 'rspec/rails'
  require 'fakefs/spec_helpers'
  require 'webmock/rspec'
  require 'vcr'

  RSpec.configure do |config|
    include FactoryGirl::Syntax::Default

    config.include Devise::TestHelpers, :type => :controller

    config.before :each do
      Torrent::RTorrent.offline!
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
      unless example.metadata[:without_transaction]
        DatabaseCleaner.start
      end
    end

    config.after(:each) do
      if example.metadata[:without_transaction]
        DatabaseCleaner.clean_with(:truncation)
      else
        DatabaseCleaner.clean
      end
    end

    config.mock_with :rspec
  end

  Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

#  # rspec reports time since its started https://github.com/guard/guard-rspec/issues/61
#  $rspec_start_time = Time.now
#
#  # Requires supporting ruby files with custom matchers and macros, etc,
#  # in spec/support/ and its subdirectories.
#  FactoryGirl.reload
#  I18n.reload!
#  load Rails.root/'config'/'routes.rb'
