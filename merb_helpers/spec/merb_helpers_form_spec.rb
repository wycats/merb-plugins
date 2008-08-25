require File.dirname(__FILE__) + '/spec_helper'

Merb::Plugins.config[:helpers] = {
  :form_class => Merb::Helpers::Form::Builder::FormWithErrors
}

# @todo - error_messages_for needs more complete specs
describe "error_messages_for" do
  it_should_behave_like "FakeController"  
  
  before :each do
    @dm_obj = Object.new
    @sq_obj = Object.new
    @dm_errors = [["foo", "bar"],["baz","bat"]]
    @sq_errors = Object.new
    @sq_errors.stub!(:full_messages).and_return(["foo", "baz"])
    @dm_obj.stub!(:errors).and_return(@dm_errors)
    @dm_obj.stub!(:new_record?).and_return(false)
    @sq_obj.stub!(:errors).and_return(@sq_errors)
    @sq_obj.stub!(:new_record?).and_return(false)
  end

  it "should build default error messages for AR-like models" do
    errs = error_messages_for(@dm_obj)
    errs.should include("<h2>Form submission failed because of 2 problems</h2>")
    errs.should include("<li>foo bar</li>")
    errs.should include("<li>baz bat</li>")
  end

  it "should build default error messages for Sequel-like models" do
    errs = error_messages_for(@sq_obj)
    errs.should include("<h2>Form submission failed because of 2 problems</h2>")
    errs.should include("<li>foo</li>")
    errs.should include("<li>baz</li>")
  end

  # it "should build default error messages for symbol" do
  #   errs = error_messages_for(:obj)
  #   errs.should include("<h2>Form submittal failed because of 2 problems</h2>")
  #   errs.should include("<li>foo bar</li>")
  #   errs.should include("<li>baz bat</li>")
  # end

  it "should accept a custom HTML class" do
    errs = error_messages_for(@dm_obj, :error_class => "foo")
    errs.should include("<div class='foo'>")
  end
  
  it "should accept a custom header block" do
    errs = error_messages_for(@dm_obj, :header => "<h3>Failure: %s issue%s</h3>")
    errs.should include("<h3>Failure: 2 issues</h3>")
  end
  
  it "should put the error messages inside a form if :before is false" do
    ret = form_for @dm_obj do
      _buffer << error_messages
    end
    ret.should =~ /\A\s*<form.*<div class='error'>/    
  end
end

describe "form" do
  it_should_behave_like "FakeController"

  it "should use the post method by default" do
    ret = form do
      _buffer << "CONTENT"
    end
    ret.should match_tag(:form, :method => "post")
    ret.should include("CONTENT")
  end

  it "should use the get method if set" do
    ret = form :method => :get do
      _buffer << "CONTENT"
    end
    ret.should == "<form method=\"get\">CONTENT</form>"
  end
  
  it "should fake out the put method if set" do
    ret = form :method => :put do
      _buffer << "CONTENT"
    end
    ret.should =~ %r{<form method="post"><input type="hidden" value="put" name="_method"/>CONTENT</form>}
  end
  
  it "should fake out the delete method if set" do
    ret = form :method => :delete do
      _buffer << "CONTENT"
    end
    ret.should match_tag(:form, :method => "post")
    ret.should match_tag(:input, :type => "hidden", :name => "_method", :value => "delete")
  end
  
  # TODO: Why is this required?
  # ---------------------------
  # 
  # it "should silently set method to post if an unsupported method is used" do
  #     form_tag :method => :dodgy do
  #       _buffer << "CONTENT"
  #     end
  #     _buffer.should match_tag(:form, :method => "post")
  #     _buffer.should_not match_tag(:input, :type => "hidden", :name => "_method", :value => "dodgy")
  # end
  
  it "should take create a form" do
    ret = form(:action => "foo", :method => :post) do
      _buffer << "Hello"
    end
    ret.should match_tag(:form, :action => "foo", :method => "post")
    ret.should include("Hello")
  end
  
  it "should set a form to be multipart" do
    ret = form( :action => "foo", :method => :post, :multipart => true ) do
      _buffer << "CONTENT"
    end
    ret.should match_tag( :form, :action => "foo", :method => "post", :enctype => "multipart/form-data")
    ret.should include("CONTENT")
  end
end

describe "form_for" do
  it_should_behave_like "FakeController"

  it "should wrap the contents in a form tag" do
    form = form_for(:obj) do
      _buffer << "Hello"
    end
    form.should match_tag(:form, :method => "post")
    form.should match_tag(:input, :type => "hidden", :value => "put", :name => "_method")
  end

  it "should set the method to post be default" do
    @obj2 = FakeModel2.new
    form = form_for(:obj2) do
    end
    form.should match_tag(:form, :method => "post")
    form.should_not match_tag(:input, :type => "hidden", :name => "_method")
  end

  it "should support PUT if the object passed in is not a new_record? via a hidden field" do
    form = form_for(:obj) do
    end
    form.should match_tag(:form, :method => "post")
    form.should match_tag(:input, :type => "hidden", :value => "put", :name => "_method")
  end

end

