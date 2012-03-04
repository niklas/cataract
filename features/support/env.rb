require 'rubygems'
require 'spork'

Spork.prefork do
  ENV["RAILS_ENV"] ||= 'test'
  require File.dirname(__FILE__) + "/../../config/spork_prefork"

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

  Capybara.register_driver :selenium do |app|
    Capybara::Selenium::Driver.new(app, :browser => :chrome).tap do |driver|
      width, height = 480 + 8, 800 + 57

      # Resize window. In Firefox and Chrome, must create a new window to do this.
      # http://groups.google.com/group/webdriver/browse_thread/thread/e4e987eeedfdb586
      browser = driver.browser
      handles = browser.window_handles
      browser.execute_script("window.open('chrome://version/?name=Webdriver','_blank','width=#{width},height=#{height}');")
      browser.close
      browser.switch_to.window((browser.window_handles - handles).pop)
      browser.execute_script("window.resizeTo(#{width}, #{height}); window.moveTo(1,1);")
    end
  end

  Capybara.server do |app, port|
    require 'rack/handler/webrick'
    Rack::Handler::WEBrick.run(app, :Port => port, :AccessLog => [], :Logger => WEBrick::Log::new(Rails.root.join("log/capybara_test.log").to_s))
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
end

Spork.each_run do
  I18n.backend.reload!
  FactoryGirl.reload
  load Rails.root/'config'/'routes.rb'
end

