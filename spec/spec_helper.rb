require 'rubygems'
require 'spork'

Spork.prefork do
  ENV["RAILS_ENV"] ||= 'test'
  require File.dirname(__FILE__) + "/../config/spork_prefork"

  require 'rspec/rails'
  require 'fakefs/spec_helpers'
  require 'webmock/rspec'

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
end

Spork.each_run do
  # rspec reports time since its started https://github.com/guard/guard-rspec/issues/61
  $rspec_start_time = Time.now

  # Requires supporting ruby files with custom matchers and macros, etc,
  # in spec/support/ and its subdirectories.
  Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}
  FactoryGirl.reload
  I18n.reload!
  load Rails.root/'config'/'routes.rb'
end
