# make sure we're running inside Merb
if defined?(Merb::Plugins)

  # Merb gives you a Merb::Plugins.config hash...feel free to put your stuff in your piece of it
  Merb::Plugins.config[:sampleplugin] = {
    :elephants => true,
    :chickens => false
  }
  
  Merb::Plugins.add_rakefiles "sampleplugin/merbtasks"
end