if defined?(Merb::Plugins)  
  
  dependency "activerecord"
  
  require File.join(File.dirname(__FILE__) / "merb" / "orms" / "active_record" / "cleanup" )
  require File.join(File.dirname(__FILE__) / "merb" / "orms" / "active_record" / "connection")
  Merb::Plugins.add_rakefiles(File.join(File.dirname(__FILE__) / "active_record" / "merbtasks"))
  
  class Merb::Orms::ActiveRecord::Connect < Merb::BootLoader
    after BeforeAppLoads

    def self.run
      Merb::Orms::ActiveRecord.connect
      if Merb::Config.session_stores.include?(:activerecord)
        Merb.logger.debug "Using ActiveRecord sessions"
        require File.join(File.dirname(__FILE__) / "merb" / "session" / "active_record_session")
      end
      # The default identify is :id instead of :to_param so that the identify
      # can be used as the default resource key
      Merb::Router.root_behavior = Merb::Router.root_behavior.identify(ActiveRecord::Base => :id)
    end

  end
  
  class Merb::Orms::ActiveRecord::DisconnectBeforeFork < Merb::BootLoader
    after AfterAppLoads
    
    def self.run      
      Merb.logger.debug "Disconnecting database connection before forking."
      ::ActiveRecord::Base.connection.disconnect!
    end
    
  end
  
  generators = File.join(File.dirname(__FILE__), 'generators')
  Merb.add_generators generators / :migration
  Merb.add_generators generators / :model
  Merb.add_generators generators / :resource_controller
  Merb.add_generators generators / :session_migration

end