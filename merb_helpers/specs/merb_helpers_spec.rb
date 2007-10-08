require File.dirname(__FILE__) + '/spec_helper'
require 'merb_helpers'

include Merb::ViewContextMixin
include Merb::ErubisCaptureMixin
include Merb::Helpers::Form


describe "error_messages_for" do
  before :each do
    @obj = Object.new
    def @obj.errors() [["foo", "bar"], ["baz", "bat"]] end
  end
  
  it "should build default error messages" do
    errs = error_messages_for(@obj)
    errs.should include("<h2>Form submittal failed because of 2 problems</h2>")
    errs.should include("<li>foo bar</li>")
    errs.should include("<li>baz bat</li>")
  end
  
  it "should accept a custom HTML class" do
    errs = error_messages_for(@obj, nil, "foo")
    errs.should include("<div class='foo'>")
  end
  
  it "should accept a custom header block" do
    errs = error_messages_for(@obj) {|errs| "<h3>Failure: #{errs.size} issues</h3>"}
    errs.should include("<h3>Failure: 2 issues</h3>")
  end
  
  it "should accept a custom error list item block" do
    errs = error_messages_for(@obj, proc {|err| "<li>#{err[0]} column: #{err[1]}</li>"})
    errs.should include("<li>foo column: bar</li>")
  end
  
end

class FakeModel
  def self.columns
    [FakeColumn.new(:foo, :string), FakeColumn.new(:bar, :integer)]
  end
  
  def foo
    "foowee"
  end
end

class FakeColumn
  attr_accessor :name, :type
  def initialize(name, type)
    @name, @type = name, type
  end
end

describe "text_control" do
  
  before :each do
    @obj = FakeModel.new
    def _buffer(buf) @buffer ||= "" end    
  end
  
  it "should take a string object and return a useful text control" do
    f = form_for :obj do
      text_control(:foo).should == "<form><input type='text' name='obj[foo]' value='foowee'/>"
    end
    f.should == "<form><input type='text' name='obj[foo]' value='foowee'/></form>"
  end
  
end