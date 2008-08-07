if defined?(Merb::Plugins)
  Merb::Plugins.config[:merb_sequel] = {}
  require File.join(File.dirname(__FILE__) / "merb" / "orms" / "sequel" / "connection")
  Merb::Plugins.add_rakefiles "merb_sequel" / "merbtasks"
  
  class Merb::Orms::Sequel::Connect < Merb::BootLoader

    after BeforeAppLoads

    def self.run
      Merb::Orms::Sequel.connect
      Merb::Orms::Sequel.register_session_type
    end

  end
  
  generators = File.join(File.dirname(__FILE__), 'generators')
  Merb.add_generators generators / :migration
  Merb.add_generators generators / :model
  Merb.add_generators generators / :resource_controller
  Merb.add_generators generators / :session_migration
  
end