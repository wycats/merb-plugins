require 'base64'

module Merb
  module SessionMixin
    def setup_session
      MERB_LOGGER.info("Setting up session")
      before = cookies[_session_id_key]
      request.session, cookies[_session_id_key] = Merb::SequelSession.persist(cookies[_session_id_key])
      @_fingerprint = Marshal.dump(request.session.data).hash
      @_new_cookie = cookies[_session_id_key] != before
    end
  
    def finalize_session
      MERB_LOGGER.info("Finalize session")
      request.session.save if @_fingerprint != Marshal.dump(request.session.data).hash
      set_cookie(_session_id_key, request.session.values[:session_id], _session_expiry) if (@_new_cookie || request.session.needs_new_cookie)
    end
  end

  table_name = (Merb::Plugins.config[:sequel][:session_table_name] || "sessions")

  class SequelSession < Sequel::Model(table_name.to_sym)
    set_schema do
      primary_key :id
      varchar :session_id
      varchar :data
      timestamp :created_at
    end
  
    attr_accessor :needs_new_cookie
  
    class << self
      # Generates a new session ID and creates a row for the new session in the database.
      def generate
        create(:session_id => Merb::SessionMixin::rand_uuid,
                       :data => marshal({}), :created_at => Time.now)
      end
    
      # Gets the existing session based on the <tt>session_id</tt> available in cookies.
      # If none is found, generates a new session.
      def persist(session_id)
        if session_id
          session = find_by_session_id(session_id)
        end
        unless session
          session = generate
        end
        [session, session.values[:session_id]]
      end
    
      # Don't try to reload ARStore::Session in dev mode.
      def reloadable? #:nodoc:
        false
      end
    
      def data_column_size_limit
        255
      end
    
      def marshal(data)   Base64.encode64(Marshal.dump(data)) if data end
      def unmarshal(data)
        Marshal.load(Base64.decode64(data)) if data
      end
      
      alias :create_table! :create_table
      alias :drop_table! :drop_table
    end
  
    # Regenerate the Session ID
    def regenerate
      update_attributes(:session_id => Merb::SessionMixin::rand_uuid)
      self.needs_new_cookie = true
    end 
  
    # Recreates the cookie with the default expiration time 
    # Useful during log in for pushing back the expiration date 
    def refresh_expiration
      self.needs_new_cookie = true
    end
  
    # Lazy-delete of session data 
    def delete
      self.data = {}
    end
  
    def [](key)
      data[key]
    end
  
    def []=(key, val)
      data[key] = val
    end
  
    # Lazy-unmarshal session state.
    def data
      @data ||= self.class.unmarshal(@values[:data]) || {}
    end
  
    # Has the session been loaded yet?
    def loaded?
      !! @data
    end
  
  private
    attr_writer :data
  
    before_save do # marshal_data!
      # return false if !loaded?
      @values[:data] = self.class.marshal(self.data)
    end
  
    # Ensures that the data about to be stored in the database is not
    # larger than the data storage column. Raises
    # ActionController::SessionOverflowError.
    # before_save do # raise_on_session_data_overflow!
      # return false if !loaded?
      # limit = self.class.data_column_size_limit
      # if loaded? and limit and read_attribute(@@data_column_name).size > limit
        # raise MerbController::SessionOverflowError
      # end
    # end
  end

  unless Sequel::Model.db.table_exists?(table_name.to_sym)
    puts "Warning: The database did not contain a '#{table_name}' table for sessions."

    SequelSession.class_eval do
      create_table unless table_exists?
    end

    puts "Created sessions table."
  end
end