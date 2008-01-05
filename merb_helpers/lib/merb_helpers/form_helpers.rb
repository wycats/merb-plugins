module Merb #:nodoc:
  
  # Merb helpers include several helpers used for simplifying view creation.
  # The available helpers currently include form tag helpers for both resource based and generic HTML form tag creation
  module Helpers
    # Provides a number of methods for creating form tags which may be used either with or without the presence of ORM specific models.
    # There are two types of form helpers: those that specifically work with model attributes and those that don't.
	  # This helper deals with both model attributes and generic form tags. Model attributes generally end in "_control" such as +text_control+,
	  # and generic tags end with "_field", such as +text_field+
    #
	  # The core method of this helper, +form_for+, gives you the ability to create a form for a resource.
    # For example, let's say that you have a model <tt>Person</tt> and want to create a new instance of it:
    #
    #     <% form_for :person, :action => url(:people) do %>
    #       <%= text_control :first_name, :label => 'First Name' %>
    #       <%= text_control :last_name,  :label => 'Last Name' %>
    #       <%= submit_button 'Create' %>
    #     <% end %>
    #
    # The HTML generated for this would be:
    #
    #     <form action="/people/create" method="post">
    #       <label for="person_first_name">First Name</label>
    #       <input id="person_first_name" name="person[first_name]" size="30" type="text" />
    #       <label for="person_last_name">Last Name</label>
    #       <input id="person_last_name" name="person[last_name]" size="30" type="text" />
    #       <button type="submit">Create</button>
    #     </form>
    #
	  # You may also create a normal form using form_tag
    #     <% form_tag({url(:controller => "foo", :action => "bar", :id => 1)} do %>
    #       <%= text_field :name => 'first_name', :label => 'First Name' %>
    #       <%= submit_button 'Create' %>
    #     <% end %>
    #
    # The HTML generated for this would be:
    #
    #     <form action="/foo/bar/1" method="post">
    #       <label for="first_name">First Name</label><input id="first_name" name="first_name" size="30" type="text" />
    #       <button type="submit">Create</button>
    #     </form>
    module Form
    
      # Provides a HTML formatted display of resource errors in an unordered list with a h2 form submission error
      # ==== Options
      # +html_class+:: Set for custom error div class default is <tt>submittal_failed<tt>
      #
      # ==== Example
      #   <%= error_messages_for :person %>      
      def error_messages_for(obj, error_li = nil, html_class='submittal_failed')
        return "" if !obj.respond_to?(:errors) || obj.errors.empty?
        header_message = block_given? ? yield(obj.errors) : "<h2>Form submittal failed because of #{obj.errors.size} #{obj.errors.size == 1 ? 'problem' : 'problems'}</h2>"
        ret = %Q{
          <div class='#{html_class}'>
            #{header_message}
            <ul>
        }
        obj.errors.each {|err| ret << (error_li ? error_li.call(err) : "<li>#{err.join(" ")}</li>") }
        ret << %Q{
            </ul>
          </div>
        }
      end
      
      def obj_from_ivar_or_sym(obj) #:nodoc:
        obj.is_a?(Symbol) ? instance_variable_get("@#{obj}") : obj
      end

      # Creates a generic HTML tag 
      def tag(tag_name, contents, attrs = {}) #:nodoc:
        open_tag(tag_name, attrs) + contents.to_s + "</#{tag_name}>"
      end

      # Generates a form tag, which accepts a block that is not directly based on resource attributes
      # 
      #     <% form_tag({url(:controller => "foo", :action => "bar", :id => 1)} do %>
      #       <%= text_field :name => 'first_name', :label => 'First Name' %>
      #       <%= submit_button 'Create' %>
      #     <% end %>
      #
      # The HTML generated for this would be:
      #
      #     <form action="/foo/bar/1" method="post">
      #       <label for="first_name">First Name</label><input id="first_name" name="first_name" size="30" type="text" />
      #       <input name="commit" type="submit" value="Create" />
      #     </form>
      def form_tag(attrs = {}, &block)
        set_multipart_attribute!(attrs)
        fake_form_method = set_form_method(attrs)
        concat(open_tag("form", attrs), block.binding)
        concat(generate_fake_form_method(fake_form_method), block.binding) if fake_form_method
        concat(capture(&block), block.binding)
        concat("</form>", block.binding)
      end
      
      # Generates a resource specific form tag which accepts a block, this also provides automatic resource routing.
      #     <% form_for :person, :action => url(:people) do %>
      #       <%= text_control :first_name, :label => 'First Name' %>
      #       <%= text_control :last_name,  :label => 'Last Name' %>
      #       <%= submit_button 'Create' %>
      #     <% end %>
      #
      # The HTML generated for this would be:
      #
      #     <form action="/people/create" method="post">
      #       <label for="person[first_name]">First Name</label><input id="person_first_name" name="person[first_name]" size="30" type="text" />
      #       <label for="person[last_name]">Last Name</label><input id="person_last_name" name="person[last_name]" size="30" type="text" />
      #       <input name="commit" type="submit" value="Create" />
      #     </form>
      def form_for(obj, attrs={}, &block)
        set_multipart_attribute!(attrs)
        obj = obj_from_ivar_or_sym(obj)
        fake_form_method = set_form_method(attrs, obj)
        concat(open_tag("form", attrs), block.binding)
        concat(generate_fake_form_method(fake_form_method), block.binding) if fake_form_method
        fields_for(obj, attrs, &block)
        concat("</form>", block.binding)
      end
      
      # Creates a scope around a specific resource object like form_for, but doesnt create the form tags themselves.
      # This makes fields_for suitable for specifying additional resource objects in the same form. 
      #
      # ==== Examples
      #     <% form_for :person, :action => url(:people) do %>
      #       <%= text_control :first_name, :label => 'First Name' %>
      #       <%= text_control :last_name,  :label => 'Last Name' %>
      #       <% fields_for :permission do %>
      #         <%= checkbox_control :is_admin, :label => 'Administrator' %>
      #       <% end %>
      #       <%= submit_button 'Create' %>
      #     <% end %>
      def fields_for(obj, attrs=nil, &block)
        @_obj ||= nil
        @_block ||= nil
        obj = obj_from_ivar_or_sym(obj)
        old_obj, @_obj = @_obj, obj
        @_object_name = "#{@_obj.class}".snake_case
        old_block, @_block = @_block, block
        
        concat(capture(&block), block.binding)

        @_obj, @_block = old_obj, old_block        
      end
      
      def control_name(col) #:nodoc:
        "#{@_object_name}[#{col}]"
      end
      
      def control_id(col) #:nodoc:
        "#{@_object_name}_#{col}"
      end
      
      def control_value(col) #:nodoc:
        @_obj.send(col)
      end
      
      def control_name_value(col, attrs) #:nodoc:
        {:name => control_name(col), :value => control_value(col)}.merge(attrs)
      end
      
      # Provides a HTML text input tag based on a resource attribute.
      #
      # ==== Example
      #     <% form_for :person, :action => url(:people) do %>
      #       <%= text_control :first_name, :label => 'First Name' %>
      #     <% end %>
      def text_control(col, attrs = {})
        errorify_field(attrs, col)
        attrs.merge!(:id => control_id(col))
        text_field(control_name_value(col, attrs))
      end
      
      # Provides a generic HTML text input tag.
      # Provides a HTML text input tag based on a resource attribute.
      #
      # ==== Example
      #     <%= text_field :fav_color, :label => 'Your Favorite Color' %>
      #     # => <label for="fav_color">Your Favorite Color</label><input type="text" name="fav_color" id="fav_color"/>
      def text_field(attrs = {})
        attrs.merge!(:type => "text")
        optional_label(attrs) { self_closing_tag("input", attrs) }
      end
      
      # Provides a HTML password input based on a resource attribute.
      # This is generally used within a resource block such as +form_for+.
      #
      # ==== Example
      #     <%= password_control :password, :label => 'New Password' %>
      def password_control(col, attrs = {})
        attrs.merge!(:name => control_name(col), :id => control_id(col))
        errorify_field(attrs, col)
        password_field(control_name_value(col, attrs))
      end
      
      # Provides a generic HTML password input tag.
      #
      # ==== Example
      #     <%= password_field :password, :label => "Password" %>
      #     # => <label for="password">Password</label><input type="password" name="password" id="password"/>
      def password_field(attrs = {})
        attrs.delete(:value)
        attrs.merge!(:type => 'password')
        optional_label(attrs) { self_closing_tag("input", attrs) }
      end
      
      # translate column values from the db to boolean
      # nil, false, 0 and '0' are false. All others are true
      def col_val_to_bool(val) #:nodoc:
        !(val == "0" || val == 0 || !val)
      end
      private :col_val_to_bool

      # Provides a HTML checkbox input based on a resource attribute.
      # This is generally used within a resource block such as +form_for+.
      #
      # ==== Example
      #     <%= checkbox_control :is_activated, :label => "Activated?" %>
      def checkbox_control(col, attrs = {}, hidden_attrs={})
        errorify_field(attrs, col)
        attrs.merge!(:checked => "checked") if col_val_to_bool(@_obj.send(col))
        attrs.merge!(:id => control_id(col))
        checkbox_field(control_name_value(col, attrs), hidden_attrs)
      end

      # Provides a generic HTML checkbox input tag.
      # There are two ways this tag can be generated, based on the
      # option :boolean. If not set to true, a "magic" input is generated.
      # Otherwise, an input is created that can be easily used for passing
      # an array of values to the application.
      #
      # ==== Example
      #     <% checkbox_field :name => "is_activated", :value => "1" %>
      #
      #     <% checkbox_field :name => "choices[]", :boolean => false, :value => "dog" %>
      #     <% checkbox_field :name => "choices[]", :boolean => false, :value => "cat" %>
      #     <% checkbox_field :name => "choices[]", :boolean => false, :value => "weasle" %>
      def checkbox_field(attrs = {}, hidden_attrs={})
        boolbox = true
        boolbox = false if ( attrs.has_key?(:boolean) and !attrs[:boolean] )
        attrs.delete(:boolean)

        if( boolbox )
                on            = attrs.delete(:on)  || 1
                off           = attrs.delete(:off) || 0
                attrs[:value] = on if ( (v = attrs[:value]).nil? || v != "" )
        else
                # HTML-escape the value attribute
                attrs[:value] = escape_xml( attrs[:value] )
        end

        attrs.merge!(:type => :checkbox)
        attrs.add_html_class!("checkbox")
        (boolbox ? hidden_field({:name => attrs[:name], :value => off}.merge(hidden_attrs)) : '') + optional_label(attrs){self_closing_tag("input", attrs)}
      end

      # Returns a hidden input tag tailored for accessing a specified attribute (identified by +col+) on an object
      # resource within a +form_for+ resource block. Additional options on the input tag can be passed as a
      # hash with +attrs+. These options will be tagged onto the HTML as an HTML element attribute as in the example
      # shown.
      #
      # ==== Example
      #     <%= hidden_control :identifier %>
      #     # => <input id="person_identifier" name="person[identifier]" type="hidden" value="#{@person.identifier}" />
      def hidden_control(col, attrs = {})
        attrs.delete(:label)
        errorify_field(attrs, col)
        attrs[:class] ||= "hidden"
        hidden_field(control_name_value(col, attrs))
      end
      
      # Provides a generic HTML hidden input field.
      #
      # ==== Example
      #     <%= hidden_field :name => "secret", :value => "some secret value" %>
      def hidden_field(attrs = {})
        attrs.delete(:label)
        attrs.merge!(:type => :hidden)
        self_closing_tag("input", attrs)
      end
      
      # Provides a radio group based on a resource attribute.
      # This is generally used within a resource block such as +form_for+.
      #
      # ==== Examples
      #     <%# the labels are the options %>
      #     <%= radio_group_control :my_choice, [5,6,7] %>
      # 
      #     <%# custom labels %>
      #     <%= radio_group_control :my_choice, [{:value => 5, :label => "five"}] %>
      def radio_group_control(col, options = [], attrs = {})
        errorify_field(attrs, col)
        val = @_obj.send(col)
        ret = ""
        options.each do |opt|
          value, label = opt.is_a?(Hash) ? [opt[:value], opt[:label]] : [opt, opt]
          hash = {:name => "#{@_object_name}[#{col}]", :value => value, :label => label}
          hash.merge!(:selected => "selected") if val.to_s == value.to_s
          ret << radio_field(hash)
        end
        ret
      end
      
      # Provides a generic HTML radio input tag.
      # Normally, you would use multipe +radio_field+.
      #
      # ==== Example
      #     <%= radio_field :name => "radio_options", :value => "1", :label => "One" %>
      #     <%= radio_field :name => "radio_options", :value => "2", :label => "Two" %>
      def radio_field(attrs = {})
        attrs.merge!(:type => "radio")
        attrs.add_html_class!("radio")
        optional_label(attrs){self_closing_tag("input", attrs)}
      end
      
      # Provides a HTML textarea based on a resource attribute
      # This is generally used within a resource block such as +form_for+
      #
      # ==== Example
      #     <% text_area_control :comments, :label => "Comments"
      def text_area_control(col, attrs = {})
        attrs ||= {}
        errorify_field(attrs, col)
        text_area_field(control_value(col), attrs.merge(:name => control_name(col)))
      end
      
      # Provides a generic HTML textarea tag.
      #
      # ==== Example
      #     <% text_area_field "my comments", :name => "comments", :label => "Comments" %>
      def text_area_field(val, attrs = {})
        val ||=""
        optional_label(attrs) do
          open_tag("textarea", attrs) +
          val +
          "</textarea>"
        end
      end
      
      # Provides a generic HTML submit button.
      #
      # ==== Example
      #     <% submit_button "Process" %>
      def submit_button(contents, attrs = {})
        contents ||= "Submit"
        attrs.merge!(:type => "submit")
        tag("button", contents, attrs)
      end

      # Provides a generic HTML label.
      #
      # ==== Example
      #     <% label "Name", "", :for => "name" %> 
      #     # => <label for="name">Name</label>
      def label(name, contents = "", attrs = {})
        tag("label", name.to_s + contents, attrs)
      end

      # Provides a generic HTML select.
      #
      # ==== Options
      # +prompt+:: Adds an additional option tag with the provided string with no value.
      # +selected+:: The value of a selected object, which may be either a string or an array.
      # +include_blank+:: Adds an additional blank option tag with no value.
      # +collection+:: The collection for the select options
      # +text_method+:: Method to determine text of an option (as a symbol). Ex: :text_method => :name  will call .name on your record object for what text to display.
      # +value_method+:: Method to determine value of an option (as a symbol).
      def select_field(attrs = {})
        collection = attrs.delete(:collection)
        option_attrs = {
          :prompt => attrs.delete(:prompt),
          :selected => attrs.delete(:selected),
          :include_blank => attrs.delete(:include_blank),
          :text_method => attrs.delete(:text_method),
          :value_method => attrs.delete(:value_method)
        }
        optional_label(attrs) { open_tag('select', attrs) + options_from_collection_for_select(collection, option_attrs) + "</select>"}
      end
      
      # Provides a HTML select based on a resource attribute.
      # This is generally used within a resource block such as +form_for+.
      #
      # ==== Example
      #     <% select_control :name, :collection => %w(one two three four) %>
      def select_control(col, attrs = {})
        attrs.merge!(:name => attrs[:name] || control_name(col))
        attrs.merge!(:id   => attrs[:id]   || control_id(col))
        errorify_field(attrs, col)
        optional_label(attrs) { select_field(attrs) }
      end
      
      # Accepts a collection (hash, array, enumerable, your type) and returns a string of option tags. 
      # Given a collection where the elements respond to first and last (such as a two-element array), 
      # the "lasts" serve as option values and the "firsts" as option text. Hashes are turned into
      # this form automatically, so the keys become "firsts" and values become lasts. If selected is
      # specified, the matching "last" or element will get the selected option-tag. Selected may also
      # be an array of values to be selected when using a multiple select.
      #
      # ==== Examples
      #   <%= options_for_select( [['apple','Apple Pie'],['orange','Orange Juice']], :selected => 'orange' )
      #   => <option value="apple">Apple Pie</option><option value="orange" selected="selected">Orange Juice</option>
      #
      #   <%= options_for_select( [['apple','Apple Pie'],['orange','Orange Juice']], :selected => ['orange','apple'], :prompt => 'Select One' )
      #   => <option value="">Select One</option><option value="apple" selected="selected">Apple Pie</option><option value="orange" selected="selected">Orange Juice</option>
      #
      # ==== Options
      # +selected+:: The value of a selected object, which may be either a string or an array.
      # +prompt+:: Adds an addtional option tag with the provided string with no value.
      # +include_blank+:: Adds an additional blank option tag with no value.
      def options_for_select(collection, attrs = {})
        prompt     = attrs.delete(:prompt)
        blank      = attrs.delete(:include_blank)
        selected   = attrs.delete(:selected)
        returning '' do |ret|
          ret << tag('option', prompt, :value => '') if prompt
          ret << tag("option", '', :value => '') if blank
          unless collection.blank?
            if collection.is_a?(Hash)
              collection.each do |label,group|
                ret << open_tag("optgroup", :label => label.to_s.titleize) + options_for_select(group, :selected => selected) + "</optgroup>"
              end
            else
              collection.each do |value,text|
                options = selected.to_a.include?(value) ? {:selected => 'selected'} : {}
                ret << tag( 'option', text, {:value => value}.merge(options) )
              end
            end
          end
        end
      end

      # Returns a string of option tags that have been compiled by iterating over the collection and
      # assigning the the result of a call to the value_method as the option value and the text_method
      # as the option text. If selected_value is specified, the element returning a match on
      # the value_method option will get the selected option tag.
      #
      # This method also also supports the automatic generation of optgroup tags by using a hash.
      # ==== Examples
      # If we had a collection of people within a @project object, and want to use 'id' as the value, and 'name'
      # as the option content we could do something similar to this;
      #
      #   <%= options_from_collection_for_select(@project.people, :text_method => "id", :value_method => "name") %>
      #   The iteration of the collection would create options in this manner;
      #   =>  <option value="#{person.id}">#{person.name}</option>
      #
      #   <% @people = Person.find(:all).group_by( &:state )
      #   <%= options_for_select(@people, :text_method => 'full_name', :value_method => 'id', :selected => 3) %>
      #   => <optgroup label="Washington"><option value="1">Josh Martin</option><option value="2">John Doe</option></optgroup>
      #   => <optgroup label="Idaho"><option value="3" selected="selected">Jane Doe</option>
      #
      # ==== Options
      # +text_method+:: Defines the method which will be used to provide the text of the option tags (required)
      # +value_method+:: Defines the method which will be used to provide the value of the option tags (required)
      # +selected+:: The value of a selected object, may be either a string or an array.
      def options_from_collection_for_select(collection, attrs = {})
        prompt     = attrs.delete(:prompt)
        blank      = attrs.delete(:include_blank)
        if collection.is_a?(Hash)
          returning '' do |ret|
	          ret << tag("option", prompt, :value => '') if prompt
	          ret << tag("option", '',     :value => '') if blank
            collection.each do |label, group|
              ret << open_tag("optgroup", :label => label.to_s.humanize.titleize) + options_from_collection_for_select(group, attrs) + "</optgroup>"
            end
          end
        else
          text_method    = attrs[:text_method]
          value_method   = attrs[:value_method]
          selected_value = attrs[:selected]
          
          text_method ||= :to_s
          value_method ||= text_method
          
          options_for_select((collection || []).inject([]) { |options, object| 
              options << [ object.send(value_method), object.send(text_method) ] },
            :selected => selected_value, :include_blank => blank, :prompt => prompt
          )
        end
      end
      
      # Provides the ability to create quick fieldsets as blocks for your forms.
      #
      # ==== Example
      #     <% fieldset :legend => 'Customer Options' do -%>
      #     ...your form elements
      #     <% end -%>
      #
      #     => <fieldset><legend>Customer Options</legend>...your form elements</fieldset>
      #
      # ==== Options
      # +legend+:: The name of this fieldset which will be provided in a HTML legend tag.
      def fieldset(attrs={}, &block)
        legend = attrs.delete(:legend)
        concat( open_tag('fieldset', attrs), block.binding )
        concat( tag('legend', legend), block.binding ) if legend
        concat(capture(&block), block.binding)
        concat( "</fieldset>", block.binding)
      end
      
      # Provides a HTML file input for a resource attribute.
      # This is generally used within a resource block such as +form_for+.
      #
      # ==== Example
      #     <% file_control :file, :label => "File" %>
      def file_control(col, attrs = {})
        errorify_field(attrs, col)
        file_field(control_name_value(col, attrs))
      end
      
      # Provides a HTML file input
      #
      # ==== Example
      #     <% file_field :name => "file", :label => "File" %>
      def file_field(attrs = {})
        attrs.merge!(:type => "file")
        optional_label(attrs) { self_closing_tag("input", attrs) }
      end
      
      def submit_field(attrs = {})
        attrs.merge!(:type => :submit)
        attrs[:name] ||= "submit"
        self_closing_tag("input", attrs)
      end

      # Generates a delete button inside of a form. 
      # 
      #     <%= delete_button :news_post, @news_post, 'Remove' %>
      # 
      # The HTML generated for this would be:
      # 
      #     <form method="post" action="/news_posts/4">
      #       <input type="hidden" value="delete" name="_method"/>
      #       <button type="submit">Remove</button>
      #     </form>
      def delete_button(symbol, obj, contents = 'Delete', form_attrs = {}, button_attrs = {})
        button_attrs.merge!(:type => 'submit')
        form_attrs.merge!(:action => url(symbol, obj), :method => :delete)

        obj = obj_from_ivar_or_sym(symbol)
        fake_form_method = set_form_method(form_attrs, obj)

        output = ""
        output << open_tag("form", form_attrs)
        output << generate_fake_form_method(fake_form_method)
        output << tag("button", contents, button_attrs)
        output << "</form>"
        output
      end
         
      private

      # Fake out the browser to send back the method for RESTful stuff.
      # Fall silently back to post if a method is given that is not supported here
      def set_form_method(options = {}, obj = nil)
        options[:method] ||= (!obj || (obj.respond_to?(:new_record?) && !obj.new_record?) ? :put : :post)
        if ![:get,:post].include?(options[:method])
          fake_form_method = options[:method] if [:put, :delete].include?(options[:method])
          options[:method] = :post
        end
        fake_form_method
      end

      def generate_fake_form_method(fake_form_method)
        fake_form_method ? hidden_field(:name => "_method", :value => "#{fake_form_method}") : ""
      end
      
      def optional_label(attrs = {})
        label = attrs.delete(:label) if attrs
        if label
          title = label.is_a?(Hash) ? label.delete(:title) : label
          named = attrs[:id].blank? ? {} : {:for => attrs[:id]}
          label(title, '', label.is_a?(Hash) ? label.merge(named) : named) + yield
        else
          yield
        end
      end
      
      def errorify_field(attrs, col)
        attrs.add_html_class!("error") if @_obj.respond_to?(:errors) && @_obj.errors.on(col)
      end   
      
      def set_multipart_attribute!(attrs = {})
        attrs.merge!( :enctype => "multipart/form-data" ) if attrs.delete(:multipart)      
      end
      
    end
  end
end

class Merb::ViewContext #:nodoc:
  include Merb::Helpers::Form
end
