require File.dirname(__FILE__) + '/spec_helper'

describe "MerbScrewUnit (module)" do
  
  it "should have proper specs"
  
  # Feel free to remove the specs below
  
  before :all do
    Merb::Router.prepare { |r| r.add_slice(:MerbScrewUnit) } if standalone?
  end
  
  after :all do
    Merb::Router.reset! if standalone?
  end
  
  it "should be registered in Merb::Slices.slices" do
    Merb::Slices.slices.should include(MerbScrewUnit)
  end
  
  it "should be registered in Merb::Slices.paths" do
    Merb::Slices.paths[MerbScrewUnit.name].should == current_slice_root
  end
  
  it "should have an :identifier property" do
    MerbScrewUnit.identifier.should == "merb_screw_unit"
  end
  
  it "should have an :identifier_sym property" do
    MerbScrewUnit.identifier_sym.should == :merb_screw_unit
  end
  
  it "should have a :root property" do
    MerbScrewUnit.root.should == Merb::Slices.paths[MerbScrewUnit.name]
    MerbScrewUnit.root_path('app').should == current_slice_root / 'app'
  end
  
  it "should have a :file property" do
    MerbScrewUnit.file.should == current_slice_root / 'lib' / 'merb_screw_unit.rb'
  end
  
  it "should have metadata properties" do
    MerbScrewUnit.description.should == "MerbScrewUnit is a chunky Merb slice!"
    MerbScrewUnit.version.should == "0.0.1"
    MerbScrewUnit.author.should == "YOUR NAME"
  end
  
  it "should have :routes and :named_routes properties" do
    MerbScrewUnit.routes.should_not be_empty
    MerbScrewUnit.named_routes[:merb_screw_unit_index].should be_kind_of(Merb::Router::Route)
  end

  it "should have an url helper method for slice-specific routes" do
    MerbScrewUnit.url(:controller => 'main', :action => 'show', :format => 'html').should == "/merb_screw_unit/main/show.html"
    MerbScrewUnit.url(:merb_screw_unit_index, :format => 'html').should == "/merb_screw_unit/index.html"
  end
  
  it "should have a config property (Hash)" do
    MerbScrewUnit.config.should be_kind_of(Hash)
  end
  
  it "should have bracket accessors as shortcuts to the config" do
    MerbScrewUnit[:foo] = 'bar'
    MerbScrewUnit[:foo].should == 'bar'
    MerbScrewUnit[:foo].should == MerbScrewUnit.config[:foo]
  end
  
  it "should have a :layout config option set" do
    MerbScrewUnit.config[:layout].should == :merb_screw_unit
  end
  
  it "should have a dir_for method" do
    app_path = MerbScrewUnit.dir_for(:application)
    app_path.should == current_slice_root / 'app'
    [:view, :model, :controller, :helper, :mailer, :part].each do |type|
      MerbScrewUnit.dir_for(type).should == app_path / "#{type}s"
    end
    public_path = MerbScrewUnit.dir_for(:public)
    public_path.should == current_slice_root / 'public'
    [:stylesheet, :javascript, :image].each do |type|
      MerbScrewUnit.dir_for(type).should == public_path / "#{type}s"
    end
  end
  
  it "should have a app_dir_for method" do
    root_path = MerbScrewUnit.app_dir_for(:root)
    root_path.should == Merb.root / 'slices' / 'merb_screw_unit'
    app_path = MerbScrewUnit.app_dir_for(:application)
    app_path.should == root_path / 'app'
    [:view, :model, :controller, :helper, :mailer, :part].each do |type|
      MerbScrewUnit.app_dir_for(type).should == app_path / "#{type}s"
    end
    public_path = MerbScrewUnit.app_dir_for(:public)
    public_path.should == Merb.dir_for(:public) / 'slices' / 'merb_screw_unit'
    [:stylesheet, :javascript, :image].each do |type|
      MerbScrewUnit.app_dir_for(type).should == public_path / "#{type}s"
    end
  end
  
  it "should have a public_dir_for method" do
    public_path = MerbScrewUnit.public_dir_for(:public)
    public_path.should == '/slices' / 'merb_screw_unit'
    [:stylesheet, :javascript, :image].each do |type|
      MerbScrewUnit.public_dir_for(type).should == public_path / "#{type}s"
    end
  end
  
  it "should have a public_path_for method" do
    public_path = MerbScrewUnit.public_dir_for(:public)
    MerbScrewUnit.public_path_for("path", "to", "file").should == public_path / "path" / "to" / "file"
    [:stylesheet, :javascript, :image].each do |type|
      MerbScrewUnit.public_path_for(type, "path", "to", "file").should == public_path / "#{type}s" / "path" / "to" / "file"
    end
  end
  
  it "should have a app_path_for method" do
    MerbScrewUnit.app_path_for("path", "to", "file").should == MerbScrewUnit.app_dir_for(:root) / "path" / "to" / "file"
    MerbScrewUnit.app_path_for(:controller, "path", "to", "file").should == MerbScrewUnit.app_dir_for(:controller) / "path" / "to" / "file"
  end
  
  it "should have a slice_path_for method" do
    MerbScrewUnit.slice_path_for("path", "to", "file").should == MerbScrewUnit.dir_for(:root) / "path" / "to" / "file"
    MerbScrewUnit.slice_path_for(:controller, "path", "to", "file").should == MerbScrewUnit.dir_for(:controller) / "path" / "to" / "file"
  end
  
  it "should keep a list of path component types to use when copying files" do
    (MerbScrewUnit.mirrored_components & MerbScrewUnit.slice_paths.keys).length.should == MerbScrewUnit.mirrored_components.length
  end
  
end