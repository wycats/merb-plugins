if Merb::Server.config[:session_store].nil? || Merb::Server.config[:session_store].to_s == "active_record"
  puts "Using ActiveRecord sessions"
  begin
    require 'action_controller/flash'
    puts "Rails session compatibilty on."
  rescue  LoadError
    puts "Rails session compatibilty disabled. If you need this then install the actionpack gem"
  end

  require 'merb_active_record'
  class Merb::Controller
    include ::Merb::ActiveRecordSessionMixin
  end
end