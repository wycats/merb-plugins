require 'fileutils'

module Merb
  module Orms
    module Sequel
      class << self
        def config_file() MERB_ROOT / "config" / "database.yml" end
        def sample_dest() MERB_ROOT / "config" / "database.sample.yml" end
        def sample_source() File.dirname(__FILE__) / "database.sample.yml" end
      
        def copy_sample_config
          FileUtils.cp sample_source, sample_dest unless File.exists?(sample_dest)
        end
      
        def config
          @config ||=
            begin
              # Convert string keys to symbols
              full_config = Erubis.load_yaml_file(config_file)
              config = (Merb::Plugins.config[:merb_sequel] = {})
              (full_config[MERB_ENV.to_sym] || full_config[MERB_ENV]).each { |k, v| config[k.to_sym] = v }
              config
            end
        end
      
        # Database connects as soon as the gem is loaded
        def connect
          if File.exists?(config_file)
            puts "Connecting to database..."
            # Load the correct Sequel adapter and set it up according to the yaml file
            case config[:adapter]
            when 'mysql'
              require "sequel/mysql"
              host = config[:host] || 'localhost'
              user = config[:user] || config[:username] || 'root'
              password = config[:password]
              # Use Sequel::Model.db to access this object
              ::Sequel.mysql(config[:database], :host => host, :user => user, :password => password, :logger => MERB_LOGGER)
            when 'sqlite'
              require "sequel/sqlite"
              if config[:database]
                ::Sequel.sqlite config[:database]
              else
                ::Sequel.sqlite
              end
            else
              require "sequel/sqlite"
              p full_config
              puts "No adapter specified in config/database.yml... trying a memory-only sqlite database"
              ::Sequel.sqlite
            end
          else
            copy_sample_config
            puts "No database.yml file found in #{MERB_ROOT}/config."
            puts "A sample file was created called database.sample.yml for you to copy and edit."
            exit(1)
          end
        end
        
        # Registering this ORM lets the user choose sequel as a session store
        # in merb.yml's session_store: option.
        def register_session_type
          Merb::Server.register_session_type("sequel",
            "merb/session/sequel_session",
            "Using Sequel database sessions")
        end
      end
    end
  end
end