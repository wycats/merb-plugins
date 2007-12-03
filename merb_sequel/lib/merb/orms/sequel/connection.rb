require "fileutils"

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

          require "sequel"

          if File.exists?(config_file)
            puts "Connecting to database..."
            options = {}
            options[:adapter]  = (config[:adaptor]  || "sqlite")
            options[:host]     = (config[:host]     || "localhost")
            options[:user]     = (config[:username] || config[:user] || "root")
            options[:encoding] = (config[:encoding] || config[:charset]) if (config[:encoding] || config[:charset])
            options[:database] = config[:database] if config[:database]
            options[:logger]   = MERB_LOGGER
            
            uri = "#{options[:adapter]}://"
            uri << options[:username]         if options[:username]
            uri << (':' + options[:password]) if options[:password]
            uri << '@' if (options[:user] || options[:password])
            uri << options[:host]
            uri << ('/' + options[:database]) if options[:database]

            connection = ::Sequel.connect(uri, options)

            MERB_LOGGER.error("Connection Error: #{e}") unless connection
          else
            copy_sample_config
            puts "No database.yml file found in #{MERB_ROOT}/config."
            puts "A sample file was created called config/database.sample.yml for you to copy and edit."
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
