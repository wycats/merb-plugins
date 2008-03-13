module Merb
  
  module Helpers
    HELPERS_DIR   = File.dirname(__FILE__) / 'merb_helpers'
    HELPERS_FILES = Dir["#{HELPERS_DIR}/*_helpers.rb"].collect {|h| h.match(/\/(\w+)\.rb/)[1]}
      
    def self.load_helpers(helpers = HELPERS_FILES)
      helpers.each {|h| Kernel.load(File.join(HELPERS_DIR, "#{h}.rb") )} # using load here allows specs to work
    end
    
    def self.load
      if Merb::Plugins.config[:merb_helpers]
        config = Merb::Plugins.config[:merb_helpers]
        raise "With and Without options cannot be used with merb_helpers plugin configuration" if config[:with] && config[:without]
        if config[:include]
          load_helpers(config[:include])
        elsif config[:exclude]
          load_helpers(HELPERS_FILES.reject {|h| config[:exclude].include? h})
        else
          # This is in case someone defines an entry in the config,
          # but doesn't put in a with or without option
          load_helpers
        end
      else
        load_helpers
      end
    end
    
  end
  
end

Merb::BootLoader.before_app_loads do  
  Merb::Helpers.load if defined?(Merb::Plugins)
end
