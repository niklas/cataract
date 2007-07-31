#!/usr/bin/env ruby

RAILS_ENV = ENV['RAILS_ENV'] || 'production'
require File.dirname(__FILE__) + '/../config/environment'

eater = BittornadoEater.new('flupp')
eater.startup

