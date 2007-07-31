#!/usr/bin/env ruby
require File.dirname(__FILE__) + '/../config/environment'
eater = BittornadoEater.new('ignored', true)
eater.verbose = true
eater.startup
