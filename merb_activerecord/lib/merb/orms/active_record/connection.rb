require 'fileutils'

module Merb
  module Orms
    module ActiveRecord

      # Start a transaction.
      #
      # Used by Merb::Rack::Console#open_sandbox!
      def self.open_sandbox!
        ::ActiveRecord::Base.send :increment_open_transactions
        ::ActiveRecord::Base.connection.begin_db_transaction
      end

      # Rollback a transaction.
      #
      # Used by Merb::Rack::Console#close_sandbox!
      def self.close_sandbox!
        ::ActiveRecord::Base.connection.rollback_db_transaction
        ::ActiveRecord::Base.send :decrement_open_transactions
      end

      class << self
        def config_file() Merb.dir_for(:config) / "database.yml" end
        def sample_dest() Merb.dir_for(:config) / "database.yml.sample" end
        def sample_source() File.dirname(__FILE__) / "database.yml.sample" end

        def copy_sample_config
          FileUtils.cp sample_source, sample_dest unless File.exists?(sample_dest)
        end

        def config
          #If Merb#runs_like specifies a differnt db env, use it.
          env_sym = (Merb.environment_info.nil?) ?
            Merb.environment.to_sym :
            Merb.environment_info[:db_env].to_sym

          raise ArgumentError, "missing environment :#{Merb.environment} in config file #{config_file}" unless configurations.key?(env_sym)
          @config ||= (Merb::Plugins.config[:merb_active_record] = configurations[env_sym])
        end

        def configurations
          @configurations ||=
            begin
              #A proc that will recursively intern(a.k.a symbolize) the keys of the hash
              intern_keys = lambda { |x|
                x.inject({}) do |y, (k,v)|
                  y[k.to_sym || k] = v.is_a?(Hash) ? intern_keys.call(v) : v
                  y
                end
              }
              intern_keys.call(Erubis.load_yaml_file(config_file))
            end
        end

        # Database connects as soon as the gem is loaded
        def connect
          if File.exists?(config_file)
            Merb.logger.info!("Connecting to database...")

            Thread.new{ loop{ sleep(60*60); ::ActiveRecord::Base.verify_active_connections! } }

            ::ActiveRecord::Base.logger = Merb.logger
            ::ActiveRecord::Base.configurations = configurations
            ::ActiveRecord::Base.establish_connection config
          else
            copy_sample_config
            Merb.logger.error! "No database.yml file found in #{Merb.root}/config."
            Merb.logger.error! "A sample file was created called database.yml.sample for you to copy and edit."
            exit(1)
          end
        end

      end
    end
  end
end
