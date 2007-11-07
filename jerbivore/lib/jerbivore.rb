if defined?(Merb::Plugins)
  require 'jerbivore/servlet_handler'
  
  Merb::Plugins.config[:jerbivore] ||= {}
  Merb::Plugins.add_rakefiles "jerbivore/tasks"
end
