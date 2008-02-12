if defined?(Merb::Plugins)
  Merb::Plugins.add_rakefiles "merbtasks"
end

module Merb::Test::Unit
end

if Merb.environment == "test"
  dependency 'hpricot'
  dependency 'merb-test'
  
  require 'test/unit'
  
  require File.join(File.dirname(__FILE__), 'asserts', 'hpricot_asserts')
  require File.join(File.dirname(__FILE__), 'asserts', 'controller_asserts')
end