require "active_record"

module Merb
  module SessionMixin
    def self.included(base)
      base.add_hook :before_dispatch do
        Merb.logger.info("Setting up session")
        before = cookies[_session_id_key]
        request.session, cookies[_session_id_key] = Merb::ActiveRecordSession.persist(cookies[_session_id_key])
        @_fingerprint = Marshal.dump(request.session.data).hash
        @_new_cookie = cookies[_session_id_key] != before
      end

      base.add_hook :after_dispatch do
        Merb.logger.info("Finalize session")
        request.session.save if @_fingerprint != Marshal.dump(request.session.data).hash
        set_cookie(_session_id_key, request.session.session_id, Time.now + _session_expiry) if (@_new_cookie || request.session.needs_new_cookie)
      end
    end
    
    def session_store_type
      "activerecord"
    end
  end # ActiveRecordMixin

  class ActiveRecordSession < ::ActiveRecord::Base
    set_table_name 'sessions'
    # Customizable data column name.  Defaults to 'data'.
    cattr_accessor :data_column_name
    self.data_column_name = 'data'
    before_save :marshal_data!
    before_save :raise_on_session_data_overflow!
    attr_accessor :needs_new_cookie

    class << self
      # Generates a new session ID and creates a row for the new session in the database.
      def generate
        create(:session_id => Merb::SessionMixin::rand_uuid, :data => {})
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
        [session, session.session_id]
      end
    
      # Don't try to reload ARStore::Session in dev mode.
      def reloadable? #:nodoc:
        false
      end

      def data_column_size_limit
        @data_column_size_limit ||= columns_hash[@@data_column_name].limit
      end

      def marshal(data)   Base64.encode64(Marshal.dump(data)) if data end
      def unmarshal(data) Marshal.load(Base64.decode64(data)) if data end

      def create_table!
        connection.execute <<-end_sql
          CREATE TABLE #{table_name} (
            id INTEGER PRIMARY KEY,
            #{connection.quote_column_name('session_id')} TEXT UNIQUE,
            #{connection.quote_column_name(@@data_column_name)} TEXT(255)
          )
        end_sql
      end

      def drop_table!
        connection.execute "DROP TABLE #{table_name}"
      end
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
    def delete(key = nil)
      key ? self.data.delete(key) : self.data.clear
    end
  
    def [](key)
      data[key]
    end
  
    def empty?
      data.empty?
    end
  
    def each(&b)
      data.each(&b)
    end
  
    def []=(key, val)
      data[key] = val
    end
    
    # Lazy-unmarshal session state.
    def data
      @data ||= self.class.unmarshal(read_attribute(@@data_column_name)) || {}
    end

    # Has the session been loaded yet?
    def loaded?
      !! @data
    end

    private
      attr_writer :data

      def marshal_data!
        return false if !loaded?
        write_attribute(@@data_column_name, self.class.marshal(self.data))
      end

      # Ensures that the data about to be stored in the database is not
      # larger than the data storage column. Raises
      # ActionController::SessionOverflowError.
      def raise_on_session_data_overflow!
        return false if !loaded?
        limit = self.class.data_column_size_limit
        if loaded? and limit and read_attribute(@@data_column_name).size > limit
          raise MerbController::SessionOverflowError
        end
      end
  end # ActiveRecordSessionMixin
end # Merb
