puts "MERB SEQUEL"
if Merb::Server.config[:session_store].nil? || Merb::Server.config[:session_store].to_s == "sequel"
  puts "  INCLUDED"
end