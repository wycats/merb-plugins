if defined?(Merb::Plugins)
  
  module Spec; end

  $:.unshift File.dirname(__FILE__)

  load_dependency 'merb-slices'
  Merb::Plugins.add_rakefiles "merb_screw_unit/merbtasks", "merb_screw_unit/slicetasks"

  # Register the Slice for the current host application
  Merb::Slices::register(__FILE__)
  
  # Slice configuration - set this in a before_app_loads callback.
  # By default a Slice uses its own layout, so you can swicht to 
  # the main application layout or no layout at all if needed.
  # 
  # Configuration options:
  # :layout - the layout to use; defaults to :merb_screw_unit
  # :mirror - which path component types to use on copy operations; defaults to all
  Merb::Slices::config[:merb_screw_unit][:layout] ||= :merb_screw_unit
  
  # All Slice code is expected to be namespaced inside a module
  module MerbScrewUnit
    
    # Slice metadata
    self.description = "MerbScrewUnit is a chunky Merb slice!"
    self.version = "0.0.1"
    self.author = "YOUR NAME"
    
    # Stub classes loaded hook - runs before LoadClasses BootLoader
    # right after a slice's classes have been loaded internally.
    def self.loaded
    end
    
    # Initialization hook - runs before AfterAppLoads BootLoader
    def self.init
    end
    
    # Activation hook - runs after AfterAppLoads BootLoader
    def self.activate
    end
    
    # Deactivation hook - triggered by Merb::Slices.deactivate(MerbScrewUnit)
    def self.deactivate
    end
    
    # Setup routes inside the host application
    #
    # @param scope<Merb::Router::Behaviour>
    #  Routes will be added within this scope (namespace). In fact, any 
    #  router behaviour is a valid namespace, so you can attach
    #  routes at any level of your router setup.
    #
    # @note prefix your named routes with :merb_screw_unit_
    #   to avoid potential conflicts with global named routes.
    def self.setup_router(scope)
      # example of a named route
      scope.match('/index.:format').to(:controller => 'main', :action => 'index').name(:merb_screw_unit_index)
      scope.match('/:controller/:action')
    end
    
  end
  
  # Setup the slice layout for MerbScrewUnit
  #
  # Use MerbScrewUnit.push_path and MerbScrewUnit.push_app_path
  # to set paths to merb_screw_unit-level and app-level paths. Example:
  #
  # MerbScrewUnit.push_path(:application, MerbScrewUnit.root)
  # MerbScrewUnit.push_app_path(:application, Merb.root / 'slices' / 'merb_screw_unit')
  # ...
  #
  # Any component path that hasn't been set will default to MerbScrewUnit.root
  #
  # Or just call setup_default_structure! to setup a basic Merb MVC structure.
  MerbScrewUnit.setup_default_structure!
  
  # Add dependencies for other MerbScrewUnit classes below. Example:
  # dependency "merb_screw_unit/other"
  
end