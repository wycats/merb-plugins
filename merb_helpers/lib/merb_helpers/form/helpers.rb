# Provides a number of methods for creating form tags which may be used either with or without the presence of ORM specific models.
# There are two types of form helpers: those that specifically work with model attributes and those that don't.
# This helper deals with both model attributes and generic form tags. Model attributes generally end in "_control" such as +text_control+,
# and generic tags end with "_field", such as +text_field+
#
# The core method of this helper, +form_for+, gives you the ability to create a form for a resource.
# For example, let's say that you have a model <tt>Person</tt> and want to create a new instance of it:
#
#     <%= form_for :person, :action => url(:people) do %>
#       <%= text_control :first_name, :label => 'First Name' %>
#       <%= text_control :last_name,  :label => 'Last Name' %>
#       <%= submit_button 'Create' %>
#     <% end =%>
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
#     <%= form :action => url(:controller => "foo", :action => "bar", :id => 1) do %>
#       <%= text_field :name => 'first_name', :label => 'First Name' %>
#       <%= submit_button 'Create' %>
#     <% end =%>
#
# The HTML generated for this would be:
#
#     <form action="/foo/bar/1" method="post">
#       <label for="first_name">First Name</label><input id="first_name" name="first_name" size="30" type="text" />
#       <button type="submit">Create</button>
#     </form>
module Merb::Helpers::Form

  def _singleton_form_context
    @_singleton_form_context ||=
      self._form_class.new(nil, nil, self)
  end

  def form_contexts
    @_form_contexts ||= []
  end

  def current_form_context
    form_contexts.last || _singleton_form_context
  end

  def _new_form_context(name, builder)
    if name.is_a?(String) || name.is_a?(Symbol)
      ivar = instance_variable_get("@#{name}")
    else
      ivar, name = name, name.class.to_s.snake_case
    end
    builder ||= current_form_context.class if current_form_context
    (builder || self._form_class).new(ivar, name, self)
  end

  def with_form_context(name, builder)
    form_contexts.push(_new_form_context(name, builder))
    ret = yield
    form_contexts.pop
    ret
  end

  # Generates a form tag, which accepts a block that is not directly based on resource attributes
  # 
  #     <%= form :action => url(:controller => "foo", :action => "bar", :id => 1) do %>
  #       <%= text_field :name => 'first_name', :label => 'First Name' %>
  #       <%= submit_button 'Create' %>
  #     <% end =%>
  #
  # The HTML generated for this would be:
  #
  #     <form action="/foo/bar/1" method="post">
  #       <label for="first_name">First Name</label><input id="first_name" name="first_name" size="30" type="text" />
  #       <input name="commit" type="submit" value="Create" />
  #     </form>
  def form(*args, &blk)
    _singleton_form_context.form(*args, &blk)
  end

  # Generates a resource specific form tag which accepts a block, this also provides automatic resource routing.
  #     <%= form_for :person, :action => url(:people) do %>
  #       <%= text_control :first_name, :label => 'First Name' %>
  #       <%= text_control :last_name,  :label => 'Last Name' %>
  #       <%= submit_button 'Create' %>
  #     <% end= %>
  #
  # The HTML generated for this would be:
  #
  #     <form action="/people/create" method="post">
  #       <label for="person[first_name]">First Name</label><input id="person_first_name" name="person[first_name]" size="30" type="text" />
  #       <label for="person[last_name]">Last Name</label><input id="person_last_name" name="person[last_name]" size="30" type="text" />
  #       <input name="commit" type="submit" value="Create" />
  #     </form>
  def form_for(name, attrs = {}, &blk)
    with_form_context(name, attrs.delete(:builder)) do
      current_form_context.form(attrs, &blk)
    end
  end

  # Creates a scope around a specific resource object like form_for, but doesnt create the form tags themselves.
  # This makes fields_for suitable for specifying additional resource objects in the same form. 
  #
  # ==== Examples
  #     <%= form_for :person, :action => url(:people) do %>
  #       <%= text_control :first_name, :label => 'First Name' %>
  #       <%= text_control :last_name,  :label => 'Last Name' %>
  #       <% fields_for :permission do %>
  #         <%= checkbox_control :is_admin, :label => 'Administrator' %>
  #       <% end %>
  #       <%= submit_button 'Create' %>
  #     <% end =%>
  def fields_for(name, attrs = {}, &blk)
    attrs ||= {}
    with_form_context(name, attrs.delete(:builder)) do
      current_form_context.concat(attrs, &blk)
    end
  end

  # Provides the ability to create quick fieldsets as blocks for your forms.
  #
  # ==== Example
  #     <%= fieldset :legend => 'Customer Options' do -%>
  #     ...your form elements
  #     <% end =%>
  #
  #     => <fieldset><legend>Customer Options</legend>...your form elements</fieldset>
  #
  # ==== Options
  # +legend+:: The name of this fieldset which will be provided in a HTML legend tag.
  def fieldset(attrs = {}, &blk)
    _singleton_form_context.fieldset(attrs, &blk)
  end

  def fieldset_for(name, attrs = {}, &blk)
    with_form_context(name, attrs.delete(:builder)) do
      current_form_context.fieldset(attrs, &blk)
    end
  end

  %w(text radio password hidden checkbox
  radio_group text_area select file).each do |kind|
    self.class_eval <<-RUBY, __FILE__, __LINE__ + 1
      def #{kind}_control(*args)
        current_form_context.#{kind}_control(*args)
      end

      def #{kind}_field(*args)
        _singleton_form_context.#{kind}_field(*args)
      end
    RUBY
  end

  # Provides a generic HTML button.
  #
  # ==== Example
  #     <%= button "Process" %>
  def button(contents, attrs = {})
    _singleton_form_context.button(contents, attrs)
  end

  # Provides a generic HTML submit button.
  #
  # ==== Example
  #     <%= submit "Process" %>
  def submit(contents, attrs = {})
    _singleton_form_context.submit(contents, attrs)
  end

  # Provides a HTML formatted display of resource errors in an unordered list with a h2 form submission error
  # ==== Options
  # +build_li+:: Block for generating a list item for an error. It receives an instance of the error.
  # +html_class+:: Set for custom error div class default is <tt>submission_failed<tt>
  #
  # ==== Examples
  #   <%= error_messages_for :person %>
  #   <%= error_messages_for :person {|errors| "You can has probs nao: #{errors.size} of em!"}
  #   <%= error_messages_for :person, lambda{|error| "<li class='aieeee'>#{error.join(' ')}"} %>
  #   <%= error_messages_for :person, nil, 'bad_mojo' %>
  def error_messages_for(obj = nil, opts = {})
    current_form_context.error_messages_for(obj, opts[:error_class] || "error", 
      opts[:build_li] || "<li>%s</li>", 
      opts[:header] || "<h2>Form submission failed because of %s problem%s</h2>",
      opts.key?(:before) ? opts[:before] : true)
  end
  alias error_messages error_messages_for

end
