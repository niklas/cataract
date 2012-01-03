require 'rubygems'
require 'spork'

Spork.prefork do
  require 'simplecov'
  # This file is copied to spec/ when you run 'rails generate rspec:install'
  ENV["RAILS_ENV"] ||= 'test'
  require File.expand_path("../../config/environment", __FILE__)
  require 'rspec/rails'
  require 'fakefs/spec_helpers'

  RSpec.configure do |config|
    include FactoryGirl::Syntax::Default

    # == Mock Framework
    #
    # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
    #
    # config.mock_with :mocha
    # config.mock_with :flexmock
    # config.mock_with :rr
    config.mock_with :rspec

    config.before :each do
      Torrent::RTorrent.offline!
    end

    config.before(:suite) do
      DatabaseCleaner.strategy = :transaction
      DatabaseCleaner.clean_with(:truncation)
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
  end
end

Spork.each_run do
  # rspec reports time since its started https://github.com/guard/guard-rspec/issues/61
  $rspec_start_time = Time.now

  # Requires supporting ruby files with custom matchers and macros, etc,
  # in spec/support/ and its subdirectories.
  Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}
  FactoryGirl.reload
  load Rails.root/'config'/'routes.rb'
end
