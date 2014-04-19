
  ENV["RAILS_ENV"] ||= 'test'
  require File.expand_path("../../../config/environment", __FILE__)

  require 'rspec'
  require 'fileutils'

  require 'capybara/rails'
  require 'cucumber/rails'

  require 'email_spec'
  require 'email_spec/cucumber'

  require 'cucumber/rspec/doubles'

  require 'factory_girl'

  require 'kopflos/cucumber'

  World(RSpec::Matchers)

  # Capybara defaults to XPath selectors rather than Webrat's default of CSS3. In
  # order to ease the transition to Capybara we set the default here. If you'd
  # prefer to use XPath just remove this line and adjust any selectors in your
  # steps to use the XPath syntax.
  Capybara.default_selector = :css

  Capybara.server do |app, port|
    require 'rack/handler/webrick'
    Rack::Handler::WEBrick.run(app, :Port => port, :AccessLog => [], :Logger => WEBrick::Log::new(Rails.root.join("log/capybara_test.log").to_s))
  end

  require File.dirname(__FILE__) + "/browsers"
  if ENV['TRAVIS']
    BrowserSupport.setup_firefox
  else
    BrowserSupport.setup_chrome
  end

  # By default, any exception happening in your Rails application will bubble up
  # to Cucumber so that your scenario will fail. This is a different from how 
  # your application behaves in the production environment, where an error page will 
  # be rendered instead.
  #
  # Sometimes we want to override this default behaviour and allow Rails to rescue
  # exceptions and display an error page (just like when the app is running in production).
  # Typical scenarios where you want to do this is when you test your error pages.
  # There are two ways to allow Rails to rescue exceptions:
  #
  # 1) Tag your scenario (or feature) with @allow-rescue
  #
  # 2) Set the value below to true. Beware that doing this globally is not
  # recommended as it will mask a lot of errors for you!
  #
  ActionController::Base.allow_rescue = false

  require 'webmock/cucumber'
  VCR.configure do |c|
    c.hook_into :webmock
    c.cassette_library_dir = 'features/cassettes'
    c.allow_http_connections_when_no_cassette = true
    c.ignore_localhost = true # selenium
  end

  VCR.cucumber_tags do |t|
    t.tag  '@vcr', use_scenario_name: true, record: :new_episodes
  end


#  I18n.backend.reload!
#  FactoryGirl.reload
#  load Rails.root/'config'/'routes.rb'

