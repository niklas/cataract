source 'http://rubygems.org'

gem 'rails', '~> 4.0.4'
gem 'pg'


# Gems used only for assets
gem 'sass-rails', '~> 4.0.3'
gem 'uglifier', '>= 1.2.3'
gem 'jquery-rails'
gem 'bootstrap-sass', '~> 2.3.0.1'
gem 'jquery-ui-rails'
gem 'bootswatch-rails'
gem 'turbo-sprockets-rails3'


group :test do
  gem 'rake'
  gem 'cucumber-rails', "~> 1.4.0", :require => false
  # This is used to obtaing timings of Cucumber scenarios
  gem 'cucumber-timed_formatter', require: 'timed'
  gem 'rspec-rails', "~> 2.13"
  gem 'pickle'
  gem 'timecop'
  gem 'database_cleaner'
  gem 'email_spec'
  gem 'factory_girl_rails', require: false
  # TODO for latest chrome-webdriver remove when capybara > 1.1.2 depends on it
  gem 'selenium-webdriver'

  # Guard
  gem 'guard'
  gem "guard-rspec"
  gem "guard-cucumber"
  gem "guard-bundler"
  gem "libnotify", :require => false
  gem "fakefs", :require => false
  gem "kopflos", :git => 'git://github.com/niklas/kopflos.git'

  gem 'simplecov', :require => false

  gem 'diff_matcher'
  gem 'launchy'
  gem 'chromedriver-helper'

  gem 'term-ansicolor' # for ScenarioTodo

  gem 'poltergeist'

  # for torrent_fetcher/maulwurf
  gem 'webmock', '1.16', require: false
  gem "vcr"

  # the zeus page says, it should is not needed and should be kept out of the
  # Gemfile guard-cucumber cannot start "zeus cucumber" because it isn't in the
  # bundle: So.. we add it, but don't load it. To get fast guard response
  # times, make sure it does not run cucumber through bundler.
  gem 'zeus', '~> 0.15.0', require: false
end

group :development, :test do
  gem 'pry'
  gem 'pry-nav'
  gem 'pry-doc'
  gem 'pry-stack_explorer'
  gem 'jasminerice', github: 'bradphelan/jasminerice'
  gem 'guard-jasmine'
  gem 'rb-inotify'
  gem 'rails-develotest'
end

group :development do
  gem 'capistrano'
  gem 'rvm-capistrano'
  gem 'notes', :require => false, :git => 'git://github.com/niklas/notes.git'
  gem "better_errors"
  gem 'binding_of_caller'
end

group :production do
  gem 'therubyracer' # to compile our coffeescript
  gem 'unicorn'
end

gem 'acts_as_list'

gem 'nokogiri' # for partial hack

gem 'rubytorrent-allspice', :git => 'git://github.com/niklas/rubytorrent-allspice.git'

gem 'scgi'
gem 'xmlrpcs'
gem 'ancestry'

gem 'coffee-rails'
gem 'devise'
gem 'cancan'
gem 'simple_form'
gem 'haml-rails'
gem 'inherited_resources'

gem 'active_attr'
gem 'foreman'
gem 'kaminari'

gem 'levenshtein'

gem 'carrierwave'
gem "active_model_serializers", '~> 0.8.1'
gem 'whenever', :require => false

gem 'feed-abstract'

gem 'dalli'

# https://github.com/emberjs/ember-rails/issues/165
gem 'ember-rails', git: 'git://github.com/emberjs/ember-rails.git'
gem 'ember-source', '1.5.0'
gem 'ember-data-source'

gem 'ember-rails-flash', git: 'git://github.com/niklas/ember-rails-flash.git'
gem 'newrelic_rpm'

gem "rails-bookmarklet", :git => "https://github.com/oliverfriedmann/rails-bookmarklet.git"

# for maulwurf
gem 'mechanize'

# bad yaml
gem 'psych'

# .2 introduces version check on > 1.4, but ubuntu did not update the version when patching CVE-2014-2525
gem 'safe_yaml', '1.0.1'

# TODO strong parameter
gem 'protected_attributes'
