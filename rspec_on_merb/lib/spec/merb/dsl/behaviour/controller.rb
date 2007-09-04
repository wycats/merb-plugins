module Spec
  module Merb
    module DSL
      # Controller examples live in $RAILS_ROOT/spec/controllers/.
      class ControllerBehaviour < Spec::DSL::Behaviour
        def before_eval # :nodoc:
          inherit Spec::Merb::DSL::EvalModule
          controller_class = @description.described_type
          before do
            extend ::Spec::Merb::DSL::ControllerSpecHelper
            @controller_class = controller_class
            @request = ::Spec::Merb::Fakes::FakeRequest.new
            @response = StringIO.new
          end
          configure
        end
      end

      module ControllerSpecHelper
        attr_accessor :controller_class

        def get(path, opts={})
          response = StringIO.new
          class << response
            attr_accessor :status, :header, :body
          end
          response.header = {}
          request = ::Merb::FakeRequest.with(path, :request_method => 'GET')
          controller, action = ::Merb::Dispatcher.handle(request, response)
          response.status ||= controller.status
          response.body ||= controller.body
          controller.headers.each do |k, v|
            [*v].each do |vi|
              response.header[k] = vi
            end
          end
          [response, controller]
        end

        def post(path, opts={})  
          m = Multipart::Post.new
          method = opts.delete(:request_method) || 'POST'
          body, head = m.prepare_query(opts)
          request = Spec::Merb::Fakes::FakeRequest.new({:request_uri => path, :path_info => path.sub(/\?.*$/,'')}, method)
          request['REQUEST_METHOD'] = method
          request['CONTENT_TYPE'] = head
          request['CONTENT_LENGTH'] = body.length
          request.post_body = body
          response = StringIO.new
          class << response
            attr_accessor :status, :header, :body
          end
          controller, action = ::Merb::Dispatcher.handle(request, response)
          response.header = {}
          response.status ||= controller.status
          response.body ||= controller.body
          controller.headers.each do |k, v|
            [*v].each do |vi|
              response.header[k] = vi
            end
          end
          [response, controller]
        end

      end
    end
  end
end
