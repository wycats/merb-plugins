require 'fileutils'
require 'data_mapper'

module Merb
  module Orms
    module DataMapper
      class << self
        def config_file() Merb.root / "config" / "database.yml" end
        def sample_dest() Merb.root / "config" / "database.sample.yml" end
        def sample_source() File.dirname(__FILE__) / "database.sample.yml" end
      
        def copy_sample_config
          FileUtils.cp sample_source, sample_dest unless File.exists?(sample_dest)
        end
      
        def config
          @config ||=
            begin
              # Convert string keys to symbols
              full_config = Erubis.load_yaml_file(config_file)
              config = (Merb::Plugins.config[:merb_datamapper] = {})
              (full_config[Merb.environment.to_sym] || full_config[Merb.environment]).each { |k, v| config[k.to_sym] = v }
              config
            end
        end
      
        # Database connects as soon as the gem is loaded
        def connect
          if File.exists?(config_file)
            puts "Connecting to database..."
            ::DataMapper::Database.setup(config)
          else
            copy_sample_config
            puts "No database.yml file found in #{Merb.root}/config."
            puts "A sample file was created called database.sample.yml for you to copy and edit."
            exit(1)
          end
        end
        
        # Registering this ORM lets the user choose DataMapper as a session store
        # in merb.yml's session_store: option.
        def register_session_type
          Merb::BootLoader.after_app_loads do
            Merb.register_session_type("datamapper",
            "merb/session/data_mapper_session",
            "Using DataMapper database sessions")
          end
        end
      end
    end
  end
end