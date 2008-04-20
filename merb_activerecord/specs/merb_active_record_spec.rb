require File.dirname(__FILE__) + '/spec_helper'

describe Merb::Orms::ActiveRecord::Connect do
  it "is loaded at plugin bootstrap" do
    defined?(Merb::Orms::ActiveRecord::Connect).should == "constant"
  end

  it "is a merb bootloader" do
    Merb::Orms::ActiveRecord::Connect.superclass.should == Merb::BootLoader
  end
end



describe "Merb ActiveRecord extension" do
  before :all do
    @wd = Dir.pwd
    Merb.stub!(:dir_for).with(:config).and_return(@wd)
    @config_file_path = @wd / "database.yml"
    @sample_file_path = @wd / "database.yml.sample"

    @sample_source = Merb::Orms::ActiveRecord.sample_source
    @config_sample = Erubis.load_yaml_file(@sample_source)
  end

  it "is loaded at plugin booststrap" do
    defined?(Merb::Orms::ActiveRecord).should == "constant"
  end

  it "loads config from Merb configurations directory" do
    Merb::Orms::ActiveRecord.config_file.should == @config_file_path
  end

  it "loads config sample from Merb configurations directory" do
    Merb::Orms::ActiveRecord.sample_dest.should == @sample_file_path
  end

  it "provides a sample database.yml with development environment" do
    @config_sample[:development].should be_an_instance_of(Hash)
  end

  it "provides a sample database.yml with test environment" do
    @config_sample[:test].should be_an_instance_of(Hash)
  end

  it "provides a sample database.yml with production environment" do
    @config_sample[:production].should be_an_instance_of(Hash)
  end

  it "uses Unicode and localhost in sample" do
    @config_sample[:development][:host].should == "localhost"
    @config_sample[:development][:encoding].should == "utf8"
  end

  it "stores configurations from config file" do
    Erubis.should_receive(:load_yaml_file).with(@config_file_path).and_return(@config_sample)
    Merb::Orms::ActiveRecord.configurations[:development][:database].should == "sample_development"
  end

  it "provides Rack with a way to start a transcantion" do
    Merb::Orms::ActiveRecord.should respond_to(:open_sandbox!)
  end

  it "provides Rack with a way to stop a transcantion" do
    Merb::Orms::ActiveRecord.should respond_to(:close_sandbox!)
  end
end
