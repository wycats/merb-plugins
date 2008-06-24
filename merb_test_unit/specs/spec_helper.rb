require 'rubygems'
require "merb-core"
require "test/unit"

Merb.start :environment => 'test', :adapter => 'runner'

require File.join(File.dirname(__FILE__), "..", "lib", "merb_test_unit")