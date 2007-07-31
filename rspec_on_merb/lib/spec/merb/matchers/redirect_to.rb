module Spec
  module Merb
    module Matchers

      class RedirectTo  #:nodoc:
      end

      # :call-seq:
      #   response.should redirect_to(url)
      #   response.should redirect_to(:action => action_name)
      #   response.should redirect_to(:controller => controller_name, :action => action_name)
      #   response.should_not redirect_to(url)
      #   response.should_not redirect_to(:action => action_name)
      #   response.should_not redirect_to(:controller => controller_name, :action => action_name)
      #
      # Passes if the response is a redirect to the url, action or controller/action.
      # Useful in controller specs (integration or isolation mode).
      #
      # == Examples
      #
      #   response.should redirect_to("path/to/action")
      #   response.should redirect_to("http://test.host/path/to/action")
      #   response.should redirect_to(:action => 'list')
      def redirect_to(opts)
        RedirectTo.new(request, opts)
      end
    end

  end
end
