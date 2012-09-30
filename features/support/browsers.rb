module BrowserSupport

  Sizes = {
    mobile: { width: 640 + 8, height: 800 + 57 },
    big:    { width: 1280 + 8, height: 800 + 57 }
  }

  class << self

    def setup_chrome
      if chrome = [`which chromium-browser`, `which google-chrome`].map(&:chomp).reject(&:blank?).first
        Selenium::WebDriver::Chrome.path = chrome
      end
      setup_selenium :chrome,
        :switches => %w[--ignore-certificate-errors --disable-popup-blocking --disable-translate],
        :startpage => 'chrome://version/?name=Webdriver'
    end

    def setup_firefox
      setup_selenium :firefox, 
        :startpage => 'about:buildconfig'
    end

    def setup_poltergeist
      require 'capybara/poltergeist'
      Capybara.register_driver :poltergeist do |app|
        Capybara::Poltergeist::Driver.new(app, inspector: true)
      end
      Capybara.javascript_driver = :selenium
    end

    def setup_selenium(browser, opts={})
      unless [:chrome, :firefox].include?(browser)
        raise ArgumentError, "unsupported browser: #{browser}"
      end
      # arbitrary window decorations?
      width = (opts.delete(:width) || 640) + 8
      height = (opts.delete(:height) || 800) + 57
      startpage = opts.delete(:startpage)

      Capybara.register_driver :selenium do |app|
        Capybara::Selenium::Driver.new(app, opts.merge(:browser => browser)).tap do |driver|
          # Resize window. In Firefox and Chrome, must create a new window to do this.
          # http://groups.google.com/group/webdriver/browse_thread/thread/e4e987eeedfdb586
          browser = driver.browser
          handles = browser.window_handles
          browser.execute_script("window.open('#{startpage}','_blank','width=320,height=200');")
          browser.close
          browser.switch_to.window((browser.window_handles - handles).pop)
        end
      end

      Capybara.javascript_driver = :selenium
    end

  end

  module Cucumber
    def switch_browser_size(size_name)
      if size = BrowserSupport::Sizes[size_name]
        STDERR.puts "switching browser to #{size_name}"
        width, height = size[:width], size[:height]
        page.execute_script("window.resizeTo(#{width}, #{height});")
      else
        STDERR.puts "cannot switch browser to unknown size: #{size_name}"
      end
    end
  end
end

World(BrowserSupport::Cucumber)

Before '@javascript','@big_screen' do
  switch_browser_size(:big)
end
Before '@javascript','~@big_screen' do
  switch_browser_size(:big)
end
Before '@javascript','@mobile_screen' do
  switch_browser_size(:mobile)
end
