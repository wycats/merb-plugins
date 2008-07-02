require File.dirname(__FILE__) + '/../spec_helper'

describe "MerbScrewUnit::Main (controller)" do
  
  # Feel free to remove the specs below
  
  before :all do
    Merb::Router.prepare { |r| r.add_slice(:MerbScrewUnit) } if standalone?
  end
  
  after :all do
    Merb::Router.reset! if standalone?
  end
  
  it "should have access to the slice module" do
    controller = dispatch_to(MerbScrewUnit::Main, :index)
    controller.slice.should == MerbScrewUnit
    controller.slice.should == MerbScrewUnit::Main.slice
  end
  
  it "should have an index action" do
    controller = dispatch_to(MerbScrewUnit::Main, :index)
    controller.status.should == 200
    controller.body.should contain('MerbScrewUnit')
  end
  
  it "should work with the default route" do
    controller = get("/merb_screw_unit/main/index")
    controller.should be_kind_of(MerbScrewUnit::Main)
    controller.action_name.should == 'index'
  end
  
  it "should work with the example named route" do
    controller = get("/merb_screw_unit/index.html")
    controller.should be_kind_of(MerbScrewUnit::Main)
    controller.action_name.should == 'index'
  end
  
  it "should have routes in MerbScrewUnit.routes" do
    MerbScrewUnit.routes.should_not be_empty
  end
  
  it "should have a slice_url helper method for slice-specific routes" do
    controller = dispatch_to(MerbScrewUnit::Main, 'index')
    controller.slice_url(:action => 'show', :format => 'html').should == "/merb_screw_unit/main/show.html"
    controller.slice_url(:merb_screw_unit_index, :format => 'html').should == "/merb_screw_unit/index.html"
  end
  
  it "should have helper methods for dealing with public paths" do
    controller = dispatch_to(MerbScrewUnit::Main, :index)
    controller.public_path_for(:image).should == "/slices/merb_screw_unit/images"
    controller.public_path_for(:javascript).should == "/slices/merb_screw_unit/javascripts"
    controller.public_path_for(:stylesheet).should == "/slices/merb_screw_unit/stylesheets"
  end
  
  it "should have a slice-specific _template_root" do
    MerbScrewUnit::Main._template_root.should == MerbScrewUnit.dir_for(:view)
    MerbScrewUnit::Main._template_root.should == MerbScrewUnit::Application._template_root
  end

end