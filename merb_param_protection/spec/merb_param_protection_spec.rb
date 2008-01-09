require File.dirname(__FILE__) + '/spec_helper'

describe "merb_param_protection" do
  describe "Controller", "parameter filtering" do
    before(:each) do
      @request = fake_request
    end
    
    describe "accessible parameters" do
      class ParamsAccessibleController < Merb::Controller
        params_accessible :customer => [:name, :phone, :email], :address => [:street, :zip]
        params_accessible :post => [:title, :body]
        def index; end
      end

      class ParamsProtectedController < Merb::Controller
        params_protected :customer => [:activated?, :password], :address => [:long, :lat]
        def index; end
      end
      
      before(:each) do
        @params_accessible_controller = ParamsAccessibleController.build(@request)
        @params_accessible_controller.dispatch('index')
      end

      it "should store the accessible parameters for that controller" do
        @params_accessible_controller.accessible_params_args.should == {
          :address=> [:street, :zip], :post=> [:title, :body], :customer=> [:name, :phone, :email]
        }
      end
    end
    
    describe "protected parameters" do
      before(:each) do
        @params_protected_controller = ParamsProtectedController.build(@request)
        @params_protected_controller.dispatch('index')
      end
      
      it "should store the protected parameters for that controller" do
        @params_protected_controller.protected_params_args.should == {
          :address=> [:long, :lat], :customer=> [:activated?, :password]
        }
      end
    end
    
    describe "param clash prevention" do      
      it "should raise an error 'cannot make accessible'" do
        lambda { 
          class TestAccessibleController < Merb::Controller
            params_protected :customer => [:password]
            params_accessible :customer => [:name, :phone, :email]
            def index; end
          end
        }.should raise_error("Cannot make accessible a controller (TestAccessibleController) that is already protected")
      end
      
      it "should raise an error 'cannot protect'" do
        lambda { 
          class TestProtectedController < Merb::Controller
            params_accessible :customer => [:name, :phone, :email]
            params_protected :customer => [:password]
            def index; end
          end
        }.should raise_error("Cannot protect controller (TestProtectedController) that is already accessible")
      end
    end
  end
  
  describe "param filtering" do    
    before(:each) do
      Merb::Router.prepare do |r|
        @test_route = r.match("/the/:place/:goes/here").to(:controller => "Test", :action => "show").name(:test)
        @default_route = r.default_routes
      end
    
      @in = Merb::Test::FakeRequest.new
      @in['REQUEST_METHOD'] = 'POST'
      @in['CONTENT_TYPE'] = "application/x-www-form-urlencoded"
    end
  
    it "should remove specified params" do
      @in.post_body = "post[title]=hello%20there&post[body]=some%20text&post[status]=published&post[author_id]=1&commit=Submit"
      request = Merb::Request.new(@in)
      request.remove_params_from_object(:post, [:status, :author_id])
      request.params[:post][:title].should == "hello there"
      request.params[:post][:body].should == "some text"
      request.params[:post][:status].should_not == "published"
      request.params[:post][:author_id].should_not == 1
      request.params[:commit].should == "Submit"
    end
  
    it "should restrict parameters" do
      @in.post_body = "post[title]=hello%20there&post[body]=some%20text&post[status]=published&post[author_id]=1&commit=Submit"
      request = Merb::Request.new(@in)
      request.restrict_params(:post, [:title, :body])
      request.params[:post][:title].should == "hello there"
      request.params[:post][:body].should == "some text"
      request.params[:post][:status].should_not == "published"
      request.params[:post][:author_id].should_not == 1
      request.params[:commit].should == "Submit"
      request.trashed_params.should == ["status", "author_id"]
    end
  end

end