module Merb
  module Helpers
    module Form
    
      def error_messages_for(obj, error_li = nil, html_class='submittal_failed')
        return "" if obj.errors.empty?
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
      
      def obj_from_ivar_or_sym(obj)
        obj.is_a?(Symbol) ? instance_variable_get("@#{obj}") : obj
      end
      
      def tag(tag_name, contents, attrs = {})
        open_tag(tag_name, attrs) + contents + "</#{tag_name}>"
      end
      
      def form_tag(attrs = {}, &block)
        attrs.merge!( :enctype => "multipart/form-data" ) if attrs.delete(:multipart)
        fake_form_method = set_form_method(attrs)
        concat(open_tag("form", attrs), block.binding)
        concat(generate_fake_form_method(fake_form_method), block.binding) if fake_form_method
        concat(capture(&block), block.binding)
        concat("</form>", block.binding)
      end
      
      def form_for(obj, attrs={}, &block)
        obj = obj_from_ivar_or_sym(obj)
        fake_form_method = set_form_method(attrs, obj)
        concat(open_tag("form", attrs), block.binding)
        concat(generate_fake_form_method(fake_form_method), block.binding) if fake_form_method
        fields_for(obj, attrs, &block)
        concat("</form>", block.binding)
      end
      
      def fields_for(obj, attrs=nil, &block)
        obj = obj_from_ivar_or_sym(obj)
        old_obj, @_obj = @_obj, obj
        @_object_name = "#{@_obj.class}".snake_case
        old_block, @_block = @_block, block
        
        concat(capture(&block), block.binding)

        @_obj, @_block = old_obj, old_block        
      end
      
      def control_name(col)
        "#{@_object_name}[#{col}]"
      end
      
      def control_value(col)
        @_obj.send(col)
      end
      
      def control_name_value(col, attrs)
        {:name => control_name(col), :value => control_value(col)}.merge(attrs)
      end
      
      def text_control(col, attrs = {})
        errorify_field(attrs, col)
        text_field(control_name_value(col, attrs))
      end
      
      def text_field(attrs = {})
        attrs.merge!(:type => "text")
        optional_label(attrs) { self_closing_tag("input", attrs) }
      end
      
      def checkbox_control(col, attrs = {})
        errorify_field(attrs, col)
        val = @_obj.send(col)
        attrs.merge!(:value => val ? "1" : "0")
        attrs.merge!(:checked => "checked") if val
        checkbox_field(control_name_value(col, attrs))
      end
      
      def checkbox_field(attrs = {})
        attrs.merge!(:type => :checkbox)
        attrs.add_html_class!("checkbox")
        optional_label(attrs){self_closing_tag("input", attrs)}
      end
      
      def hidden_control(col, attrs = {})
        attrs.delete(:label)
        errorify_field(attrs, col)
        hidden_field(control_name_value(col, attrs))
      end
      
      def hidden_field(attrs = {})
        attrs.delete(:label)
        attrs.merge!(:type => :hidden)
        self_closing_tag("input", attrs)
      end
      
      def radio_group_control(col, options = {}, attrs = {})
        errorify_field(attrs, col)
        val = @_obj.send(col)
        ret = ""
        options.each do |opt|
          hash = {:name => "#{@_object_name}[#{col}]", :value => opt, :label => opt}
          hash.merge!(:selected => "selected") if val.to_s == opt.to_s
          ret << radio_field(hash)
        end
        ret
      end
      
      def radio_field(attrs = {})
        attrs.merge!(:type => "radio")
        attrs.add_html_class!("radio")
        optional_label(attrs){self_closing_tag("input", attrs)}
      end
      
      def text_area_control(col, attrs = {})
        attrs ||= {}
        errorify_field(attrs, col)
        text_area_field(control_value(col), attrs.merge(:name => control_name(col)))
      end
      
      def text_area_field(val, attrs = {})
        val ||=""
        optional_label(attrs) do
          open_tag("textarea", attrs) +
          val +
          "</textarea>"
        end
      end
      
      def submit_button(contents, attrs = {})
        attrs.merge!(:type => "submit")
        tag("button", contents, attrs)
      end

      def label(name, contents = "", attrs = {})
        tag("label", name.to_s + contents, attrs)
      end
      
      private
      # Fake out the browser to send back the method for RESTful stuff.
      # Fall silently back to post if a method is given that is not supported here
      def set_form_method(options = {}, obj = nil)
        options[:method] ||= (!obj || obj.new_record? ? :post : :put)
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
          label(title, yield, label.is_a?(Hash) ? label : {})
        else
          yield
        end
      end   
      
      def errorify_field(attrs, col)
        attrs.add_html_class!("error") if !@_obj.valid? && @_obj.errors.on(col)
      end         
      
    end
  end
end

class Merb::ViewContext
  include Merb::Helpers::Form
end