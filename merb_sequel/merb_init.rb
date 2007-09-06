if Merb::Server.config[:session_store].nil? || Merb::Server.config[:session_store].to_s == "sequel"
end