require 'merb-core/dispatch/session'
require 'active_record'
require 'base64'

module Merb

  # Sessions stored in ActiveRecord model.
  #
  # To use ActiveRecord based sessions add the following to config/init.rb:
  #
  # Merb::Config[:session_store] = 'activerecord'
  
  class ActiveRecordSessionStore < ::ActiveRecord::Base
  
    table_name = (Merb::Plugins.config[:merb_active_record][:session_table_name] || "sessions")
  
    set_table_name table_name
    
    serialize :data
  
    class << self
  
      # ==== Parameters
      # session_id<String>:: ID of the session to retrieve.
      #
      # ==== Returns
      # ContainerSession:: The session corresponding to the ID.
      def retrieve_session(session_id)
        if item = find_by_session_id(session_id)
          item.data
        end
      end

      # ==== Parameters
      # session_id<String>:: ID of the session to set.
      # data<ContainerSession>:: The session to set.
      def store_session(session_id, data)
        if item = find_by_session_id(session_id)
          item.update_attributes!(:data => data)
        else
          create(:session_id => session_id, :data => data)
        end
      end

      # ==== Parameters
      # session_id<String>:: ID of the session to delete.
      def delete_session(session_id)
        delete_all(["#{connection.quote_column_name('session_id')} IN (?)", session_id])
      end
    
    end

  end
  
  class ActiveRecordSession < SessionStoreContainer
    
    # The session store type
    self.session_store_type = :activerecord
    
    # The store object is the model class itself
    self.store = ActiveRecordSessionStore
    
  end
    
end