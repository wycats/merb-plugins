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
  
  it "should use the post method by default" do
    form_tag do
      _buffer << "CONTENT"
    end
    _buffer.should match_tag(:form, :method => "post")
    _buffer.should include("CONTENT")
  end
  
  it "should use the get method if set" do
    form_tag :method => :get do
      _buffer << "CONTENT"
    end
    _buffer.should match_tag(:form, :method => "get")
    _buffer.should include("CONTENT")        
  end
  
  it "should fake out the put method if set" do
    form_tag :method => :put do
      _buffer << "CONTENT"
    end
    _buffer.should match_tag(:form, :method => "post")
    _buffer.should match_tag(:input, :type => "hidden", :name => "_method", :value => "put")    
  end
  
  it "should fake out the delete method if set" do
    form_tag :method => :delete do
      _buffer << "CONTENT"
    end
    _buffer.should match_tag(:form, :method => "post")
    _buffer.should match_tag(:input, :type => "hidden", :name => "_method", :value => "delete")
  end
  
  it "should silently set method to post if an unsupported method is used" do
      form_tag :method => :dodgy do
        _buffer << "CONTENT"
      end
      _buffer.should match_tag(:form, :method => "post")
      _buffer.should_not match_tag(:input, :type => "hidden", :name => "_method", :value => "dodgy")
  end
  
  it "should take create a form" do
    form_tag(:action => "foo", :method => :post) do
      _buffer << "Hello"
    end
    _buffer.should match_tag(:form, :action => "foo", :method => "post")
    _buffer.should include("Hello")
  end
  
  it "should set a form to be mutlipart" do
    form_tag( :action => "foo", :method => :post, :multipart => true ) do
      _buffer << "CONTENT"
    end
    _buffer.should match_tag( :form, :action => "foo", :method => "post", :enctype => "multipart/form-data")
    _buffer.should include("CONTENT")  
  end
end

describe "form_for" do
  it_should_behave_like "FakeBufferConsumer"  
  
  it "should wrap the contents in a form tag" do
    form_for(:obj) do
      _buffer << "Hello"
    end
    _buffer.should match_tag(:form, :method => "post")
    _buffer.should match_tag(:input, :type => "hidden", :value => "put", :name => "_method")    
  end
  
  it "should set the method to post be default" do
    @obj2 = FakeModel2.new
    form_for(:obj2) do
    end
    _buffer.should match_tag(:form, :method => "post")
    _buffer.should_not match_tag(:input, :type => "hidden", :name => "_method")
  end
  
  it "should support PUT if the object passed in is not a new_record? via a hidden field" do
    form_for(:obj) do
    end
    _buffer.should match_tag(:form, :method => "post")
    _buffer.should match_tag(:input, :type => "hidden", :value => "put", :name => "_method")    
  end
  
end

describe "fields_for" do
  it_should_behave_like "FakeBufferConsumer"
  
  it "should dump the contents in the context of the object" do
    fields_for(:obj) do
      text_control(:foo).should match_tag(:input, :type => "text", :value => "foowee")
      _buffer << "Hello"
    end
    _buffer.should == "Hello"
  end  

  it "should be able to modify the context midstream" do
    @obj2 = FakeModel2.new    
    form_for(:obj) do
      text_control(:foo).should match_tag(:input, :type => "text", :value => "foowee")      
      fields_for(:obj2) do
        text_control(:foo).should match_tag(:input, :name => "fake_model2[foo]", :type => "text", :value => "foowee2")
      end
      text_control(:foo).should match_tag(:input, :type => "text", :value => "foowee")      
    end
  end
  
  it "should handle an explicit nil attribute" do
    fields_for(:obj, nil) do
      _buffer << text_control(:foo)
    end
    _buffer.should match_tag(:input, :name => "fake_model[foo]", :value => "foowee", :type => "text")
  end
  
end

describe "text_field (basic)" do
  it_should_behave_like "FakeBufferConsumer"
  
  it "should return a basic text field based on the values passed in" do
    text_field(:name => "foo", :value => "bar").should match_tag( :input, :type => "text", :name => "foo", :value => "bar")
  end
  
  it "should wrap the field in a label if the :label option is passed to the text_field" do
    result = text_field(:label => "LABEL" )
    result.should match(/<label>LABEL<input type="text"\s*\/><\/label>/)
  end
end

describe "text_control (data bound)" do
  it_should_behave_like "FakeBufferConsumer"
  
  it "should take a string object and return a useful text control" do
    f = form_for :obj do
      text_control(:foo).should match_tag(:input, :type => "text", :name => "fake_model[foo]", :value => "foowee")
    end
  end

  it "should take additional attributes and use them" do
    form_for :obj do
      text_control(:foo, :bar => "7").should match_tag(:input, :type => "text", :name => "fake_model[foo]", :value => "foowee", :bar => "7")
    end
  end
  
  it "should wrap the text_control in a label if the :label option is passed in" do
    form_for :obj do
      _buffer << text_control(:foo, :label => "LABEL")
    end
    _buffer.should match(/<label>LABEL<input/)
    res = _buffer.scan(/<[^>]*>/)
    res[2].should_not match_tag(:input, :label => "LABEL")
  end
