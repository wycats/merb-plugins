if defined?(Merb::Plugins)
  Merb::Plugins.add_rakefiles "merbtasks"
end

if Merb.environment == "test"
  dependency 'hpricot'
  dependency 'merb-test'
  
  require 'test/unit'
  
  require 'asserts/hpricot_asserts'
end