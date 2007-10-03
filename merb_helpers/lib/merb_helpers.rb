# make sure we're running inside Merb
if defined?(Merb::Plugins)

  # Merb gives you a Merb::Plugins.config hash...feel free to put your stuff in your piece of it
  Merb::Plugins.config[:merb_helpers] = {
    :chickens => false
  }
  
  require 'form_model'
  require 'form_helpers'
  Merb::Plugins.add_rakefiles "merb_helpers/merbtasks"
end