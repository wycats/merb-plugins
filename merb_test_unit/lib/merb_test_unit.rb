if defined?(Merb::Plugins)
  Merb::Plugins.add_rakefiles "merbtasks"
end

#Don't include anything for Test::Unit if we're not 
if Merb.environment == "test"
  dependency 'hpricot'
  dependency 'merb-test'
  
  require 'test/unit'
  
  module Merb::Test::Unit
  end
  
  require File.join(File.dirname(__FILE__), 'asserts', 'hpricot_asserts')
  require File.join(File.dirname(__FILE__), 'asserts', 'controller_asserts')
end