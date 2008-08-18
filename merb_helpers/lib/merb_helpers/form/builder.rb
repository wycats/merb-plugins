load File.dirname(__FILE__) / ".." / "tag_helpers.rb"

module Merb::Helpers::Form::Builder

  class Base
    include Merb::Helpers::Tag

    def initialize(obj, name, origin)
      @obj, @origin = obj, origin
      @name = name || @obj.class.name.snake_case.split("/").last
    end

    def concat(attrs, &blk)
      @origin.concat(@origin.capture(&blk), blk.binding)
    end

    # Provides the ability to create quick fieldsets as blocks for your forms.
    #
    # Note: Block helpers use the <%= =%> syntax
    #
    # ==== Parameters
    # attrs<Hash>:: HTML attributes and options
    #
    # ==== Options
    # +legend+:: Adds a legend tag within the fieldset
    #
    # ==== Returns
    # String:: HTML
    #
    # ==== Example
    #   <%= fieldset :legend => "Customer Options" do %>
    #     ...your form elements
    #   <% end =%>
    #
    #   Generates the HTML:
    #
    #   <fieldset>
    #     <legend>Customer Options</legend>
    #     ...your form elements
    #   </fieldset>
    def fieldset(attrs, &blk)
      legend = (l_attr = attrs.delete(:legend)) ? tag(:legend, l_attr) : ""
      tag(:fieldset, legend + @origin.capture(&blk), attrs)
      # @origin.concat(contents, blk.binding)
    end

    # Generates a form tag, which accepts a block that is not directly based on resource attributes
    #
    # Notes:
    #  * Block helpers use the <%= =%> syntax
    #  * a multipart enctype is automatically set if the form contains a file upload field
    #
    # ==== Parameters
    # attrs<Hash>:: HTML attributes
    #
    # ==== Returns
    # String:: HTML
    #
    # ==== Example
    #   <%= form :action => url(:controller => "foo", :action => "bar", :id => 1) do %>
    #     <%= text_field :name => "first_name", :label => "First Name" %>
    #     <%= submit_button "Create" %>
    #   <% end =%>
    #
    #   Generates the HTML:
    #
    #   <form action="/foo/bar/1" method="post">
    #     <label for="first_name">First Name</label><input id="first_name" name="first_name" size="30" type="text" />
    #     <input name="commit" type="submit" value="Create" />
    #   </form>
    def form(attrs = {}, &blk)
      captured = @origin.capture(&blk)
      fake_method_tag = process_form_attrs(attrs)

      tag(:form, fake_method_tag + captured, attrs)
      # @origin.concat(contents, blk.binding)
    end

    def process_form_attrs(attrs)
      method = attrs[:method]

      # Unless the method is :get, fake out the method using :post
      attrs[:method] = :post unless attrs[:method] == :get
      # Use a fake PUT if the object is not new, otherwise use the method
      # passed in.
      method ||= (@obj && !@obj.new_record? ? :put : :post)

      attrs[:enctype] = "multipart/form-data" if attrs.delete(:multipart) || @multipart

      method == :post || method == :get ? "" : fake_out_method(attrs, method)
    end

    # This can be overridden to use another method to fake out methods
    def fake_out_method(attrs, method)
      self_closing_tag(:input, :type => "hidden", :name => "_method", :value => method)
    end

    def add_css_class(attrs, new_class)
      attrs[:class] = (attrs[:class].to_s.split(" ") + [new_class]).join(" ")
    end

    def update_control_fields(method, attrs, type)
      case type
      when "checkbox"
        update_checkbox_control_field(method, attrs)
      when "select"
        update_select_control_field(method, attrs)
      end
    end

    def update_fields(attrs, type)
      case type
      when "checkbox"
        update_checkbox_field(attrs)
      when "file"
        @multipart = true
      end

      attrs[:disabled] ? attrs[:disabled] = "disabled" : attrs.delete(:disabled)
    end

    def update_select_control_field(method, attrs)
      attrs[:value_method] ||= method
      attrs[:text_method] ||= attrs[:value_method] || :to_s
      attrs[:selected] ||= @obj.send(attrs[:value_method])
    end

    def update_checkbox_control_field(method, attrs)
      raise ArgumentError, ":value can't be used with a checkbox_control" if attrs.has_key?(:value)

      attrs[:boolean] ||= true

      val = @obj.send(method)
      attrs[:checked] = attrs.key?(:on) ? val == attrs[:on] : considered_true?(val)
    end

    def update_checkbox_field(attrs)
      boolean = attrs[:boolean] || (attrs[:on] && attrs[:off]) ? true : false

      case
      when attrs.key?(:on) ^ attrs.key?(:off)
        raise ArgumentError, ":on and :off must be specified together"
      when (attrs[:boolean] == false) && (attrs.key?(:on) || attrs.key?(:off))
        raise ArgumentError, ":boolean => false cannot be used with :on and :off"
      when boolean && attrs.key?(:value)
        raise ArgumentError, ":value can't be used with a boolean checkbox"
      end

      if attrs[:boolean] = boolean
        attrs[:on] ||= "1"; attrs[:off] ||= "0"
      end

      if attrs[:checked] || (attrs[:on] && attrs[:on] == attrs[:value])
        attrs[:checked] = "checked"
      else
        attrs.delete(:checked)
      end
    end

    def checkbox_control(method, attrs = {})
      name = control_name(method)
      update_control_fields(method, attrs, "checkbox")
      checkbox_field({:name => name}.merge(attrs))
    end

    def checkbox_field(attrs = {})
      update_fields(attrs, "checkbox")
      if attrs.delete(:boolean)
        on, off = attrs.delete(:on), attrs.delete(:off)
        hidden_field(:name => attrs[:name], :value => off) <<
          self_closing_tag(:input, {:type => "checkbox", :value => on}.merge(attrs))
      else
        self_closing_tag(:input, {:type => "checkbox"}.merge(attrs))
      end
    end

    %w(text radio password hidden file).each do |kind|
      self.class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def #{kind}_control(method, attrs = {})
          name = control_name(method)
          update_control_fields(method, attrs, "#{kind}")
          #{kind}_field({:name => name, :value => @obj.send(method)}.merge(attrs))
        end

        def #{kind}_field(attrs = {})
          update_fields(attrs, "#{kind}")
          self_closing_tag(:input, {:type => "#{kind}"}.merge(attrs))
        end
      RUBY
    end

    # Generates a HTML button.
    #
    # Notes:
    #  * Buttons do not always work as planned in IE
    #    http://www.peterbe.com/plog/button-tag-in-IE
    #  * Not all mobile browsers support buttons
    #    http://nickcowie.com/2007/time-to-stop-using-the-button-element/
    #
    # ==== Parameters
    # contents<String>:: HTML contained within the button tag
    # attrs<Hash>:: HTML attributes
    #
    # ==== Returns
    # String:: HTML
    #
    # ==== Example
    #   <%= button "Initiate Launch Sequence" %>
    def button(contents, attrs)
      update_fields(attrs, "button")
      tag(:button, contents, attrs)
    end

    # Generates a HTML submit button.
    #
    # ==== Parameters
    # value<String>:: Sets the value="" attribute
    # attrs<Hash>:: HTML attributes
    #
    # ==== Returns
    # String:: HTML
    #
    # ==== Example
    #   <%= submit "Process" %>
    def submit(value, attrs)
      attrs[:type]  ||= "submit"
      attrs[:name]  ||= "submit"
      attrs[:value] ||= value
      update_fields(attrs, "submit")
      self_closing_tag(:input, {:type => "submit"}.merge(attrs))
    end

    # Provides a HTML select based on a resource attribute.
    # This is generally used within a resource block such as +form_for+.
    #
    # ==== Parameters
    # method<Symbol>:: Resource attribute
    # attrs<Hash>:: HTML attributes and options
    #
    # ==== Options
    # +collection+:: An array of items to choose from
    #
    # ==== Returns
    # String:: HTML
    #
    # ==== Example
    #   <%= select_control :name, :collection => %w(one two three four) %>
    def select_control(method, attrs = {})
      name = control_name(method)
      update_control_fields(method, attrs, "select")
      select_field({:name => name}.merge(attrs))
    end

    # Provides a generic HTML select.
    #
    # ==== Parameters
    # attrs<Hash>:: HTML attributes and options
    #
    # ==== Options
    # +prompt+:: Adds an additional option tag with the provided string with no value.
    # +selected+:: The value of a selected object, which may be either a string or an array.
    # +include_blank+:: Adds an additional blank option tag with no value.
    # +collection+:: The collection for the select options
    # +text_method+:: Method to determine text of an option (as a symbol). Ex: :text_method => :name  will call .name on your record object for what text to display.
    # +value_method+:: Method to determine value of an option (as a symbol).
    #
    # ==== Returns
    # String:: HTML
    def select_field(attrs = {})
      update_fields(attrs, "select")
      tag(:select, options_for(attrs), attrs)
    end

    # Provides a radio group based on a resource attribute.
    # This is generally used within a resource block such as +form_for+.
    #
    # ==== Parameters
    # method<Symbol>:: Resource attribute
    # arr<Array>:: Choices
    #
    # ==== Returns
    # String:: HTML
    #
    # ==== Examples
    #   <%# the labels are the options %>
    #   <%= radio_group_control :my_choice, [5,6,7] %>
    #
    #   <%# custom labels %>
    #   <%= radio_group_control :my_choice, [{:value => 5, :label => "five"}] %>
    def radio_group_control(method, arr)
      val = @obj.send(method)
      arr.map do |attrs|
        attrs = {:value => attrs} unless attrs.is_a?(Hash)
        attrs[:checked] ||= (val == attrs[:value])
        radio_group_item(method, attrs)
      end.join
    end

    # Provides a generic HTML textarea tag.
    #
    # ==== Parameters
    # contents<String>:: Contents of the text area
    # attrs<Hash>:: HTML attributes
    #
    # ==== Returns
    # String:: HTML
    #
    # ==== Example
    #   <%= text_area_field "my comments", :name => "comments" %>
    def text_area_field(contents, attrs = {})
      update_fields(attrs, "text_area")
      tag(:textarea, contents, attrs)
    end

    # Provides a HTML textarea based on a resource attribute
    # This is generally used within a resource block such as +form_for+
    #
    # ==== Parameters
    # method<Symbol>:: Resource attribute
    # attrs<Hash>:: HTML attributes
    #
    # ==== Returns
    # String:: HTML
    #
    # ==== Example
    #   <%= text_area_control :comments %>
    def text_area_control(method, attrs = {})
      name = "#{@name}[#{method}]"
      update_control_fields(method, attrs, "text_area")
      text_area_field(@obj.send(method), {:name => name}.merge(attrs))
    end

    private

    def control_name(method)
      "#{@name}[#{method}]"
    end

    # Accepts a collection (hash, array, enumerable, your type) and returns a string of option tags. 
    # Given a collection where the elements respond to first and last (such as a two-element array), 
    # the "lasts" serve as option values and the "firsts" as option text. Hashes are turned into
    # this form automatically, so the keys become "firsts" and values become lasts. If selected is
    # specified, the matching "last" or element will get the selected option-tag. Selected may also
    # be an array of values to be selected when using a multiple select.
    #
    # ==== Parameters
    # attrs<Hash>:: HTML attributes and options
    #
    # ==== Options
    # +selected+:: The value of a selected object, which may be either a string or an array.
    # +prompt+:: Adds an addtional option tag with the provided string with no value.
    # +include_blank+:: Adds an additional blank option tag with no value.
    #
    # ==== Returns
    # String:: HTML
    #
    # ==== Examples
    #   <%= options_for_select [["apple", "Apple Pie"], ["orange", "Orange Juice"]], :selected => "orange"
    #   => <option value="apple">Apple Pie</option><option value="orange" selected="selected">Orange Juice</option>
    #
    #   <%= options_for_select [["apple", "Apple Pie"], ["orange", "Orange Juice"]], :selected => ["orange", "apple"], :prompt => "Select One"
    #   => <option value="">Select One</option><option value="apple" selected="selected">Apple Pie</option><option value="orange" selected="selected">Orange Juice</option>
    def options_for(attrs)
      if attrs.delete(:include_blank)
        b = tag(:option, "", :value => "")
      elsif prompt = attrs.delete(:prompt)
        b = tag(:option, prompt, :value => "")
      else
        b = ""
      end

      # yank out the options attrs
      collection = attrs.delete(:collection) || []
      selected = attrs.delete(:selected)
      text_method = @obj ? attrs.delete(:text_method) : :last
      value_method = @obj ? attrs.delete(:value_method) : :first

      # if the collection is a Hash, optgroups are a-coming
      if collection.is_a?(Hash)
        options = collection.map do |g,col|
          tag(:optgroup, options(col, text_method, value_method, attrs, selected, ""), :label => g)
        end + [b]
        options.join
      else
        options(collection, text_method, value_method, attrs, selected, b)
      end
    end

    def options(col, text_meth, value_meth, attrs, sel, b)
      options = col.map do |item|
        value = item.send(value_meth)
        attrs.merge!(:value => value)
        attrs.merge!(:selected => "selected") if value == sel
        tag(:option, item.send(text_meth), attrs)
      end + [b]
      options.join
    end

    def radio_group_item(method, attrs)
      attrs.merge!(:checked => "checked") if attrs[:checked]
      radio_control(method, attrs)
    end

    def considered_true?(value)
      value && value != "0" && value != 0
    end
  end

  class Form < Base
    def update_control_fields(method, attrs, type)
      attrs.merge!(:id => "#{@name}_#{method}") unless attrs[:id]
      super
    end

    def update_fields(attrs, type)
      case type
      when "text", "radio", "password", "hidden", "checkbox", "file"
        add_css_class(attrs, type)
      end
      super
    end

    # Provides a generic HTML label.
    #
    # ==== Parameters
    # attrs<Hash>:: HTML attributes
    #
    # ==== Returns
    # String:: HTML
    #
    # ==== Example
    #   <%= label :for => "name", :label => "Full Name" %> 
    #   => <label for="name">Full Name</label>
    def label(attrs)
      attrs ||= {}
      for_attr = attrs[:id] ? {:for => attrs[:id]} : {}
      if label_text = attrs.delete(:label)
        tag(:label, label_text, for_attr)
      else
        ""
      end
    end

    %w(text password file).each do |kind|
      self.class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def #{kind}_field(attrs = {})
          label(attrs) + super
        end
      RUBY
    end

    def button(contents, attrs = {})
      label(attrs) + super
    end

    def submit(value, attrs = {})
      label(attrs) + super
    end

    def text_area_field(contents, attrs = {})
      label(attrs) + super
    end

    def checkbox_field(attrs = {})
      label_text = label(attrs)
      super + label_text
    end

    def radio_field(attrs = {})
      label_text = label(attrs)
      super + label_text
    end

    def radio_group_item(method, attrs)
      unless attrs[:id]
        attrs.merge!(:id => "#{@name}_#{method}_#{attrs[:value]}")
      end

      attrs.merge!(:label => attrs[:label] || attrs[:value])
      super
    end

    # Provides a generic HTML hidden input field.
    #
    # ==== Parameters
    # attrs<Hash>:: HTML attributes
    #
    # ==== Returns
    # String:: HTML
    #
    # ==== Example
    #   <%= hidden_field :name => "secret", :value => "some secret value" %>
    def hidden_field(attrs = {})
      attrs.delete(:label)
      super
    end
  end

  module Errorifier
    def update_control_fields(method, attrs, type)
      if @obj.errors.on(method.to_sym)
        add_css_class(attrs, "error")
      end
      super
    end

    # Provides a HTML formatted display of resource errors in an unordered list with a h2 form submission error
    #
    # ==== Parameters
    # obj<Symbol>:: Model or Resource
    # error_class<String>:: CSS class to use for error container
    # build_li<String>:: Custom li tag to wrap each error in
    # header<String>:: Custom header text for the error container
    # before<Boolean>:: Display the errors before or inside of the form
    #
    # ==== Returns
    # String:: HTML
    #
    # ==== Examples
    #   <%= error_messages_for :person %>
    #   <%= error_messages_for :person {|errors| "You can has probs nao: #{errors.size} of em!"}
    #   <%= error_messages_for :person, lambda{|error| "<li class='aieeee'>#{error.join(' ')}"} %>
    #   <%= error_messages_for :person, nil, 'bad_mojo' %>
    def error_messages_for(obj, error_class, build_li, header, before)
      obj ||= @obj
      return "" unless obj.respond_to?(:errors)

      sequel = !obj.errors.respond_to?(:each)
      errors = sequel ? obj.errors.full_messages : obj.errors

      return "" if errors.empty?

      header_message = header % [errors.size, errors.size == 1 ? "" : "s"]
      markup = %Q{<div class='#{error_class}'>#{header_message}<ul>}
      errors.each {|err| markup << (build_li % (sequel ? err : err.join(" ")))}
      markup << %Q{</ul></div>}
    end
  end

  class FormWithErrors < Form
    include Errorifier
  end

  module Resourceful
    def process_form_attrs(attrs)
      attrs[:action] ||= url(@name, @obj) if @origin
      super
    end
  end

  class ResourcefulForm < Form
    include Resourceful
  end

  class ResourcefulFormWithErrors < FormWithErrors
    include Errorifier
    include Resourceful
  end

end
