module Jerbivore
  class ServletHandler
    @@path_prefix = nil
    @@path_prefix_original = nil
    
    class << self
      
      def path_prefix
        @@path_prefix_original
      end
      
      def path_prefix=(prefix)
        @@path_prefix_original = prefix
        @@path_prefix = (prefix.is_a?(String) ? /^#{prefix.escape_regexp}/ : prefix)
      end
      
      def handle(servlet_request, input, servlet_response, output)
        start = Time.now
        benchmarks = {}

        request = ServletHandler::Request.new(servlet_request, input)
        MERB_LOGGER.info("\nRequest: REQUEST_URI: #{servlet_request.getRequestURI}  (#{Time.now.strftime("%Y-%m-%d %H:%M:%S")})")

        if @@path_prefix
          if request.params['REQUEST_URI'] =~ @@path_prefix
            MERB_LOGGER.info("Path prefix #{@@path_prefix.inspect} removed from PATH_INFO and REQUEST_URI")
            request.params['REQUEST_URI'].sub!(@@path_prefix, '')
            request.params['PATH_INFO'].sub!(@@path_prefix, '')
          else
            raise "Path prefix is set to '#{@@path_prefix.inspect}', but is not in the REQUEST_URI. "
          end
        end
        
        controller, action = Merb::Dispatcher.handle(request, StringIO.new)
        benchmarks.merge!(controller._benchmarks)
        benchmarks[:controller] = controller.class.to_s
        benchmarks[:action]     = action
        
        MERB_LOGGER.info("Routing to controller: #{controller.class} action: #{action}\nRoute Recognition & Parsing HTTP Input took: #{benchmarks[:setup_time]} seconds")
        
        # TODO: handle X-SENDFILE 
        # TODO: handle procs and io objects in the controller.body
        servlet_response.setStatus(controller.status)
        controller.headers.each do |header, value|
          servlet_response.setHeader(header, value)
        end
        body = (controller.body.to_s rescue '')
        output.write(body)
        output.flush
        
        total_request_time = Time.now - start
        benchmarks[:total_request_time] = total_request_time
        MERB_LOGGER.info("Request Times: #{benchmarks.inspect}\nResponse status: #{servlet_response.status}\nComplete Request took: #{total_request_time} seconds, #{1.0/total_request_time} Requests/Second\n\n")
      rescue Object => e
        servlet_response.setStatus(500)
        output.write("500 Internal Server Error")
        output.flush
        MERB_LOGGER.error(Merb.exception(e))
      ensure
        MERB_LOGGER.flush
      end
    end
    
    class Request
      attr_accessor :params, :body
      
      def initialize(servlet_request, input)        
        @params = {
          'PATH_INFO'       => servlet_request.getPathInfo || '',
          'REMOTE_ADDR'     => servlet_request.getRemoteAddr || '',
          'REMOTE_HOST'     => servlet_request.getRemoteHost || '',
          'REMOTE_USER'     => servlet_request.getRemoteUser || '',
          'REQUEST_METHOD'  => servlet_request.getMethod || '',
          'REQUEST_URI'     => servlet_request.getRequestURI || '',
          'SERVER_NAME'     => servlet_request.getServerName || '',
          'SERVER_PORT'     => servlet_request.getServerPort || '',
          'SERVER_PROTOCOL' => servlet_request.getProtocol || '',
        }

        servlet_request.getHeaderNames.each do |header|
          key = "HTTP_#{header.to_s.upcase.gsub('-','_')}"
          @params[key] = servlet_request.getHeader(header)
        end
        
        @body = input
      end
    end
    
  end
end
