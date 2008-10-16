if defined?(Merb::Plugins)
  Merb::Plugins.config[:merb_sequel] = {}
  require File.join(File.dirname(__FILE__) / "sequel_ext" / "model")
  require File.join(File.dirname(__FILE__) / "merb" / "orms" / "sequel" / "connection")
  Merb::Plugins.add_rakefiles "merb_sequel" / "merbtasks"
  
  class Merb::Orms::Sequel::Connect < Merb::BootLoader

    after BeforeAppLoads

    def self.run
      Merb::Orms::Sequel.connect
      if Merb::Config.session_stores.include?(:sequel)
        Merb.logger.debug "Using Sequel sessions"
        require File.join(File.dirname(__FILE__) / "merb" / "session" / "sequel_session")
      end
      
      Merb::Router.root_behavior = Merb::Router.root_behavior.identify(Sequel::Model => :id)
    end

  end
  
  generators = File.join(File.dirname(__FILE__), 'generators')
  Merb.add_generators generators / :migration
  Merb.add_generators generators / :model
  Merb.add_generators generators / :resource_controller
  Merb.add_generators generators / :session_migration
  
end