end

describe "password_field (basic)" do
  it_should_behave_like "FakeBufferConsumer"
  
  it "should return a basic password field, but omit the value" do
    password_field(:name => "foo", :value => "bar").should match_tag(:input, :type => "password", :name => "foo")
  end
  
  it "should wrap the field in a label if the :label option is passed to the text_field" do
    result = password_field(:label => "LABEL" )
    result.should match(/<label>LABEL<input type="password"\s*\/><\/label>/)
  end
end

describe "password_control (data bound)" do
  it_should_behave_like "FakeBufferConsumer"
  
  it "should take a string object and return a useful password control, but omit the value" do
    f = form_for :obj do
      password_control(:foo).should match_tag(:input, :type => "password", :name => "fake_model[foo]")
    end
  end

  it "should take additional attributes and use them" do
    form_for :obj do
      password_control(:foo, :bar => "7").should match_tag(:input, :type => "password", :name => "fake_model[foo]", :bar => "7")
    end
  end
  
  it "should wrap the text_control in a label if the :label option is passed in" do
    form_for :obj do
      _buffer << password_control(:foo, :label => "LABEL")
    end
    _buffer.should match(/<label>LABEL<input/)
    res = _buffer.scan(/<[^>]*>/)
    res[2].should_not match_tag(:input, :label => "LABEL")
  end
end

describe "checkbox_field (basic)" do
  it "should return a basic checkbox based on the values passed in" do
    checkbox_field(:name => "foo", :checked => "checked").should match_tag(:input, :class => "checkbox", :name => "foo", :checked => "checked")
  end
  
  it "should wrap the checkbox_field in a label if the :label option is passed in" do
    result = checkbox_field(:label => "LABEL" )
    result.should match(/<label>LABEL<input/)
    res = result.scan(/<[^>]*>/)
    res[2].should_not match_tag(:input, :label => "LABEL")
  end
end

describe "checkbox_control (data bound)" do
  it_should_behave_like "FakeBufferConsumer"  
    
  it "should take a string and return a useful checkbox control" do
    form_for :obj do
      checkbox_control(:baz).should match_tag(:input, :type =>"checkbox", :name => "fake_model[baz]", :class => "checkbox", :value => "1", :checked => "checked")
      checkbox_control(:bat).should match_tag(:input, :type =>"checkbox", :name => "fake_model[bat]", :class => "checkbox", :value => "0")
    end
  end
  
  it "should allow a user to set the :off value" do
    form_for :obj do
      checkbox_control(:baz, :off => "off", :on => "on").should match_tag(:input, :type =>"checkbox", :name => "fake_model[baz]", :class => "checkbox", :value => "on", :checked => "checked")
      checkbox_control(:bat, :off => "off", :on => "on").should match_tag(:input, :type =>"checkbox", :name => "fake_model[bat]", :class => "checkbox", :value => "off")
    end
  end
  
  it "should evaulate nil, false, 0 and '0' to false. All else to true" do
    send(:col_val_to_bool, nil).should   == false
    send(:col_val_to_bool, false).should == false
    send(:col_val_to_bool, 0).should     == false
    send(:col_val_to_bool, '0').should   == false
    send(:col_val_to_bool, 1).should     == true
    send(:col_val_to_bool, '1').should   == true
    send(:col_val_to_bool, true).should  == true
  end

  it "should render controls with errors if their attribute contains an error" do
    form_for :obj do
      checkbox_control(:bazbad).should match_tag(:input, :type =>"checkbox", :name => "fake_model[bazbad]", 
        :class => "error checkbox", :value => "1", :checked => "checked")
      checkbox_control(:batbad).should match_tag(:input, :type =>"checkbox", :name => "fake_model[batbad]", 
        :class => "error checkbox", :value => "0")        
    end
  end  
  
  it "should wrap the checkbox_control in a label if the label option is passed in" do
    form_for :obj do
      _buffer << checkbox_control(:foo, :label => "LABEL")
    end
    _buffer.should match( /<label>LABEL<input/ )
    res = _buffer.scan(/<[^>]*>/)
    res[2].should_not match_tag(:input, :label => "LABEL")
    end
end

describe "hidden_field (basic)" do
  
  it "should return a basic checkbox based on the values passed in" do
    hidden_field(:name => "foo", :value => "bar").should match_tag(:input, :type => "hidden", :name => "foo", :value => "bar")
  end
  
  it "should not render a label if the :label option is passed in" do
    res = hidden_field(:label => "LABEL")
    res.should_not match(/<label>LABEL/)
    res.should_not match_tag(:input, :label=> "LABEL")  
  end
end

describe "hidden_control (data bound)" do
  it_should_behave_like "FakeBufferConsumer"
    
  it "should take a string and return a useful checkbox control" do
    form_for :obj do 
      hidden_control(:foo).should match_tag(:input, :type =>"hidden", :name => "fake_model[foo]", :value => "foowee")
    end
  end
  
  it "should render controls with errors if their attribute contains an error" do
    form_for :obj do
      hidden_control(:foobad).should match_tag(:input, :type =>"hidden", :name => "fake_model[foobad]", :value => "foowee", :class => "error")
    end
  end
  
  it "should not render a label if the :label option is passed in" do
    form_for :obj do
      res = hidden_control(:foo, :label => "LABEL")
      res.should_not match(/<label>LABEL/)
      res.should_not match_tag(:input, :label=> "LABEL")  
    end
  end
    
