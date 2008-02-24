require 'rubygems'
require "merb-core"
require 'merb-test'

Merb.start :environment => 'test', :adapter => 'runner', :log_level => :fatal

require File.join(File.dirname(__FILE__), "..", "lib", "merb_rspec")