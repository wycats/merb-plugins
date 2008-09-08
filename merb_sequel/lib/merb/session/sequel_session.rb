require 'sequel'
require 'merb-core/dispatch/session'
require 'base64'

module Merb

  table_name = (Merb::Plugins.config[:merb_sequel][:session_table_name] || "sessions")

  # Sessions stored in Sequel model.
  #
  # To use Sequel based sessions add the following to config/init.rb:
  #
  # Merb::Config[:session_store] = 'sequel'

  class SequelSessionStore < Sequel::Model(table_name.to_sym)
    
    set_schema do
      primary_key :id
      varchar :session_id
      text :data
      timestamp :created_at
    end

    class << self
      
      # ==== Parameters
      # session_id<String>:: ID of the session to retrieve.
      #
      # ==== Returns
      # ContainerSession:: The session corresponding to the ID.
      def retrieve_session(session_id)
        if item = find(:session_id => session_id)
          item.data
        end
      end

      # ==== Parameters
      # session_id<String>:: ID of the session to set.
      # data<ContainerSession>:: The session to set.
      def store_session(session_id, data)
        if item = find(:session_id => session_id)
          item.update(:data => data)
        else
          create(:session_id => session_id, :data => data, :created_at => Time.now)
        end
      end

      # ==== Parameters
      # session_id<String>:: ID of the session to delete.
      def delete_session(session_id)
        if item = find(:session_id => session_id)
          item.delete
        end
      end
    
      # ==== Returns
      # Integer:: The maximum length of the 'data' column.
      def data_column_size_limit
        512 # TODO - figure out how much space we actually have
      end

      alias :create_table! :create_table
      alias :drop_table! :drop_table
    end

    # Lazy-unserialize session state.
    def data
      @data ||= (@values[:data] ? Marshal.load(@values[:data]) : {})
    end
    
    # Virtual attribute writer - override.
    def data=(hsh)
      @data = hsh if hsh.is_a?(Hash)
    end

    # Has the session been loaded yet?
    def loaded?
      !!@data
    end

    before_save do 
      @values[:data] = Marshal.dump(self.data)
      if @values[:data].size > self.class.data_column_size_limit
        raise Merb::SessionMixin::SessionOverflow
      end    
    end
    
  end

  unless Sequel::Model.db.table_exists?(table_name.to_sym)
    puts "Warning: The database did not contain a '#{table_name}' table for sessions."
    SequelSessionStore.class_eval { create_table unless table_exists? }
    puts "Created sessions table."
  end
  
  class SequelSession < SessionStoreContainer
    
    # The session store type
    self.session_store_type = :sequel
    
    # The store object is the model class itself
    self.store = SequelSessionStore
    
  end

end
