dir = File.dirname(__FILE__)
require "#{dir}/../../../spec_helper"

module Spec
  module Merb
    module DSL
      module ControllerBehaviourSpec
        def run(behaviour)
          errors = StringIO.new
          formatter = Spec::Runner::Formatter::BaseTextFormatter.new(errors)
          reporter = Spec::Runner::Reporter.new([formatter], Spec::Runner::QuietBacktraceTweaker.new)
          behaviour.run(reporter)
          unless reporter.dump == 0
            fail errors.string
          end
        end
      end
      
      describe ControllerBehaviour, "being evaled" do
        include ControllerBehaviourSpec

        it "inherits from EvalModule" do
          behaviour = ControllerBehaviour.new do
            @behaviour_superclass.should == Spec::Merb::DSL::EvalModule
          end
        end

        it "instantiates a fake request and a response" do
          request = nil
          response = nil
          behaviour = ControllerBehaviour.new(FooController) do
            it "runs example" do
              request = @request
              response = @response
            end
          end

          run behaviour

          request.class.should == ::Spec::Merb::Fakes::FakeRequest
          response.class.should == StringIO
          response.read.should == ""
        end
      end

      describe ControllerBehaviour, "receiving get" do
        include ControllerBehaviourSpec

        it "dispatches a GET request" do
          controller = nil
          request = nil
          behaviour = ControllerBehaviour.new(FooController) do
            it "runs example" do
              get 'bar'
              controller = @controller
              request = @request
            end
          end
          run behaviour

          request.should be_get
          request.uri.should == "/foo_controller/bar"
        end
      end

      describe ControllerBehaviour, "receiving post" do
        include ControllerBehaviourSpec

        it "dispatches a POST request" do
          controller = nil
          request = nil
          behaviour = ControllerBehaviour.new(FooController) do
            it "runs example" do
              post 'bar'
              controller = @controller
              request = @request
            end
          end
          run behaviour

          request.should be_post
          request.uri.should == "/foo_controller/bar"
        end
      end

      describe ControllerBehaviour, "receiving create_controller" do
        include ControllerBehaviourSpec
        
        it 'creates a controller based on the description' do
          controller = nil
          behaviour = ControllerBehaviour.new(FooController) do
            it "runs example" do
              create_controller('bar')
              controller = @controller
            end
          end

          run behaviour

          controller.class.should == FooController
          controller.params[:controller].should == 'FooController'
          controller.params[:action].should == 'bar'
        end

        it 'creates a controller with overridden controller name' do
          controller = nil
          behaviour = ControllerBehaviour.new(FooController) do
            it "runs example" do
              create_controller('bar', "AnotherController")
              controller = @controller
            end
          end

          run behaviour

          controller.class.should == FooController
          controller.params[:controller].should == 'AnotherController'
          controller.params[:action].should == 'bar'
        end
      end
    end
  end
end