end

describe "radio button (basic)" do
  it "should should return a basic radio button based on the values passed in" do
    radio_field(:name => "foo", :value => "bar").should match_tag(:input, :type => "radio", :name => "foo", :value => "bar")
  end
  
  it "should render a label when the label is passed in" do
    result = radio_field(:name => "foo", :value => "bar", :label => "LABEL")
    result.should match(/<label>LABEL<input/)
    res = result.scan(/<[^>]*>/)
    res[2].should_not match_tag(:input, :label => "LABEL")
  end
  
end

describe "radio button groups (data bound)" do
  it_should_behave_like "FakeBufferConsumer"
  
  it "should return a group of radio buttons" do
    form_for :obj do
      radio = radio_group_control(:foo, [:foowee, :baree]).scan(/<[^>]*>/)
      radio[1].should match_tag(:input, :type => "radio", :name => "fake_model[foo]", :value => "foowee", :selected => "selected")
      radio[4].should match_tag(:input, :type => "radio", :name => "fake_model[foo]", :value => "baree")
      radio[2].should not_match_tag(:selected => "selected")
    end
  end
  
  it "should wrap the each radio button in the group in a label corresponding to the options" do
    form_for :obj do
      radio = radio_group_control(:foo, [:foowee, :baree])
      radio.scan( /<label>(foowee|baree)<input/ ).size.should == 2
      radio = radio.scan(/<[^>]*>/)
      radio[1].should_not match_tag(:input, :label => "LABEL")
      radio[4].should_not match_tag(:input, :label => "LABEL")
    end
  end
end

describe "text area (basic)" do
  it "should should return a basic text area based on the values passed in" do
    text_area_field("foo", :name => "foo").should match_tag(:textarea, :name => "foo")
  end
  
  it "should handle a nil content" do
    text_area_field(nil, :name => "foo").should == "<textarea name=\"foo\"></textarea>"
  end
  
  it "should handle a nil attributes hash" do
    text_area_field("CONTENT", nil).should == "<textarea>CONTENT</textarea>"
  end
  
  it "should render a label when the label is passed in" do
    result = text_area_field( "CONTENT", :name => "foo", :value => "bar", :label => "LABEL")
    result.should match(/<label>LABEL<textarea/)
    res = result.scan(/<[^>]*>/)
    res[1].should_not match_tag(:textarea, :label => "LABEL")
  end
end

describe "text area (data bound)" do
  it_should_behave_like "FakeBufferConsumer"
  
  it "should return a bound text area" do
    form_for :obj do
      ta = text_area_control(:foo)
      tab = text_area_control(:foobad)
      ta.should match_tag(:textarea, :name => "fake_model[foo]")
      tab.should match_tag(:textarea, :name => "fake_model[foobad]", :class => "error")
      ta.should include("foowee")
    end
  end
  
  it "should handle a nil content value" do
    @obj.nothing.should be_nil
    form_for :obj do
      text_area_control(:nothing).should match_tag(:textarea, :name => "fake_model[nothing]")
    end
  end
  
  it "should handle a nil attribute hash" do
    form_for :obj do
      text_area_control(:nothing, nil).should match_tag(:textarea, :name => "fake_model[nothing]")
    end
  end

  it "should render a label when the label is passed in" do
    form_for :obj do
      result = text_area_control( :foo, :label => "LABEL")
      result.should match(/<label>LABEL<textarea/)
      res = result.scan(/<[^>]*>/)
      res[1].should_not match_tag(:textarea, :label => "LABEL")
    end
  end

end

describe "form helper supporting methods for controls" do
  it_should_behave_like "FakeBufferConsumer"
  
  it "should give class_name[colname] for control_name" do
    form_for :obj do
      text_control( :foo ).should match_tag( :input, :type => "text", :name => "fake_model[foo]")
    end
  end
  
  it "should provide value=method_value for the control_value method" do
    form_for :obj do
      text_control( :foo ).should match_tag( :input, :type => "text", :value => "foowee")
    end
  end
  
  it "should give name and value for a call to control_name_value" do
    form_for :obj do
      control_name_value(:foo, :attribute => "ATTRIBUTE" ).should == {  :name => "fake_model[foo]",
                                                                        :value => "foowee",
                                                                        :attribute => "ATTRIBUTE"}
    end    
  end
end

describe "submit_button" do
  it_should_behave_like "FakeBufferConsumer"
    
  it "should produce a simple submit button" do
    submit_button("Foo").should == "<button type=\"submit\">Foo</button>"
  end
end

describe "label helpers" do
  it_should_behave_like "FakeBufferConsumer"
  
  it "should add a label to arbitrary markup in a template" do
    result = label("Name:", text_field(:name => "name_value"))
    result.should == "<label>Name:<input type=\"text\" name=\"name_value\"/></label>"
    
  end
    
end

