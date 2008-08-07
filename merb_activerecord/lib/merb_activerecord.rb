if defined?(Merb::Plugins)  
  dependency "activerecord"
  require File.join(File.dirname(__FILE__) / "merb" / "orms" / "active_record" / "connection")
  Merb::Plugins.add_rakefiles(File.join(File.dirname(__FILE__) / "active_record" / "merbtasks"))
  
  class Merb::Orms::ActiveRecord::Connect < Merb::BootLoader

    after BeforeAppLoads

    def self.run
      Merb::Orms::ActiveRecord.connect
      Merb::Orms::ActiveRecord.register_session_type
    end

  end
  
  generators = File.join(File.dirname(__FILE__), 'generators')
  Merb.add_generators generators / :migration
  Merb.add_generators generators / :model
  Merb.add_generators generators / :resource_controller
  Merb.add_generators generators / :session_migration

end