describe "fields_for" do
  it_should_behave_like "FakeController"

  it "should dump the contents in the context of the object" do
    _buffer = ""
    fields_for(:obj) do
      text_field(:foo).should match_tag(:input, :type => "text", :value => "foowee")
      _buffer << "Hello"
    end
    _buffer.should == "Hello"
  end

  it "should be able to modify the context midstream" do
    @obj2 = FakeModel2.new
    form_for(:obj) do
      text_field(:foo).should match_tag(:input, :type => "text", :value => "foowee")
      fields_for(@obj2) do
        text_field(:foo).should match_tag(:input, :name => "fake_model2[foo]", :type => "text", :value => "foowee2")
      end
      text_field(:foo).should match_tag(:input, :type => "text", :value => "foowee")
    end
  end

  it "should handle an explicit nil attribute" do
    fields_for(@obj, nil) do
      _buffer << text_field(:foo)
    end
    _buffer.should match_tag(:input, :name => "fake_model[foo]", :value => "foowee", :type => "text")
  end

  it "should pass context back to the old object after exiting block" do
    @obj2 = FakeModel2.new
    fields_for(@obj) do
      text_field(:foo).should match_tag(:input, :id => "fake_model_foo", :name => "fake_model[foo]", :type => "text")

      fields_for(@obj2) do
        text_field(:foo).should match_tag(:input, :id => "fake_model2_foo", :name => "fake_model2[foo]", :type => "text")
      end

      text_field(:bar).should match_tag(:input, :id => "fake_model_bar", :name => "fake_model[bar]", :type => "text")
    end
  end
end

describe "text_field" do
  it_should_behave_like "FakeController"

  it "should return a basic text field based on the values passed in" do
    text_field(:name => "foo", :value => "bar").should match_tag( :input, :type => "text", :name => "foo", :value => "bar")
  end

  it "should provide an additional label tag if the :label option is passed in" do
    result = text_field(:label => "LABEL" )
    result.should match(/<label>LABEL<\/label><input type="text" class="text"\s*\/>/)
  end

  it "should update an existing :class with a new class" do
    result = text_field(:class => "awesome foobar")
    result.should == "<input type=\"text\" class=\"awesome foobar text\"/>"
  end
  
  it "should be disabled if :disabled => true is passed in" do
    text_field(:disabled => true).should match_tag(:input, :type => "text", :disabled => "disabled")
  end
  
  it "should not be disabled if :disabled => false is passed in" do
    text_field(:disabled => false).should_not match_tag(:input, :type => "text", :disabled => "false")
  end

  it "should not be disabled if :disabled => nil is passed in" do
    text_field(:disabled => false).should_not match_tag(:input, :type => "text", :disabled => "nil")
  end
end

describe "bound_text_field" do
  it_should_behave_like "FakeController"

  it "should take a string object and return a useful text control" do
    f = form_for @obj do
      text_field(:foo).should match_tag(:input, :type => "text", :name => "fake_model[foo]", :value => "foowee")
    end
  end

  it "should take additional attributes and use them" do
    form_for @obj do
      text_field(:foo, :bar => "7").should match_tag(:input, :type => "text", :name => "fake_model[foo]", :value => "foowee", :bar => "7")
    end
  end

  it "should provide an additional label tag if the :label option is passed in" do
    form = form_for @obj do
      _buffer << text_field(:foo, :label => "LABEL")
    end
    form.should match(/<label.*>LABEL<\/label><input/)
    res = form.scan(/<[^>]*>/)
    res[2].should_not match_tag(:input, :label => "LABEL")
  end

  it "should not errorify the field for a new object" do
    f = form_for @obj do
      text_field(:foo, :bar =>"7").should_not match_tag(:input, :type => "text", :name => "fake_model[foo]", :class => "error")
    end
  end

  it "should errorify a field for a model with errors" do
    model = mock("model")
    model.stub!(:new_record?).and_return(true)
    model.stub!(:class).and_return("MyClass")
    model.stub!(:foo).and_return("FOO")
    errors = mock("errors")
    errors.should_receive(:on).with(:foo).and_return(true)

    model.stub!(:errors).and_return(errors)

    f = form_for model do
      text_field(:foo).should match_tag(:input, :class => "error text")
    end
  end
end

describe "bound_radio_button" do
  it_should_behave_like "FakeController"

  it "should take a string object and return a useful text control" do
    f = form_for @obj do
      radio_button(:foo).should match_tag(:input, :type => "radio", :name => "fake_model[foo]", :value => "foowee")
    end
  end

  it "should take additional attributes and use them" do
    form_for @obj do
      radio_button(:foo, :bar => "7").should match_tag(:input, :type => "radio", :name => "fake_model[foo]", :value => "foowee", :bar => "7")
    end
  end

  it "should provide an additional label tag if the :label option is passed in" do
    form = form_for @obj do
      _buffer << radio_button(:foo, :label => "LABEL")
    end
    form.should match(/<input.*><label.*>LABEL<\/label>/)
    res = form.scan(/<[^>]*>/)
    res[2].should_not match_tag(:input, :label => "LABEL")
  end

  it "should not errorify the field for a new object" do
    f = form_for @obj do
      radio_button(:foo, :bar =>"7").should_not match_tag(:input, :type => "radio", :name => "fake_model[foo]", :class => "error")
    end
  end

  it "should errorify a field for a model with errors" do
    model = mock("model")
    model.stub!(:new_record?).and_return(true)
    model.stub!(:class).and_return("MyClass")
    model.stub!(:foo).and_return("FOO")
    errors = mock("errors")
    errors.should_receive(:on).with(:foo).and_return(true)

    model.stub!(:errors).and_return(errors)

    f = form_for model do
      radio_button(:foo).should match_tag(:input, :class => "error radio")
    end
  end
