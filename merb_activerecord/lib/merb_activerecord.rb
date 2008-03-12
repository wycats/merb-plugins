if defined?(Merb::Plugins)  
  dependency "activerecord"
  require File.join(File.dirname(__FILE__) / "merb" / "orms" / "active_record" / "connection")
  Merb::Plugins.add_rakefiles(File.join(File.dirname(__FILE__) / "active_record" / "merbtasks"))
  
  class Merb::Orms::ActiveRecord::Connect < Merb::BootLoader

    after BeforeAppRuns

    def self.run
      Merb::Orms::ActiveRecord.connect
      Merb::Orms::ActiveRecord.register_session_type
    end

  end

end