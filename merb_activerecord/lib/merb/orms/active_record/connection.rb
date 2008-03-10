require 'fileutils'
require 'active_record'

module Merb
  module Orms
    module ActiveRecord
      class << self
        def config_file() Merb.dir_for(:config) / "database.yml" end
        def sample_dest() Merb.dir_for(:config) / "database.yml.sample" end
        def sample_source() File.dirname(__FILE__) / "database.yml.sample" end
      
        def copy_sample_config
          FileUtils.cp sample_source, sample_dest unless File.exists?(sample_dest)
        end
      
        def config
          @config ||=
            begin
              # Convert string keys to symbols
              full_config = Erubis.load_yaml_file(config_file)
              config = (Merb::Plugins.config[:merb_active_record] = {})
              (full_config[Merb.environment.to_sym] || full_config[Merb.environment]).each { |k, v| config[k.to_sym] = v }
               ::ActiveRecord::Base.configurations= full_config
              config
            end
        end

        # Database connects as soon as the gem is loaded
        def connect
          if File.exists?(config_file)
            Merb.logger.info("Connecting to database...")

            Thread.new{ loop{ sleep(60*60); ::ActiveRecord::Base.verify_active_connections! } }.priority = -10

            ::ActiveRecord::Base.verification_timeout = 14400
            ::ActiveRecord::Base.logger = Merb.logger
            ::ActiveRecord::Base.establish_connection config
          else
            copy_sample_config
            puts "No database.yml file found in #{Merb.root}/config."
            puts "A sample file was created called database.sample.yml for you to copy and edit."
            exit(1)
          end
        end
        
        # Registering this ORM lets the user choose active_record as a session
        # in merb.yml's session_store: option.
        def register_session_type
          Merb.register_session_type("activerecord",
          "merb/session/active_record_session",
          "Using ActiveRecord database sessions")
        end
      end
    end
  end
end