end

describe "password_field" do
  it_should_behave_like "FakeController"

  it "should return a basic password field, but omit the value" do
    password_field(:name => "foo", :value => "bar").should match_tag(:input, :type => "password", :name => "foo")
  end

  it "should provide an additional label tag if the :label option is passed in" do
    result = password_field(:label => "LABEL" )
    result.should match(/<label.*>LABEL<\/label><input type="password" class="password"\s*\/>/)
  end
  
  it "should be disabled if :disabled => true is passed in" do
    password_field(:disabled => true).should match_tag(:input, :type => "password", :disabled => "disabled")
  end
end

describe "bound_password_field" do
  it_should_behave_like "FakeController"

  it "should take a string object and return a useful password control, but omit the value" do
    f = form_for @obj do
      password_field(:foo).should match_tag(:input, :type => "password", :name => "fake_model[foo]")
    end
  end

  it "should take additional attributes and use them" do
    form_for @obj do
      password_field(:foo, :bar => "7").should match_tag(
        :input, :type => "password", :name => "fake_model[foo]", :bar => "7", :value => @obj.foo
      )
    end
  end

  it "should provide an additional label tag if the :label option is passed in" do
    form = form_for @obj do
      _buffer << password_field(:foo, :label => "LABEL")
    end
    form.should match(/<label.*>LABEL<\/label><input/)
    res = form.scan(/<[^>]*>/)
    res[2].should_not match_tag(:input, :label => "LABEL")
  end

  it "should not errorify the field for a new object" do
    f = form_for @obj do
      password_field(:foo, :bar =>"7").should_not match_tag(:input, :class => "error")
    end
  end

  it "should errorify a field for a model with errors" do
    model = mock("model")
    model.stub!(:new_record?).and_return(true)
    model.stub!(:class).and_return("MyClass")
    model.stub!(:foo).and_return("FOO")
    errors = mock("errors")
    errors.should_receive(:on).with(:foo).and_return(true)

    model.stub!(:errors).and_return(errors)

    f = form_for model do
      password_field(:foo).should match_tag(:input, :class => "error password")
    end
  end

end

