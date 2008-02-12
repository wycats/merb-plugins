require 'rubygems'
require "merb-core"
require "merb-test"
require "rubigen"

Merb.start :environment => "test", :adapter => "runner"

require File.join(File.dirname(__FILE__), "..", "lib", "merb_rspec")