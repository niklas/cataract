source 'http://rubygems.org'

gem 'rails', '3.2.12'
gem 'pg'


# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.4'
  gem 'uglifier', '>= 1.2.3'
  gem 'jquery-rails'
  gem 'bootstrap-sass', '~> 2.0.4'
  gem 'jquery-ui-rails'
  gem 'bootswatch-rails'
  gem 'ember-rails', git: 'git://github.com/emberjs/ember-rails.git', ref: "359221e49057fe737" # master that has rmber 1.0rc1
end


group :test do
  gem 'rake'
  gem 'cucumber-rails', "~> 1.2.1", :require => false
  gem 'rspec-rails', "~> 2.12.2"
  gem 'pickle'
  gem 'timecop'
  gem 'database_cleaner'
  gem 'email_spec'
  gem 'factory_girl_rails'
  # TODO for latest chrome-webdriver remove when capybara > 1.1.2 depends on it
  gem 'selenium-webdriver', '~> 2.21.2'

  gem "spork", "1.0.0rc3"
  gem "guard-rspec", "~> 2.4.0"
  gem "guard-cucumber", "~> 1.3.2"
  gem "guard-spork", "~> 1.4.2"
  gem "guard-bundler", "~> 1.0.0"
  gem "libnotify", :require => false
  gem "fakefs", :require => false
  gem "kopflos", :git => 'git://github.com/niklas/kopflos.git'

  gem 'simplecov', :require => false

  gem 'diff_matcher'
  gem 'launchy'
  gem 'chromedriver-helper'

  gem 'webmock'
  gem 'term-ansicolor' # for ScenarioTodo

  gem 'poltergeist'
end

group :development, :test do
  gem 'pry'
  gem 'pry-nav'
  gem 'pry-doc'
  gem 'pry-stack_explorer'
  gem 'jasminerice'
  gem 'guard-jasmine'
  gem 'rb-inotify'
end

group :development do
  gem 'capistrano'
  gem 'rvm-capistrano'
  gem 'notes', :require => false, :git => 'git://github.com/niklas/notes.git'
end

group :production do
  gem 'therubyracer' # to compile our coffeescript
end
gem "pg"
gem 'acts_as_list'

gem 'nokogiri' # for partial hack

gem 'rubytorrent-allspice', :git => 'git://github.com/niklas/rubytorrent-allspice.git'

gem 'scgi'
gem 'xmlrpcs'
gem 'ancestry'

gem 'coffee-rails', '~> 3.2.2'
gem 'compass-rails'
gem 'devise', '~> 2.0.4'
gem 'cancan'
gem 'simple_form', '~> 2.0.0'
gem 'haml-rails'
gem 'inherited_resources'
gem 'draper'

gem 'active_attr', '~> 0.5.0.alpha2' # SchedulingFilter, need AttributeDefaults
gem 'foreman'
gem 'kaminari'

gem 'levenshtein'

gem 'carrierwave'
gem "active_model_serializers", :git => "git://github.com/rails-api/active_model_serializers.git"
gem 'whenever', :require => false

gem 'feed-abstract'

gem 'dalli'
gem 'ember-rails-flash', git: 'git://github.com/niklas/ember-rails-flash.git'
