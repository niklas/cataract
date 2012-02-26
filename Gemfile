source 'http://rubygems.org'

gem 'rails', '3.2.1'
gem 'pg'


# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.4'
  gem 'uglifier', '>= 1.2.3'
  gem 'jquery-rails'
  gem 'bootstrap-sass', '~> 2.0.0'
end


group :test do
  gem 'rake'
  gem 'cucumber-rails', "~> 1.2.1"
  gem 'rspec-rails', "~> 2.8.1"
  gem "pickle"
  gem "timecop"
  gem 'database_cleaner'
  gem "email_spec"
  gem 'factory_girl_rails'
  # TODO for latest chrome-webdriver remove when capybara > 1.1.2 depends on it
  gem 'selenium-webdriver', '~> 2.19.0'

  gem "spork", "1.0.0rc2"
  gem "guard-rspec", "~> 0.6.0"
  gem "guard-cucumber", "~> 0.7.5"
  gem "guard-spork", "~> 0.5.2"
  gem "guard-bundler", "~> 0.1.3"
  gem "guard-shell"
  gem "libnotify", :require => false
  gem "fakefs", :require => "fakefs/safe"
  gem "kopflos", :git => 'git://github.com/niklas/kopflos.git'

  gem 'simplecov', :require => false
  gem 'pry-nav'
  gem 'pry-stack_explorer'
end

group :development, :test do
  gem 'pry'
end

group :development do
  gem "capistrano"
  gem 'rb-inotify'
  gem 'notes', :require => false, :git => 'git://github.com/v0n/notes.git'
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
gem 'devise'
gem 'cancan'
gem 'simple_form', '~> 2.0.0'
gem 'haml-rails'
gem 'inherited_resources'
gem 'draper'

gem 'active_attr', '~> 0.5.0.alpha2' # SchedulingFilter, need AttributeDefaults
gem 'versatile_rjs', :git => 'git://github.com/condor/versatile_rjs.git'

gem 'foreman'
gem 'kaminari'
