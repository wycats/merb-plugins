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

describe "form_tag" do
  it_should_behave_like "FakeBufferConsumer"
  
  it "should take create a form" do
    form_tag(:action => "foo", :method => "POST") do
      _buffer << "Hello"
    end
    _buffer.should match_tag(:form, :action => "foo", :method => "POST")
    _buffer.should include("Hello")
  end
end

describe "form_for" do
  it_should_behave_like "FakeBufferConsumer"  
  
  it "should wrap the contents in a form tag" do
    form_for(:obj) do
      _buffer("") << "Hello"
    end
    _buffer("").should == "<form>Hello</form>"
  end
end

describe "fields_for" do
  it_should_behave_like "FakeBufferConsumer"
  
  it "should dump the contents in the context of the object" do
    fields_for(:obj) do
      _buffer("") << "Hello"
    end
    _buffer("").should == "Hello"
  end  

  it "should be able to modify the context midstream" do
    @obj2 = FakeModel2.new    
    form_for(:obj) do
      text_control(:foo).should match_tag(:input, :type => "text", :value => "foowee")      
      fields_for(:obj2) do
        text_control(:foo).should match_tag(:input, :type => "text", :value => "foowee2")
      end
      text_control(:foo).should match_tag(:input, :type => "text", :value => "foowee")      
    end
  end
end

describe "text_field (basic)" do
  it "should return a basic text field based on the values passed in" do
    text_field(:name => "foo", :value => "bar").should == "<input type=\"text\" name=\"foo\" value=\"bar\"/>"  
  end
end

describe "text_control (data bound)" do
  it_should_behave_like "FakeBufferConsumer"
  
  it "should take a string object and return a useful text control" do
    f = form_for :obj do
      text_control(:foo).should match_tag(:input, :type => "text", :name => "obj[foo]", :value => "foowee")
    end
  end

  it "should take additional attributes and use them" do
    form_for :obj do
      text_control(:foo, :bar => "7").should match_tag(:input, :type => "text", :name => "obj[foo]", :value => "foowee", :bar => "7")
    end
  end
end

describe "checkbox_field (basic)" do
  include TagMatchers
  
  it "should return a basic checkbox based on the values passed in" do
    checkbox_field(:name => "foo", :checked => "checked").should match_tag(:input, :class => "checkbox", :name => "foo", :checked => "checked")
  end
end

describe "checkbox_control (data bound)" do
  it_should_behave_like "FakeBufferConsumer"  
    
  it "should take a string and return a useful checkbox control" do
    form_for :obj do
      checkbox_control(:baz).should match_tag(:input, :type =>"checkbox", :name => "obj[baz]", :class => "checkbox", :value => "1", :checked => "checked")
      checkbox_control(:bat).should match_tag(:input, :type =>"checkbox", :name => "obj[bat]", :class => "checkbox", :value => "0")
    end
  end
  
  it "should render controls with errors if their attribute contains an error" do
    form_for :obj do
      checkbox_control(:bazbad).should match_tag(:input, :type =>"checkbox", :name => "obj[bazbad]", 
        :class => "error checkbox", :value => "1", :checked => "checked")
      checkbox_control(:batbad).should match_tag(:input, :type =>"checkbox", :name => "obj[batbad]", 
        :class => "error checkbox", :value => "0")        
    end
  end
    
end

describe "hidden_field (basic)" do
  include TagMatchers
  
  it "should return a basic checkbox based on the values passed in" do
    hidden_field(:name => "foo", :value => "bar").should match_tag(:input, :type => "hidden", :name => "foo", :value => "bar")
  end
end

describe "hidden_control (data bound)" do
  it_should_behave_like "FakeBufferConsumer"
    
  it "should take a string and return a useful checkbox control" do
    form_for :obj do
      hidden_control(:foo).should match_tag(:input, :type =>"hidden", :name => "obj[foo]", :value => "foowee")
    end
  end
  
  it "should render controls with errors if their attribute contains an error" do
    form_for :obj do
      hidden_control(:foobad).should match_tag(:input, :type =>"hidden", :name => "obj[foobad]", :value => "foowee", :class => "error")
    end
  end
    
end

describe "radio button (basic)" do
  include TagMatchers
  it "should should return a basic radio button based on the values passed in" do
    radio_field(:name => "foo", :value => "bar").should match_tag(:input, :type => "radio", :name => "foo", :value => "bar")
  end
end

describe "radio button groups (data bound)" do
  it_should_behave_like "FakeBufferConsumer"
  
  it "should return a group of radio buttons" do
    form_for :obj do
      radio = radio_group_control(:foo, [:foowee, :baree]).scan(/<[^>]*>/)
      radio[0].should match_tag(:input, :type => "radio", :name => "obj[foo]", :value => "foowee", :selected => "selected")
      radio[1].should match_tag(:input, :type => "radio", :name => "obj[foo]", :value => "baree")
      radio[1].should not_match_tag(:selected => "selected")
    end
  end
end

describe "submit_button" do
  it_should_behave_like "FakeBufferConsumer"
    
  it "should produce a simple submit button" do
    submit_button("Foo").should == "<button type=\"submit\">Foo</button>"
  end
end