describe "check_box" do
  it_should_behave_like "FakeController"
  
  it "should return a basic checkbox based on the values passed in" do
    check_box(:name => "foo", :checked => "checked").should match_tag(:input, :class => "checkbox", :name => "foo", :checked => "checked")
  end

  it "should provide an additional label tag if the :label option is passed in" do
    result = check_box(:label => "LABEL" )
    result.should match(/<input.*><label>LABEL<\/label>/)
    res = result.scan(/<[^>]*>/)
    res[0].should_not match_tag(:input, :label => "LABEL")
  end
  
  it 'should remove the checked="checked" attribute if :checked is false or nil' do
    check_box(:name => "foo", :checked => false).should_not include('checked="')
    check_box(:name => "foo", :checked => nil).should_not   include('checked="')
  end
  
  it 'should have the checked="checked" attribute if :checked => true is passed in' do
    check_box(:name => "foo", :checked => true).should include('checked="checked"')
  end

  it "should not be boolean by default" do
    check_box(:name => "foo", :value => "bar").should match_tag(:input, :type => "checkbox", :name => "foo", :value => "bar")
  end

  it "should add a hidden input if boolean" do
    html = check_box(:boolean => true)
    html.should have_tag(:input, :type => "checkbox", :value => "1")
    html.should have_tag(:input, :type => "hidden",   :value => "0")
    html.should match(/<input.*?type="hidden"[^>]*>[^<]*<input.*?type="checkbox"[^>]*>/)
    
  end

  it "should not allow a :value param if boolean" do
    lambda { check_box(:boolean => true, :value => "woot") }.
      should raise_error(ArgumentError, /can't be used with a boolean checkbox/)
    lambda { check_box(:on => "YES", :off => "NO", :value => "woot") }.should raise_error(ArgumentError)
  end

  it "should not allow :boolean => false if :on and :off are specified" do
    lambda { check_box(:boolean => false, :on => "YES", :off => "NO") }.
      should raise_error(ArgumentError, /cannot be used/)
    lambda { check_box(:boolean => true,  :on => "YES", :off => "NO") }.
      should_not raise_error(ArgumentError)
  end

  it "should be boolean if :on and :off are specified" do
    html = check_box(:name => "foo", :on => "YES", :off => "NO")
    html.should have_tag(:input, :type => "checkbox", :value => "YES", :name => "foo")
    html.should have_tag(:input, :type => "hidden",   :value => "NO",  :name => "foo")
  end

  it "should have both :on and :off specified or neither" do
    lambda { check_box(:name => "foo", :on  => "YES") }.should raise_error(ArgumentError, /must be specified/)
    lambda { check_box(:name => "foo", :off => "NO")  }.should raise_error(ArgumentError, /must be specified/)
  end
  
  it "should convert :value to a string on a non-boolean checkbox" do
    check_box(:name => "foo", :value => nil).should match_tag(:input, :value => "")
    check_box(:name => "foo", :value => false).should match_tag(:input, :value => "false")
    check_box(:name => "foo", :value => 0).should match_tag(:input, :value => "0")
    check_box(:name => "foo", :value => "0").should match_tag(:input, :value => "0")
    check_box(:name => "foo", :value => 1).should match_tag(:input, :value => "1")
    check_box(:name => "foo", :value => "1").should match_tag(:input, :value => "1")
    check_box(:name => "foo", :value => true).should match_tag(:input, :value => "true")
  end
  
  it "should be disabled if :disabled => true is passed in" do
    check_box(:disabled => true).should match_tag(:input, :type => "checkbox", :disabled => "disabled")
  end
  
  it "should be possible to call with just check_box" do
    check_box.should match_tag(:input, :type => "checkbox", :class => "checkbox")
  end
end

describe "bound_check_box" do
  it_should_behave_like "FakeController"

  it "should take a string and return a useful checkbox control" do
    form_for @obj do
      check_box(:baz).should match_tag(:input, :type =>"checkbox", :name => "fake_model[baz]", :class => "checkbox", :value => "1", :checked => "checked", :id => "fake_model_baz")
      check_box(:bat).should match_tag(:input, :type =>"checkbox", :name => "fake_model[bat]", :class => "checkbox", :value => "0")
    end
  end

  it "should raise an error if you try to use :value" do
    form_for @obj do
      lambda { check_box(:baz, :value => "Awesome") }.
        should raise_error(ArgumentError, /:value can't be used with a bound_check_box/)
    end
  end

  it "should support models from datamapper" do
    @dm_obj =  FakeDMModel.new
    form_for @dm_obj do
      check_box(:baz).should match_tag(:input,
                                              :type    =>"checkbox",
                                              :name    => "fake_dm_model[baz]",
                                              :class   => "checkbox",
                                              :value   => "1",
                                              :checked => "checked",
                                              :id      => "fake_dm_model_baz")
      check_box(:bat).should match_tag(:input, :type =>"checkbox", :name => "fake_dm_model[bat]", :class => "checkbox", :value => "0")
    end
  end

  it "should allow a user to set the :off value" do
    form_for @obj do
      check_box(:bat, :off => "off", :on => "on").should match_tag(:input, :type =>"checkbox", :name => "fake_model[bat]", :class => "checkbox", :value => "off")
    end
  end

  it "should render controls with errors if their attribute contains an error" do
    form_for @obj do
      check_box(:bazbad).should match_tag(:input, :type =>"checkbox", :name => "fake_model[bazbad]",
        :class => "error checkbox", :value => "1", :checked => "checked")
      check_box(:batbad).should match_tag(:input, :type =>"checkbox", :name => "fake_model[batbad]",
        :class => "error checkbox", :value => "0")
    end
  end

  it "should provide an additional label tag if the :label option is passed in" do
    form = form_for @obj do
      _buffer << check_box(:foo, :label => "LABEL")
    end
    form.should match( /<input.*><label.*>LABEL<\/label>/ )
    res = form.scan(/<[^>]*>/)
    res[0].should_not match_tag(:input, :label => "LABEL")
  end

  it "should not errorify the field for a new object" do
    f = form_for @obj do
      check_box(:foo, :bar =>"7").should_not match_tag(:input, :type => "checkbox", :class => "error checkbox")
    end
  end

  it "should errorify a field for a model with errors" do
    model = mock("model")
    model.stub!(:new_record?).and_return(true)
    model.stub!(:class).and_return("MyClass")
    model.stub!(:foo).and_return("FOO")
    errors = mock("errors")
    errors.should_receive(:on).with(:foo).and_return(true)

    model.stub!(:errors).and_return(errors)

    f = form_for model do
      check_box(:foo, :bar =>"7").should match_tag(:input, :type => "checkbox", :class => "error checkbox")
    end
  end
  
  it "should be boolean" do
    form_for @obj do
      html = check_box(:baz)
      html.should have_tag(:input, :type => "checkbox", :value => "1")
      html.should have_tag(:input, :type => "hidden",   :value => "0")
    end
  end
  
  it "should be checked if the value of the model's attribute is equal to the value of :on" do
    form_for @obj do
      check_box(:foo, :on => "foowee", :off => "NO").should match_tag(:input, :type =>"checkbox", :value => "foowee", :checked => "checked")
      check_box(:foo, :on => "YES",    :off => "NO", :true_if => "zoo").should_not include('checked="')
    end
  end
end

describe "hidden_field" do
  it_should_behave_like "FakeController"
  
  it "should return a basic checkbox based on the values passed in" do
    hidden_field(:name => "foo", :value => "bar").should match_tag(:input, :type => "hidden", :name => "foo", :value => "bar")
  end

  it "should not render a label if the :label option is passed in" do
    res = hidden_field(:label => "LABEL")
    res.should_not match(/<label>LABEL/)
    res.should_not match_tag(:input, :label=> "LABEL")
  end
  
  it "should be disabled if :disabled => true is passed in" do
    hidden_field(:disabled => true).should match_tag(:input, :type => "hidden", :disabled => "disabled")
  end
end

describe "bound_hidden_field" do
  it_should_behave_like "FakeController"

  it "should take a string and return a useful checkbox control" do
    form_for @obj do
      hidden_field(:foo).should match_tag(:input, :type =>"hidden", :name => "fake_model[foo]", :value => "foowee")
    end
  end

  it "should render controls with errors if their attribute contains an error" do
    form_for @obj do
      hidden_field(:foobad).should match_tag(:input, :type =>"hidden", :name => "fake_model[foobad]", :value => "foowee", :class => "error hidden")
    end
  end

  it "should not render a label if the :label option is passed in" do
    form_for @obj do
      res = hidden_field(:foo, :label => "LABEL")
      res.should_not match(/<label>LABEL/)
      res.should_not match_tag(:input, :label=> "LABEL")
    end
  end

  it "should not errorify the field for a new object" do
    f = form_for @obj do
      hidden_field(:foo, :bar =>"7").should_not match_tag(:input, :type => "hidden", :class => "error")
    end
  end

  it "should not errorify a field for a model with errors" do
    model = mock("model")
    model.stub!(:new_record?).and_return(true)
    model.stub!(:class).and_return("MyClass")
    model.stub!(:foo).and_return("FOO")
    errors = mock("errors")
    errors.should_receive(:on).with(:foo).and_return(true)

    model.stub!(:errors).and_return(errors)

    f = form_for model do
      hidden_field(:foo, :bar =>"7").should match_tag(:input, :type => "hidden", :name => "my_class[foo]", :class => "error hidden")
    end
  end

end

describe "radio_button" do
  it_should_behave_like "FakeController"
  
  it "should should return a basic radio button based on the values passed in" do
    radio_button(:name => "foo", :value => "bar", :id => "baz").should match_tag(:input, :type => "radio", :name => "foo", :value => "bar", :id => "baz")
  end

  it "should provide an additional label tag if the :label option is passed in" do
    result = radio_button(:name => "foo", :value => "bar", :label => "LABEL")
    # result.should match(/<label.*>LABEL<\/label><input/)
    # res = result.scan(/<[^>]*>/)
    # res[2].should_not match_tag(:input, :label => "LABEL")
    result.should match(/<input.*><label.*>LABEL<\/label>/)
    res = result.scan(/<[^>]*>/)
    res[0].should_not match_tag(:input, :label => "LABEL")
  end

  it "should be disabled if :disabled => true is passed in" do
    radio_button(:disabled => true).should match_tag(:input, :type => "radio", :disabled => "disabled")
  end
end

describe "bound_radio_group" do
  it_should_behave_like "FakeController"

  it "should return a group of radio buttons" do
    form_for @obj do
      radio = radio_group(:foo, ["foowee", "baree"]).scan(/<[^>]*>/)
      radio[0].should match_tag(:input, :type => "radio", :name => "fake_model[foo]", :value => "foowee", :checked => "checked")
      radio[3].should match_tag(:input, :type => "radio", :name => "fake_model[foo]", :value => "baree")
      radio[4].should not_match_tag(:checked => "checked")
    end
  end

  it "should provide an additional label tag for each option in array-based options" do
    form_for :obj do
      radio = radio_group(:foo, ["foowee", "baree"])
      radio.scan( /<input.*?><label.*?>(foowee|baree)<\/label>/ ).size.should == 2
      radio = radio.scan(/<[^>]*>/)
      radio[0].should_not match_tag(:input, :label => "LABEL")
      radio[3].should_not match_tag(:input, :label => "LABEL")
    end
  end

  it "should accept array of hashes as options" do
    form_for @obj do
      radio = radio_group(:foo, [{:value => 5, :label => "Five"}, {:value => 'bar', :label => 'Bar', :id => 'bar_id'}])
      radio.scan( /<input.*?><label.*?>(Five|Bar)<\/label>/ ).size.should == 2
      radio = radio.scan(/<[^>]*>/)
      radio.size.should == 6
      radio[0].should match_tag(:input, :value => 5)
      radio[1].should match_tag(:label)
      radio[2].should match_tag('/label')
      radio[3].should match_tag(:input, :value => 'bar', :id => 'bar_id')
      radio[4].should match_tag(:label, :for => 'bar_id')
      radio[5].should match_tag('/label')
    end
  end

  it "should provide autogenerated id for inputs" do
    form_for @obj do
      [ radio_group(:foo, [:bar]), radio_group(:foo, [{:value => 'bar', :label => 'Bar'}]) ].each do |radio|
        radio = radio.scan(/<[^>]*>/)
        radio[0].should match_tag(:input, :id => 'fake_model_foo_bar')
        radio[1].should match_tag(:label, :for => 'fake_model_foo_bar')
      end
    end
  end

  it "should override autogenerated id for inputs with hash-given id" do
    form_for @obj do
      radio = radio_group(:foo, [{:value => 'bar', :label => 'Bar', :id => 'bar_id'}]).scan(/<[^>]*>/)
      radio[0].should match_tag(:input, :id => 'bar_id')
      radio[1].should match_tag(:label, :for => 'bar_id')
    end
  end
end

describe "text_area" do
  it_should_behave_like "FakeController"
  
  it "should should return a basic text area based on the values passed in" do
    text_area("foo", :name => "foo").should match_tag(:textarea, :name => "foo")
  end

  it "should handle a nil content" do
    text_area(nil, :name => "foo").should == "<textarea name=\"foo\"></textarea>"
  end


  # TODO: Why is this required?
  # ---------------------------
  # 
  # it "should handle a nil attributes hash" do
  #   text_area("CONTENT", nil).should == "<textarea>CONTENT</textarea>"
  # end

  it "should render a label when the label is passed in" do
    result = text_area( "CONTENT", :name => "foo", :value => "bar", :label => "LABEL")
    result.should match(/<label.*>LABEL<\/label><textarea/)
    res = result.scan(/<[^>]*>/)
    res[1].should_not match_tag(:textarea, :label => "LABEL")
  end
  
  it "should be disabled if :disabled => true is passed in" do
    text_area("Woop Woop Woop!", :disabled => true).should match_tag(:textarea, :disabled => "disabled")
  end
end

describe "bound_text_area" do
  it_should_behave_like "FakeController"

  it "should provide :id attribute" do
    form_for @obj do
      ret = text_area( :foo )
      ret.should match_tag(:textarea, :id => 'fake_model_foo', :name => "fake_model[foo]")
      ret.should =~ />\s*#{@obj.foo}\s*</
    end
  end
end

describe "unbound_select" do
  it_should_behave_like "FakeController"
  
  it "should provide a blank option if you :include_blank" do
    content = select(:include_blank => true)
    content.should =~ /<option.*>\s*<\/option>/
  end
end

describe "bound_select" do

  it_should_behave_like "FakeController"

  it "should render the select tag with the correct id and name" do
    form_for @obj do
      content = select( :foo )
      content.should match_tag( :select, :id => "fake_model_foo", :name => "fake_model[foo]" )
    end
  end

  it "should include a blank option" do
    form_for @obj do
      content = select( :foo, :include_blank => true )
      content.should match_tag(:option, :value => '')
      content.should =~ /<option.*>\s*<\/option>/
    end
  end

  it "should render a prompt option without a value" do
    form_for @obj do
      content = select( :foo, :prompt => "Choose" )
    end
  end

  it "should render a select tag with options" do
    form_for @obj do
      content = select( :foo, :class => 'class1 class2', :title => 'This is the title' )
      content.should match_tag( :select, :class => "class1 class2", :title=> "This is the title" )
      content.should =~ /<select.*>\s*<\/select>/
    end
  end

  it "should render a select tag with options and a blank option" do
    form_for @obj do
      content = select( :foo, :title => "TITLE", :include_blank => true )
      content.should match_tag( :select, :title => "TITLE" )
      content.should match_tag( :option, :value => '' )
      content.should =~ /<option.*>\s*<\/option>/
    end
  end

  # Not sure how this makes any sense
  # ---------------------------------
  #
  # it "should render the text as the value if no text_method is specified" do
  #   form_for @obj do
  #     content = select( :foo, :collection => [FakeModel] )
  #     content.should match_tag( :option, :value => "FakeModel" )
  #   end
  # end

end

describe "option tag generation (data bound)" do
  it_should_behave_like "FakeController"

  it "should use text_method and value_method for tag generation" do
    form_for @obj do
      content = select( :foo, :collection => [FakeModel.new, FakeModel2.new],
        :text_method => "foo", :value_method => "bar" )
      content.should match_tag( :option, :content => "foowee", :value => "7" )
      content.should match_tag( :option, :content => "foowee2", :value => "barbar" )
    end
    
    # content = options_from_collection_for_select( [FakeModel.new, FakeModel2.new], :text_method => 'foo', :value_method => 'bar' )
    # content.should match_tag( :option, :content => "foowee", :value => "7" )
    # content.should match_tag( :option, :content => "foowee2", :value => "barbar" )
  end

  it "should render a hash of arrays as a grouped select box" do
    @model1 = FakeModel.new ; @model1.make = "Ford"   ; @model1.model = "Mustang"   ; @model1.vin = '1'
    @model2 = FakeModel.new ; @model2.make = "Ford"   ; @model2.model = "Falcon"    ; @model2.vin = '2'
    @model3 = FakeModel.new ; @model3.make = "Holden" ; @model3.model = "Commodore" ; @model3.vin = '3'

    form_for @model1 do
      collection = [@model1, @model2, @model3].inject({}) {|s,e| (s[e.make] ||= []) << e; s }
      content = select(:vin, :text_method => "model",
        :collection => collection)
      
      # Blank actually defaults to ""
      content.should =~ /<optgroup label=\"Ford\"><option/
      
      content.should match_tag( :optgroup, :label => "Ford" )
      content.should match_tag( :option, :selected => "selected", :value => "1", :content => "Mustang" )
      content.should match_tag( :option, :value => "2", :content => "Falcon" )
      content.should match_tag( :optgroup, :label => "Holden" )
      content.should match_tag( :option, :value => "3", :content => "Commodore" )      
    end

    # collection = [@model1, @model2, @model3].inject({}) {|s,e| (s[e.make] ||= []) << e; s }
    # content = options_from_collection_for_select(collection, :text_method => 'model', :value_method => 'vin', :selected => '1')
  end

  it "should render a collection of nested value/content arrays" do
    form_for @obj do
      content = select(:foo, :collection => [["small", "Small"], ["medium", "Medium"], ["large", "Large"]])
      content.should match_tag(:select, :id => "fake_model_foo", :name => "fake_model[foo]")
      content.should match_tag(:option, :value => "small",  :content => "Small")
      content.should match_tag(:option, :value => "medium", :content => "Medium")
      content.should match_tag(:option, :value => "large",  :content => "Large")
    end
  end

  # Is this really worth the extra speed hit? I'm thinking not
  # ----------------------------------------------------------
  #
  # it "should humanize and titlize keys in the label for the option group" do
  #   collection = { :some_snake_case_key => [FakeModel.new] }
  #   form_for @obj do
  #     content = select( :foo, :collection => collection )
  #     content.should match_tag( :optgroup, :label => "Some Snake Case Key" )
  #   end
  # end


end

require "hpricot"

describe "option tags generation (basic)" do
  it_should_behave_like "FakeController"

  before do
    @collection = [['rabbit','Rabbit'],['horse','Horse'],['bird','Bird']]
  end

  it "should provide an option tag for each item in the collection" do
    result = select(:collection => @collection)
    doc = Hpricot( result )
    (doc/"option").size.should == 3
  end

  it "should provide a blank option" do
    content = select(:collection => @collection, :include_blank => true )
    content.should match_tag( :option, :value => '' )
  end

  it "should provide a prompt option" do
    content = select( :collection => [], :prompt => 'Choose' )
    content.should match_tag( :option, :value => '', :content => 'Choose' )
  end

  it "should render the prompt option at the top" do
    content = select( :collection => [["foo", "Foo"]], :prompt => 'Choose' )
    content.should match(/<option[^>]*>Choose<\/option>[^<]*<option[^>]*>Foo<\/option>/)
  end

  it "should provide selected options by value" do
    content = select( :collection => [['rabbit','Rabbit'],['chicken','Chicken']], 
      :selected => 'rabbit' )
    content.should match_tag( :option, :value => 'rabbit', :selected => 'selected', :content => 'Rabbit' )
    content.should_not match_tag( :option, :value => 'chicken', :selected => nil, :content => 'Chicken' )
  end

  it "should render a hash of options as optgroup" do
    collection = { "Fruit" => [['orange','Orange'],['banana','Banana']], "Vegetables" => [['corn','Corn']]}
    content = select(:collection => collection, :selected => 'banana')
    content.should match_tag( :optgroup, :label => 'Fruit' )
    content.should match_tag( :optgroup, :label => 'Vegetables' )
    content.should match_tag( :option, :value => 'banana', :selected => 'selected', :content => 'Banana' )
  end

  it "should accept an array of strings in :collection as the content/value of each option" do
    content = select(:collection => %w(one two three))
    content.should match_tag(:option, :content => "one", :value => "one")
    content.should match_tag(:option, :content => "two", :value => "two")
  end

  it "should only pass :selected and :value attrs to <option> tags" do
    content = select(:collection => [["rabbit", "Rabbit"]], :id => "my_id", :name => "my_name", :class => "classy")
    content = content.slice(/<option[^>]*>[^<]*<\/option>/)
    content.should match_tag(:option, :value => "rabbit", :content => "Rabbit")
    content.should_not match_tag(:option, :id => "my_id", :name => "my_name", :class => "classy")
  end

  it "should not pollute the <select> attributes with <option> attributes" do
    content = select(:collection => [['orange','Orange'], ['banana','Banana']], :selected => 'banana')
    content = content.slice(/<select[^>]*>/)
    content.should_not match_tag(:select, :value => "banana", :selected => "selected")
  end
end

describe "fieldset" do
  it_should_behave_like "FakeController"

  it "should provide legend option" do
    res = fieldset :legend => 'TEST' do
      _buffer << "CONTENT"
    end
    res.should include("CONTENT")
    res.should match_tag(:fieldset, {})
    res.should match_tag(:legend, :content => 'TEST')
  end
end

describe "file_field" do
  it_should_behave_like "FakeController"

  it "should return a basic file field based on the values passed in" do
    file_field(:name => "foo", :value => "bar").should match_tag( :input, :type => "file", :name => "foo", :value => "bar")
  end

  it "should wrap the field in a label if the :label option is passed to the file" do
    result = file_field(:label => "LABEL" )
    result.should match(/<label>LABEL<\/label><input type="file" class="file"\s*\/>/)
  end
  
  it "should be disabled if :disabled => true is passed in" do
    file_field(:disabled => true).should match_tag(:input, :type => "file", :disabled => "disabled")
  end
  
  it "should make the surrounding form multipart" do
    ret = form_for @obj do
      file_field(:baz)
    end
    ret.should match_tag(:form, :enctype => "multipart/form-data")
  end
end

describe "bound_file_field" do
  it_should_behave_like "FakeController"

  it "should take a string object and return a useful file control" do
    f = form_for @obj do
      file_field(:foo).should match_tag(:input, :type => "file", :name => "fake_model[foo]", :value => "foowee")
    end
  end

  it "should take additional attributes and use them" do
    form_for @obj do
      file_field(:foo, :bar => "7").should match_tag(:input, :type => "file", :name => "fake_model[foo]", :value => "foowee", :bar => "7")
    end
  end

  it "should wrap the file_field in a label if the :label option is passed in" do
    form = form_for @obj do
      _buffer << text_field(:foo, :label => "LABEL")
    end
    form.should match(/<label.*>LABEL<\/label><input/)
    res = form.scan(/<[^>]*>/)
    res[2].should_not match_tag(:input, :label => "LABEL")
  end
end

describe "submit" do
  it_should_behave_like "FakeController"  
  
  it "should return a basic submit input based on the values passed in" do
    submit("Done", :name => "foo").should match_tag(:input, :type => "submit", :name => "foo", :value => "Done")
  end

  it "should provide an additional label tag if the :label option is passed in" do
    result = submit("Done", :label => "LABEL")
    result.should match(/<input.*type="submit"/)
    result.should match(/<input.*name="submit"/)
    result.should match(/<input.*value="Done"/)
    result.should match(/<label.*>LABEL<\/label>/)
  end
  
  it "should be disabled if :disabled => true is passed in" do
    submit("Done", :disabled => true).should match_tag(:input, :type => "submit", :value => "Done", :disabled => "disabled")
  end  
end

describe "button" do
  it_should_behave_like "FakeController"  
  
  it "should return a button based on the values passed in" do
    button("Click Me", :type => "button", :name => "foo", :value => "bar").
      should match_tag(:button, :type => "button", :name => "foo", :value => "bar", :content => "Click Me")
  end

  it "should provide an additional label tag if the :label option is passed in" do
    result = button("Click Me", :value => "foo", :label => "LABEL")
    result.should match(/<button.*value="foo"/)
    result.should match(/<label.*>LABEL<\/label>/)
  end

  it "should be disabled if :disabled => true is passed in" do
    button("Done", :disabled => true).should match_tag(:button, :disabled => "disabled")
  end
end

class MyBuilder < Merb::Helpers::Form::Builder::Base
  
  def update_bound_controls(method, attrs, type)
    super
    attrs[:bound] = type
  end

  def update_unbound_controls(attrs, type)
    super
    attrs[:unbound] = type
  end
  
end

describe "your own builder" do
  it_should_behave_like "FakeController"
  
  it "should let you override update_bound_controls" do
    form_for @obj, :builder => MyBuilder do
      file_field(:foo).should =~ / bound="file"/
      text_field(:foo).should =~ / bound="text"/
      hidden_field(:foo).should =~ / bound="hidden"/
      password_field(:foo).should =~ / bound="password"/
      radio_button(:foo).should =~ / bound="radio"/
      text_area(:foo).should =~ / bound="text_area"/
    end
  end
  
  it "should let you override update_unbound_controls" do
    form_for @obj, :builder => MyBuilder do
      button("Click").should match_tag(:button, :unbound => "button")
      submit("Awesome").should match_tag(:input, :unbound => "submit")
      text_area(:foo).should match_tag(:textarea, :unbound => "text_area")
    end
  end
end

# describe 'delete_button' do
#   before :each do
#     @obj = mock 'a model'
#     @obj.stub!(:object_id).and_return("1")
#     
#     Merb::Router.prepare do |r|
#       r.resources :objs
#       r.resources :foos
#     end
#     def url(sym, obj)
#       "/objs/#{obj.object_id}"
#     end
#   end
# 
#   it 'should return a button inside of a form for the object' do
#     result = delete_button(:obj, @obj)
#     result.should match_tag(:form, :action => "/objs/#{@obj.object_id}", :method => "post")
#     result.should match_tag(:input, :type => "hidden", :value => "delete", :name => "_method")
#     result.should match_tag(:button, :type => "submit")
#     result.should match(/<button.*>Delete<\/button>/)
#   end
# 
#   it 'should allow you to modify the label' do
#     delete_button(:obj, @obj, 'Remove').should match(/<button.*>Remove<\/button>/)
#   end
# 
#   it 'should allow you to omit the ivar reference if its name is the same as the attribute' do
#     delete_button(:obj).should == delete_button(:obj, @obj)
#   end
#   
#   it "should allow you to use a local variable as is common in a .each loop" do
#     foo = @obj
#     delete_button(:foo, foo).should == delete_button(:obj)
#   end
#   
#   it 'should allow you to modify the action so you can use routes with multiple params' do
#     result = delete_button('/objs/2/subobjs/1')
#     result.should match_tag(:form, :action => "/objs/2/subobjs/1", :method => "post")
#   end
# end
# 
# describe "control_value" do
#   it_should_behave_like "FakeController"
# 
#   it 'should escape [&"<>]' do
#     @obj.vin = '&"<>'
#     f = form_for :obj do
#       control_value(:vin).should == '&amp;&quot;&lt;&gt;'
#     end
#   end
# end
